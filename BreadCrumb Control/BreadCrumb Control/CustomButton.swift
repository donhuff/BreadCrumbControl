//
//  CustomButton.swift
//  BreadCrumb-Swift
//
//  Created by Philippe K on 14/11/2015. All rights reserved.
//  Copyright © 2015
//

import Foundation
import UIKit


enum StyleButton {
    case simpleButton
    case extendButton
}


class MyCustomButton: UIButton {

    required init?(coder aDecoder: (NSCoder!)) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clear
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    
    @IBInspectable var styleButton: StyleButton = .extendButton {
        didSet{
            draw( self.frame)
        }
    }
    
    @IBInspectable var arrowColor: UIColor = UIColor.white {
        didSet{
            draw( self.frame)
        }
    }
    
    @IBInspectable var backgroundCustomColor: UIColor = UIColor.gray {
        didSet{
            draw( self.frame)
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ frame: CGRect)
    {
        if (styleButton == .extendButton) {
            //// Bezier Drawing
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: frame.maxX - 10, y: frame.minY))
            bezierPath.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + 0.50000 * frame.height))
            bezierPath.addLine(to: CGPoint(x: frame.maxX - 10, y: frame.maxY))
            bezierPath.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
            bezierPath.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
            bezierPath.addLine(to: CGPoint(x: frame.maxX - 10, y: frame.minY))
            bezierPath.close()
            //UIColor.lightGrayColor().setFill()
            self.backgroundCustomColor.setFill()
            bezierPath.fill()
        } else {
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath(rect: CGRect(x: frame.minX, y: frame.minY, width: frame.maxX, height: frame.maxY))
            self.backgroundCustomColor.setFill()
            rectanglePath.fill()

            //// Bezier 2 Drawing
            let bezier2Path = UIBezierPath()
            //bezier2Path.moveToPoint(CGPointMake(frame.minX + 0.95000 * frame.width, frame.minY + 5))
            //bezier2Path.addLineToPoint(CGPointMake(frame.maxX-2, frame.minY + 0.50000 * frame.height))
            //bezier2Path.addLineToPoint(CGPointMake(frame.minX + 0.95000 * frame.width, frame.maxY - 5))
            bezier2Path.move(to: CGPoint(x: frame.maxX - 11 , y: frame.minY + 8))
            bezier2Path.addLine(to: CGPoint(x: frame.maxX - 2, y: frame.minY + 0.50000 * frame.height))
            bezier2Path.addLine(to: CGPoint(x: frame.maxX - 11, y: frame.maxY - 8))
            bezier2Path.lineCapStyle = .round;
            
            self.arrowColor.setStroke()
            bezier2Path.lineWidth = 2
            bezier2Path.stroke()

        }
    }
}
