//
//  ViewController.swift
//  QRCode
//
//  Created by pgq on 2018/3/8.
//  Copyright © 2018年 pgq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func scanBtnClick(_ sender: Any) {
        let controller = PQScanQRCodeController(nibName: "PQScanQRCodeController", bundle: nil)
        navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func crateBtnClick(_ sender: Any) {
        let controller = PQCreateQRCodeController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

