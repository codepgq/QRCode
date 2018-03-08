//
//  PQScanQRCodeController.swift
//  Swift4
//
//  Created by pgq on 2018/3/8.
//  Copyright © 2018年 pgq. All rights reserved.
//

import UIKit
import AVFoundation

class PQScanQRCodeController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var overlayView: UIImageView!
    @IBOutlet var container: UIView!
    @IBOutlet var animatorView: UIImageView!
    @IBOutlet var animator: NSLayoutConstraint!
    @IBOutlet var containerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawLine.addSublayer(lineShapeLayer)
         view.addSubview(infoLabel)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //1、设置开始位置
        animator.constant = -containerHeight.constant
        //1.1更新约束
        view.layoutIfNeeded()
        
        //开始扫描
        startScan()
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawOverlayImage()
    }

    
    // ******************************    所有的私有方法    **************************
    
    private func drawOverlayImage(){
        //画一张纯色图片
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 10), false, UIScreen.main.scale)
        #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.488976227).setFill()
        UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 10))).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //设置透明区域
        UIGraphicsBeginImageContextWithOptions(self.overlayView.bounds.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: self.overlayView.bounds)
        context?.clear(self.container.frame)
        let image2 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        overlayView.image = image2
    }
    
    @IBAction func chiosePictureBtnClick(_ sender: Any) {
        pictureController.delegate = self;
        self.present(pictureController, animated: true, completion: nil)
    }
    
    /**
     开始扫描
     */
    private func startScan(){
        guard let dInput = deviceInput else { return }
        //1、先判断能不能添加输入
        if !session.canAddInput(dInput) {
            return
        }
        //2、在判断能不能添加输出
        if !session.canAddOutput(metaDateOutput) {
            return
        }
        //3、把输入输出添加到会话层中
        session.addInput(dInput)
        session.addOutput(metaDateOutput)
        //4、设置输出能够解析的数据类型
        metaDateOutput.metadataObjectTypes = metaDateOutput.availableMetadataObjectTypes
        //5、设置输出代理，只要解析成功就通知代理
        metaDateOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //6、添加预览图层
        view.layer.insertSublayer(previewLayer, at: 0)
        
        //6.1 添加一个边框图层
        previewLayer.addSublayer(drawLine)
        
        
        
        //6.3设置扫描区域
        let interRect :CGRect = previewLayer.metadataOutputRectConverted(fromLayerRect: CGRect(x: (UIScreen.main.bounds.width - container.frame.width) / 2.0, y: container.frame.origin.y, width: container.frame.width, height: container.frame.height))
        metaDateOutput.rectOfInterest = interRect
        
        //7、开始扫描
        session.startRunning()
        
    }
    
    
    
    
    private func startAnimation(){
        //2、开始动画
        UIView.animate(withDuration: 2, animations: {
            self.animator.constant = self.containerHeight.constant
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
        })
        
    }
    
    
    // ************************     所有的懒加载     **********************
    //会话层
    private lazy var session : AVCaptureSession = AVCaptureSession()
    
    //输入
    private lazy var deviceInput : AVCaptureDeviceInput? = {
        //获取摄像头，才能拿到输入内容
        guard let device = AVCaptureDevice.default(for: .video) else { return nil }
        do{
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch{
            print(error)
            return nil
        }
    }()
    
    //输出
    private lazy var metaDateOutput : AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    // 创建预览图层
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.frame = UIScreen.main.bounds
        layer.videoGravity =  AVLayerVideoGravity.resizeAspectFill
        return layer
    }()
    
    // 创建一个边框图层
    private lazy var drawLine : CALayer = {
        let layer = CALayer()
        layer.frame = UIScreen.main.bounds
        return layer
    }()
    
    //创建一个边框
    lazy var lineShapeLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = UIScreen.main.bounds
        layer.lineWidth = 4
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = nil
        
        return layer
    }()
    
    //相册
    fileprivate let pictureController = UIImagePickerController()
    //选中的相片
    var selectedImage : UIImage?
    
    lazy var infoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 90, width: 300, height: 50))
        label.numberOfLines = 0
        label.text = "dddd"
        label.sizeToFit()
        return label
    }()
}


//代理
extension PQScanQRCodeController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //输出数据
//        print((metadataObjects.last as AnyObject))
        
        lineShapeLayer.path = nil
        
        // 2、去设置二维码的位置
        for object in metadataObjects{
            if object is AVMetadataMachineReadableCodeObject {
                let codeObject = previewLayer.transformedMetadataObject(for: object ) as! AVMetadataMachineReadableCodeObject
                drawConners(codeObject: codeObject)
            }
        }
        
        guard let str:AVMetadataMachineReadableCodeObject  = metadataObjects.last as? AVMetadataMachineReadableCodeObject  else {
            return
        }
        infoLabel.text = str.stringValue
    }
    
    private func drawConners(codeObject: AVMetadataMachineReadableCodeObject){
        //1、如果返回的数据为空，就不用画了
        if codeObject.corners.isEmpty {
            return
        }
        
        //2、创建CAShapeLayer，设置宽度、边框颜色、填充颜色
        //        懒加载实现
        
        //3、设置路径
        let path = UIBezierPath()
        guard let firstPoint = codeObject.corners.first else { return }
        path.move(to: firstPoint)
        codeObject.corners.forEach { (p) in
            path.addLine(to: p)
        }
        //4、关闭路径（绘画）
        path.close()
        
        //4.2、回执路径
        lineShapeLayer.path = path.cgPath
    }
    
    //图片选择器代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage?
        scanQRCode(selectedImage!)
        picker .dismiss(animated: true, completion: nil)
    }
    
    /// 读取图片中的二维码
    func scanQRCode(_ image : UIImage){
        let qrcodeImg =  image
        let ciImage:CIImage = CIImage(image:qrcodeImg)!
        
        let context = CIContext(options: nil)
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode,
                                             context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        
        let features=detector.features(in: ciImage)
        
        //遍历所有的二维码，并框出
        for feature in features as! [CIQRCodeFeature] {
            print(feature.messageString ?? "输错错误")
            infoLabel.text = feature.messageString
        }
    }
    
}

