//
//  LiveAnchorViewController.swift
//  LiveStreamingDemo
//
//  Created by amin.kuang on 2018/8/10.
//  Copyright © 2018年 amin.kuang. All rights reserved.
//

import UIKit
import LFLiveKit
import SocketIO

class LiveAnchorViewController: UIViewController {
   
    var liveIMView: LiveIMView!
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    lazy var session: LFLiveSession = {
        
        let audioConfig = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.low)
        let videoConfig = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low1)
        let session = LFLiveSession(audioConfiguration: audioConfig, videoConfiguration: videoConfig)
        return session!
    }()
    
    lazy var switchCameraBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "camera_switch"), for: .normal)
        btn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "主播陈一发儿"
        setupSession()
        startLive()
        
        liveIMView = LiveIMView()
        liveIMView.frame = view.bounds
        liveIMView.hideSendGift = true
        view.addSubview(liveIMView)
        
        view.addSubview(switchCameraBtn)
        switchCameraBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(70)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        switchCameraBtn.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        
        if let url = URL.init(string: webURL) {
            
            manager = SocketManager(socketURL: url, config: [.log(true), .compress])
            
            socket = manager.defaultSocket
            
            socket.on(clientEvent: .connect, callback: { data, ack in
                print("建立socket连接")
                //给服务器发送事件
                self.liveIMView.msgHandler = { message in
                    
                    self.socket.emit("msg", with: [message])
                    
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
    
    func setupSession() {
        let sessionView = UIView()
        sessionView.frame = self.view.bounds
        view.addSubview(sessionView)
        
        session.reconnectInterval = 20
        session.reconnectCount = 10
        session.running = true
        session.showDebugInfo = true
        session.delegate = self
        session.preView = sessionView
        //闪光灯开关
        session.torch = false
        //静音开关
        session.muted = false
    }
    
    //开始推流
    func startLive() {
        let stream = LFLiveStreamInfo()
        stream.url = pushRtmpURL
        session.startLive(stream)
        
    }
    //停止推流
    func stopLive() {
        session.stopLive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.running = false
        stopLive()
    }
    
    //切换摄像头
    @objc func switchCamera() {
        
        session.captureDevicePosition = session.captureDevicePosition == AVCaptureDevice.Position.back ?.front:.back
    }

}

extension LiveAnchorViewController: LFLiveSessionDelegate
{
    /** live status changed will callback */
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        print("state-\(state.rawValue)")
    }
    
    /** callback socket errorcode */
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("errorCode:\(errorCode)")
    }
    
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        /*
         @property (nonatomic, copy) NSString *streamId;                         ///< 流id
         @property (nonatomic, copy) NSString *uploadUrl;                        ///< 流地址
         @property (nonatomic, assign) CGSize videoSize;                         ///< 上传的分辨率
         @property (nonatomic, assign) BOOL isRtmp;                              ///< 上传方式（TCP or RTMP）
         
         @property (nonatomic, assign) CGFloat elapsedMilli;                     ///< 距离上次统计的时间 单位ms
         @property (nonatomic, assign) CGFloat timeStamp;                        ///< 当前的时间戳，从而计算1s内数据
         @property (nonatomic, assign) CGFloat dataFlow;                         ///< 总流量
         @property (nonatomic, assign) CGFloat bandwidth;                        ///< 1s内总带宽
         @property (nonatomic, assign) CGFloat currentBandwidth;                 ///< 上次的带宽
         
         @property (nonatomic, assign) NSInteger dropFrame;                      ///< 丢掉的帧数
         @property (nonatomic, assign) NSInteger totalFrame;                     ///< 总帧数
         
         @property (nonatomic, assign) NSInteger capturedAudioCount;             ///< 1s内音频捕获个数
         @property (nonatomic, assign) NSInteger capturedVideoCount;             ///< 1s内视频捕获个数
         @property (nonatomic, assign) NSInteger currentCapturedAudioCount;      ///< 上次的音频捕获个数
         @property (nonatomic, assign) NSInteger currentCapturedVideoCount;      ///< 上次的视频捕获个数
         
         @property (nonatomic, assign) NSInteger unSendCount;                    ///< 未发送个数（代表当前缓冲区等待发送的）
         */

    }
}
