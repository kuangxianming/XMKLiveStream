//
//  LiveFansViewController.swift
//  LiveStreamingDemo
//
//  Created by amin.kuang on 2018/8/10.
//  Copyright © 2018年 amin.kuang. All rights reserved.
//

import UIKit
import IJKMediaFramework
import SocketIO

class LiveFansViewController: UIViewController {

    var player: IJKFFMoviePlayerController?
    var manager: SocketManager!
    var socket: SocketIOClient!
    var liveIMView: LiveIMView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "观众健壮的犀牛"
        startPlayer()
        
        liveIMView = LiveIMView()
        liveIMView.frame = view.bounds
        view.insertSubview(liveIMView, at: 1)
        
        if let url = URL.init(string: webURL) {
            
            manager = SocketManager(socketURL: url, config: [.log(true), .compress])
            
            socket = manager.defaultSocket
            
            socket.on(clientEvent: .connect, callback: { data, ack in
                print("建立socket连接")
                //给服务器发送消息事件
                self.liveIMView.msgHandler = { message in
                    
                    self.socket.emit("msg", with: [message])
                    
                }
                //给服务器发送礼物事件
                self.liveIMView.giftHandler = { giftMsg in
                    
                    self.socket.emit("gift", with: [giftMsg])
                    
                }
               
            })
            
            //监听服务器发过来的事件
            socket.on("chat", callback: { (data, ack) in
                print("chat事件\(data.first!)")
                let msg = data.first! as? String
                self.liveIMView.messageArray.append(msg!)
            })
            
            socket.on("sendGift", callback: { (data, ack) in
                let giftMsg = data.first as? String
                self.liveIMView.giftMsg = giftMsg
            })
            
            socket.connect()
        }
        
        
    }
    
    
    func startPlayer() {
        
        if let url = URL.init(string: pullRtmpURL) {
            
            player = IJKFFMoviePlayerController(contentURL: url, with: nil)
            
            player?.view.frame = view.bounds
            player?.scalingMode = IJKMPMovieScalingMode.aspectFit
            player?.shouldAutoplay = true
            
            view.autoresizesSubviews = true
            view.addSubview((player?.view)!)
            player?.prepareToPlay()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        player?.stop()
    }

    
}
