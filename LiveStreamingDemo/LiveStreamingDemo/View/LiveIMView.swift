//
//  LiveIMView.swift
//  LiveStreamingDemo
//
//  Created by amin.kuang on 2018/8/22.
//  Copyright © 2018年 amin.kuang. All rights reserved.
//

import UIKit
import Lottie

class LiveIMView: UIView {

    let cellID = "LiveIMCell"
    var message: String?
    var messageArray = [String]() {
        didSet{
            msgView.reloadData()
            let indexPath = IndexPath(row: messageArray.count - 1, section: 0)
            msgView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    var giftMsg: String? {
        didSet{
            playGiftAnimation(giftMsg)
        }
    }
    
    
    var hideSendGift = false {
        didSet{
            sendGiftBtn.isHidden = hideSendGift
        }
    }

    typealias sendMsgHandler = (String)->()
    var msgHandler: sendMsgHandler?
    var giftHandler: sendMsgHandler?
    
    enum giftMessage: String {
        case hongbao = "hongbao"
    }
    
    lazy var msgView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    lazy var msgTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = UIColor.darkGray
        textField.borderStyle = UITextBorderStyle.none
        textField.backgroundColor = .clear
        textField.returnKeyType = UIReturnKeyType.send
        textField.layer.cornerRadius = 15.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.masksToBounds = true
        return textField
    }()
    
    lazy var sendGiftBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gift"), for: .normal)
        btn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        return btn
        
    }()
    
    lazy var giftAnimationView: LOTAnimationView = {
        let animationView: LOTAnimationView = LOTAnimationView()
        animationView.contentMode = .scaleAspectFit
        return animationView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(msgView)
        msgView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        addSubview(msgTextField)
        msgTextField.delegate = self
        
        addSubview(sendGiftBtn)
        sendGiftBtn.addTarget(self, action: #selector(sendGift(_:)), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        msgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(160)
        }
        
        msgTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-150)
            make.top.equalTo(msgView.snp.bottom)
            make.height.equalTo(30)
        }
        
        sendGiftBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(msgTextField.snp.bottom)
            make.left.equalTo(msgTextField.snp.right).offset(15)
            make.width.equalTo(50)
            make.height.equalTo(35)
        }
        
    }
    
    func playGiftAnimation(_ giftMsg: String?) {
        if !subviews.contains(giftAnimationView){
            addSubview(giftAnimationView)
            giftAnimationView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(15)
                make.bottom.equalTo(msgView.snp.top).offset(-15)
            }
        }
        giftAnimationView.alpha = 1.0
        
        if let msg = giftMsg, msg == giftMessage.hongbao.rawValue {
            giftAnimationView.setAnimation(named: "red_pocket_pop_up")
        }
        giftAnimationView.play()
        giftAnimationView.completionBlock = { finished in
            UIView.animate(withDuration: 1.25, animations: { [weak self] in
                self?.giftAnimationView.alpha = 0.0
            })
        }
    }
    
    @objc func sendGift(_ sender: UIButton) {
        
        giftHandler?(giftMessage.hongbao.rawValue)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        endEditing(true)
    }

}

extension LiveIMView: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)!
        let msg = messageArray[indexPath.row] as String
        
        cell.textLabel?.text = msg
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.textColor = .orange
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
    }
    
}

extension LiveIMView: UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        message = textField.text
        guard message != nil else {return true}
        msgHandler?(message!)
        return true
    }
}
