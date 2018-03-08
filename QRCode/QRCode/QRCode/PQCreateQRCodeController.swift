//
//  PQCreateQRCodeController.swift
//  Swift4
//
//  Created by pgq on 2018/3/8.
//  Copyright © 2018年 pgq. All rights reserved.
//

import UIKit
import AssetsLibrary


class PQCreateQRCodeController: UIViewController {

    private var qrCodeData: String = "在二维码中如果遮挡一部分的二维码是不会造成识别不了的情况的，但是一定要注意不能把三个小正方形给遮挡住，因为那是二维码的入口，通过三个小正方形才能开始"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(qrCodeImageView)
        qrCodeImageView.image = createQRCode()
        
    }

    
    //*********************   私有方法  ***************
    
    private lazy var qrCodeImageView: UIImageView = {
        let view = UIImageView()
        view.frame.size = CGSize(width: 300, height: 300)
        view.center = self.view.center
        let tap = UITapGestureRecognizer(target: self, action: #selector(saveImage))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc private func saveImage(){
        guard let image = qrCodeImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func createQRCode() -> UIImage{
        let bgImage = myQrcodeImage(500, nil, nil)
        
        // 5、创建头像
        let icon = UIImage(named: "headIcon")
        
        // 6、合并图片
        return mergeImageWith(bgImage: bgImage, foreImage: icon)
        //PS：在二维码中如果遮挡一部分的二维码是不会造成识别不了的情况的，但是一定要注意
        //不能把三个小正方形给遮挡住，因为那是二维码的入口，通过三个小正方形才能开始
    }
    
    //合并图片
    private func mergeImageWith(bgImage:UIImage,foreImage:UIImage?) -> UIImage{
        
        //1、开启上下文
        UIGraphicsBeginImageContext(bgImage.size)
        //2、绘制背景图
        bgImage.draw(in: CGRect(origin: CGPoint.zero, size: bgImage.size))
        //3、绘制前景图
        let width : CGFloat = 80.0
        let height: CGFloat = 80.0
        let x = (bgImage.size.width - width) / 2.0
        let y = (bgImage.size.height - height) / 2.0
        foreImage?.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //4、取得生成好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //5、关闭上下文
        UIGraphicsEndImageContext()
        //6、返回合成图
        return newImage!
    }
    
    
    func myQrcodeImage(_ size : CGFloat? ,_ color : UIColor?, _ bgColor :UIColor?) -> UIImage{
        
        //1、设置缺省值
        var QRCodeSize : CGFloat = 300
        var QRCodeColor : UIColor = UIColor.black
        var QRCodeBgColor : UIColor = UIColor.white
        
        //2、更新缺省值，如果传入了值
        if let size = size { QRCodeSize = size }
        if let color = color { QRCodeColor = color }
        if let bgColor = bgColor { QRCodeBgColor = bgColor }
        
        //3、创建二维码滤镜
        let contentData = qrCodeData.data(using: .utf8)
        let fileter = CIFilter(name: "CIQRCodeGenerator")
        
        //4、设置输入信息
        fileter?.setValue(contentData, forKey: "inputMessage")
        fileter?.setValue("H", forKey: "inputCorrectionLevel")
        
        //5、得到输出二维码
        let ciImage = fileter?.outputImage
        
        //6、设置颜色滤镜
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(ciImage, forKey: "inputImage")
        //二维码颜色
        colorFilter?.setValue(CIColor(cgColor : QRCodeColor.cgColor), forKey: "inputColor0")
        //背景色
        colorFilter?.setValue(CIColor(cgColor : QRCodeBgColor.cgColor), forKey: "inputColor1")
        
        //7、生成二维码
        let outImage = colorFilter!.outputImage!
        let scale = QRCodeSize / outImage.extent.size.width
        
        let transfrom = CGAffineTransform(scaleX: scale, y: scale)
        
        let transfromImage = colorFilter!.outputImage!.transformed(by: transfrom)
        
        let newImage = UIImage(ciImage: transfromImage)
        
        return newImage
    }
}

/*
 /**
 根据CIImage生成指定大小的高清UIImage
 
 :param: image 指定CIImage
 :param: size    指定大小
 :returns: 生成好的图片
 */
 private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
 
 let extent: CGRect = image.extent.integral
 let scale: CGFloat = min(size/extent.width, size/extent.height)
 
 // 1.创建bitmap;
 let width = extent.width * scale
 let height = extent.height * scale
 let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
 let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
 
 let context = CIContext(options: nil)
 let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
 
 bitmapRef.interpolationQuality = CGInterpolationQuality.none
 bitmapRef.scaleBy(x: scale, y: scale);
 
 let ctx = UIGraphicsGetCurrentContext()
 
 ctx?.draw(bitmapImage, in: extent, byTiling: true)
 
 ctx?.draw(bitmapImage, in: extent)
 
 
 UIGraphicsGetImageFromCurrentImageContext()
 
 // 2.保存bitmap到图片
 let scaledImage: CGImage = bitmapRef.makeImage()!
 
 return UIImage(cgImage: scaledImage)
 }
 */
