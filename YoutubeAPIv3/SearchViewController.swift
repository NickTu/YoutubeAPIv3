//
//  SearchViewController.swift
//  YoutubeAPI
//
//  Created by 涂安廷 on 2016/5/29.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {

    @IBOutlet weak var videoCategories: UIBarButtonItem!
    @IBOutlet weak var searchSettings: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelSearchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewTop: NSLayoutConstraint!
    @IBOutlet weak var searchViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBAction func cancelSearch(sender: UIButton) {
        searchBar.text = ""
        sender.hidden = true
        searchViewConstraint.constant = 0
        searchBar.resignFirstResponder()
    }
    
    var searchSuccessCount = 0
    var successCount = 0
    var apiKey = "AIzaSyDJFb3a04UYWc0NSdJv07SQ-wf8TFgyI6Y"
    var collectionDataArray: Dictionary<String,Dictionary<NSObject, AnyObject>> = [:]
    var keyVideoId:Array<String> = []
    let youtubeNetworkAddress = "https://www.googleapis.com/youtube/v3/"
    let videoTypeDictionary = [ "All":"0", "Film & Animation":"1", "Autos & Vehicles":"2", "Music":"10", "Pets & Animals":"15", "Sports":"17", "Short Movies":"18", "Travel & Events":"19", "Gaming":"20", "Videoblogging":"21", "People & Blogs":"22", "Comedy":"23", "Entertainment":"24", "News & Politics":"25", "Howto & Style":"26", "Education":"27", "Science & Technology":"28", "Movies":"30", "Anime/Animation":"31", "Action/Adventure":"32", "Classics":"33", "Documentary":"35", "Drama":"36", "Family":"37", "Foreign":"38", "Horror":"39", "Sci-Fi/Fantasy":"40", "Thriller":"41", "Shorts":"42", "Shows":"43", "Trailers":"44" ]
    var activityIndicator: UIActivityIndicatorView!
    var pageToken:String!
    var hasNextPage:Bool!
    var isScrollSearch:Bool!
    var selectedIndex:Int!
    var againSearch:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "VideoCollectionCellXib",bundle: nil), forCellWithReuseIdentifier: "idVideoCollectionCell")
        searchBar.delegate = self
        cancelSearchButton.hidden = true
        searchViewConstraint.constant = 0
        pageToken = ""
        hasNextPage = false
        againSearch = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.frame = CGRect(x: self.view.bounds.width/2-25, y: searchBar.frame.size.height + navigationBar.frame.size.height + 20, width: 50, height: 50)
        view.addSubview(activityIndicator)
        hasNextPage = true
        isScrollSearch = false
        if searchBar.text?.characters.count > 0 && againSearch{
            cleanDataAndStartSearch()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "idPlaylistItem" {
            againSearch = false
            let playlistItemViewController = segue.destinationViewController as! PlaylistItemViewController
            let details = collectionDataArray[keyVideoId[selectedIndex]]!
            playlistItemViewController.playlistId = details["playlistID"] as! String
        } else if segue.identifier == "idPlay"{
            againSearch = false
            let playViewController = segue.destinationViewController as! PlayViewController
            let details = collectionDataArray[keyVideoId[selectedIndex]]!
            playViewController.videoID = details["videoID"] as! String
        }else {
            againSearch = true
        }
    }
    
    func cleanDataAndStartSearch(){
        self.collectionView.scrollEnabled = false
        keyVideoId.removeAll(keepCapacity: false)
        collectionDataArray.removeAll(keepCapacity: false)
        collectionViewTop.constant = activityIndicator.frame.height
        search(searchBar.text!)
    }
    
    func endSearch(){
        self.activityIndicator.stopAnimating()
        collectionViewTop.constant = 0
        self.collectionView.reloadData()
        self.collectionView.scrollEnabled = true
        isScrollSearch = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        keyVideoId.removeAll(keepCapacity: false)
        collectionDataArray.removeAll(keepCapacity: false)
        search(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchViewConstraint.constant = cancelSearchButton.frame.size.width
        cancelSearchButton.hidden = false
        searchBar.frame.size.width = view.bounds.width - cancelSearchButton.frame.size.width
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchViewConstraint.constant = 0
        cancelSearchButton.hidden = true
        searchBar.frame.size.width = view.bounds.width
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //print("scrollViewDidScroll")
        let offset = scrollView.contentOffset /* 當前frame距離整個ScrollView的偏移量 */
        let bounds = scrollView.bounds
        let size = scrollView.contentSize /* 整個ScrollView的size */
        let inset = scrollView.contentInset /* 整個ScrollView的EdgeInsets */
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        let reload_distance = -bounds.size.height*10/3
        
        if y > (h + CGFloat(reload_distance) ) && !self.isScrollSearch && self.hasNextPage{
            self.isScrollSearch = true
            search(searchBar.text!)
        }
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("idVideoCollectionCell", forIndexPath: indexPath) as! VideoCollectionCell
        let title = cell.title as UILabel
        let thumbnail = cell.thumbnail as UIImageView
        let count = cell.viewCount as UILabel
        let details = collectionDataArray[keyVideoId[indexPath.row]]!
        if details["title"] == nil {
            title.text = ""
        }else {
            title.text = details["title"] as? String

        }
        if recordSearchSettings.type == "playlist" {
            count.text = "itemCount = " + String(details["itemCount"]!)
        }else {
            count.text = "viewCount = " + (details["viewCount"] as? String)!

        }
        thumbnail.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (details["thumbnail"] as? String)!)!)!)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width/2-5, collectionView.frame.height/3)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if recordSearchSettings.type != "video" {
            selectedIndex = indexPath.row
            performSegueWithIdentifier("idPlaylistItem", sender: self)
        }else {
            selectedIndex = indexPath.row
            performSegueWithIdentifier("idPlay", sender: self)
        }
    }
    
    func getNumberOfDaysInMonth(date: NSDate ) -> NSInteger {
        let calendar = NSCalendar.currentCalendar()
        let range = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        return range.length
    }
    
    func search(searchTest:String){
        
        activityIndicator.startAnimating()
        var urlString:String
        var urlStringVideoCategoryId:String!
        var urlStringVideoDurationDimensionDefinition:String!
        var urlStringUploadTime:String! = ""
        var urlStringPageToken:String!
        self.successCount = 0
        self.searchSuccessCount = 0
        if recordSearchSettings.videoType == "All" {
            urlStringVideoCategoryId = ""
        }else {
            urlStringVideoCategoryId = "&videoCategoryId=\(videoTypeDictionary[recordSearchSettings.videoType]!)"
        }
        if recordSearchSettings.type == "video" {
            urlStringVideoDurationDimensionDefinition = "&videoDuration=\(recordSearchSettings.videoDuration)&videoDimension=\(recordSearchSettings.videoDimension)&videoDefinition=\(recordSearchSettings.videoDefinition)"
        }else {
            urlStringVideoDurationDimensionDefinition = ""
        }
        
        let date = NSDate()
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"
        let dateString = dateformatter.stringFromDate(date)
        
        if recordSearchSettings.uploadTime == "anytime" {
            urlStringUploadTime = ""
        }else if recordSearchSettings.uploadTime == "today"{
            
            let formatter = NSDateFormatter();
            formatter.dateFormat = "yyyy-MM-dd'T00:00:00Z'"
            let todayString = formatter.stringFromDate(date)
            urlStringUploadTime = "&publishedAfter=\(todayString)&publishedBefore=\(dateString)"
            
        }else if recordSearchSettings.uploadTime == "this week"{
            
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            let comps = calendar!.components(.Weekday, fromDate: date)
            let value = -comps.weekday + 1
            let thisweek = NSCalendar.currentCalendar().dateByAddingUnit(.NSDayCalendarUnit, value: value, toDate: date, options: .MatchNextTime)
            let formatter = NSDateFormatter();
            formatter.dateFormat = "yyyy-MM-dd'T00:00:00Z'"
            let weekDayString = formatter.stringFromDate(thisweek!)
            urlStringUploadTime = "&publishedAfter=\(weekDayString)&publishedBefore=\(dateString)"
            
        }else if recordSearchSettings.uploadTime == "this month"{
            
            let formatter = NSDateFormatter();
            formatter.dateFormat = "yyyy-MM-'01T00:00:00Z'"
            let thisMonthString = formatter.stringFromDate(date)
            urlStringUploadTime = "&publishedAfter=\(thisMonthString)&publishedBefore=\(dateString)"
            
        }else if recordSearchSettings.uploadTime == "this year"{
        
            let formatter = NSDateFormatter();
            formatter.dateFormat = "yyyy-'01-01T00:00:00Z'"
            let thisYearString = formatter.stringFromDate(date)
            urlStringUploadTime = "&publishedAfter=\(thisYearString)&publishedBefore=\(dateString)"

        }
        
        if self.pageToken.characters.count == 0 {
            urlStringPageToken = ""
        }else {
            urlStringPageToken = "&pageToken=\(self.pageToken)"
        }
        
        urlString = youtubeNetworkAddress + "search?&part=snippet&maxResults=50&q=\(searchTest)&type=\(recordSearchSettings.type)&key=\(apiKey)&order=\(recordSearchSettings.order)&regionCode=TW" + urlStringVideoCategoryId + urlStringVideoDurationDimensionDefinition + urlStringUploadTime + urlStringPageToken
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // 將 JSON 資料轉換成字典物件
                do {
                    
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    self.searchSuccessCount = items.count
                    /*let totalCount = (resultsDict["pageInfo"] as! Dictionary<NSObject, AnyObject>)["totalResults"]
                    let thisCount = (resultsDict["pageInfo"] as! Dictionary<NSObject, AnyObject>)["resultsPerPage"]
                    print("This search count is \(thisCount)")
                    print("This search totalcount is \(totalCount)")*/
                    
                    if resultsDict["nextPageToken"] != nil && resultsDict["prevPageToken"] != nil{
                        self.hasNextPage = true
                        self.pageToken = resultsDict["nextPageToken"] as! String
                    }else if resultsDict["nextPageToken"] == nil && resultsDict["prevPageToken"] != nil {
                        self.hasNextPage = false
                        self.pageToken = ""
                    }else if resultsDict["nextPageToken"] != nil && resultsDict["prevPageToken"] == nil {
                        self.hasNextPage = true
                        self.pageToken = resultsDict["nextPageToken"] as! String
                    }
                    
                    for i in 0 ..< items.count {
                        let videoId = (items[i]["id"] as! Dictionary<NSObject, AnyObject>)[ (recordSearchSettings.type!) + "Id"] as! String
                        self.keyVideoId.append( videoId )
                        self.getDetails( videoId )
                    }
                    
                 } catch {
                    print(error)
                 }
                
            }else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(error)")
            }
            
        })
        
    }
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 0.5
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
    }
    
    func getDetails(id: String) {

        var urlString: String!
        var urlStringVideoCategoryId:String!
        var urlStringType:String!
        var count:String!
        var part:String!
        if recordSearchSettings.videoType == "All" {
            urlStringVideoCategoryId = ""
            
        }else {
            urlStringVideoCategoryId = "&videoCategoryId=\(videoTypeDictionary[recordSearchSettings.videoType]!)"
        }
        if recordSearchSettings.type == "playlist" {
            urlStringType = "&part=snippet,contentDetails"
            count = "itemCount"
            part = "contentDetails"
        }else if recordSearchSettings.type == "channel" {
            urlStringType = "&part=snippet,statistics,contentDetails"
            count = "viewCount"
            part = "statistics"
        }else {
            urlStringType = "&part=snippet,statistics"
            count = "viewCount"
            part = "statistics"
        }

        urlString = youtubeNetworkAddress + "\(recordSearchSettings.type!)s?" + urlStringType + "&key=\(apiKey)&regionCode=TW&id=\(id)" + urlStringVideoCategoryId
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            
            if HTTPStatusCode == 200 && error == nil {
                
                do {
                    // 將 JSON 資料轉換成字典
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    // 從傳回的資料中取得第一筆字典記錄（通常也只會有一筆記錄）
                    let items: AnyObject! = resultsDict["items"] as AnyObject!
                    if items.count == 1 {
                        let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>
                    
                        // 取得包含所需資料的 snippet 字典
                        let snippetDict = firstItemDict["snippet"] as! Dictionary<NSObject, AnyObject>
                    
                        // 建立新的字典，只儲存我們想要知道的數值
                        var videoDetailsDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
                        videoDetailsDict["title"] = snippetDict["title"]
                        videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                        videoDetailsDict[count] = (firstItemDict[part] as! Dictionary<NSObject, AnyObject>)[count]
                        
                        if recordSearchSettings.type == "channel" {
                            videoDetailsDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<NSObject, AnyObject>)["relatedPlaylists"] as! Dictionary<NSObject, AnyObject>)["uploads"]
                        }else if recordSearchSettings.type == "playlist" {
                            videoDetailsDict["playlistID"] = id
                        }else {
                            videoDetailsDict["videoID"] = id
                        }
                        
                        
                        self.collectionDataArray[ id ] = videoDetailsDict
                        
                        self.successCount += 1
                        if self.successCount == self.searchSuccessCount {
                            self.endSearch()
                        }
                    }else {
                        self.collectionView.reloadData()
                    }
                    
                } catch {
                    print("Error = \(error)")
                }
                
            } else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
            
        })
    }
    
}