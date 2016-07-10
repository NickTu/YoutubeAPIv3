//
//  LivePlayViewController.swift
//  YoutubeAPIv3
//
//  Created by 涂安廷 on 2016/7/3.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

import UIKit

import UIKit

class LivePlayViewController: UIViewController,YTPlayerViewDelegate {
    
    @IBAction func backViewController(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    var videoLiveID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("videoLiveID = \(videoLiveID)")
        playerView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        /* playsinline: 是否在全屏模式下播放
         
         */
        let parater = ["playsinline":1]
        playerView.loadWithVideoId(videoLiveID,playerVars: parater)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        print("playerViewDidBecomeReady")
        playerView.playVideo()
    }
    
    func playerView(playerView: YTPlayerView, didPlayTime playTime: Float) {
        //print("playerView didPlayTime")
    }
    
    func playerView(playerView: YTPlayerView, receivedError error: YTPlayerError) {
        //print("playerView receivedError")
    }
    
    func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
        //print("playerView didChangeToState")
    }
    
    func playerView(playerView: YTPlayerView, didChangeToQuality quality: YTPlaybackQuality) {
        //print("playerView didChangeToQuality")
    }
    
}