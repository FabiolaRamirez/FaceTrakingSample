//
//  DrawingUtility.swift
//  FaceTrackingSample
//
//  Created by Fabiola Ramirez on 3/11/17.
//  Copyright © 2017 Fabiola Ramirez. All rights reserved.
//

import Foundation
import UIKit

class DrawingUtility {
    class func addCircle(at point: CGPoint, to view: UIView, with color: UIColor, withRadius width: Int) {
        let circleRect = CGRect(x: point.x - CGFloat(width) / 2, y: CGFloat(point.y - CGFloat(width) / 2), width: CGFloat(width), height: CGFloat(width))
        let circleView = UIView(frame: circleRect)
        circleView.layer.cornerRadius = CGFloat(width) / 2
        circleView.alpha = 0.7
        circleView.backgroundColor = color
        view.addSubview(circleView)
    }
    
    class func addRectangle(_ rect: CGRect, to view: UIView, with color: UIColor) {
        let newView = UIView(frame: rect)
        newView.layer.cornerRadius = 10
        newView.alpha = 0.3
        newView.backgroundColor = color
        view.addSubview(newView)
    }
    
    class func addTextLabel(_ text: String, at rect: CGRect, to view: UIView, with color: UIColor) {
        let label = UILabel(frame: rect)
        label.textColor = color
        label.text = text
        view.addSubview(label)
    }
    
    class func addMostacho(at point: CGPoint, to view: UIView, withRadius width: Int) {
        let circleRect = CGRect(x: point.x - CGFloat(width) / 2, y: CGFloat(point.y - CGFloat(width) / 2 + 40), width: CGFloat(width), height: CGFloat(width))
        let imageView = UIImageView(frame: circleRect)
        imageView.image = UIImage (named: "mostacho2")
        imageView.alpha = 1
        view.addSubview(imageView)
    }
    
}
