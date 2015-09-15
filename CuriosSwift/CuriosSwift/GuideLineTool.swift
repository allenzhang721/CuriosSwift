//
//  GuideLineTool.swift
//  guideLineDemo
//
//  Created by Emiaostein on 9/15/15.
//  Copyright (c) 2015 BoTai Technology. All rights reserved.
//

import Foundation
import UIKit

 class GuideLineTool {
  
 class func drawGuideLine(frame: CGRect) {
    
    struct GuideLine {
      
      enum GuideLinePattern {
        
        case Solid, Dash
      }
      
      let lineWidth: CGFloat
      let pattern: GuideLinePattern
      let color: (CGFloat, CGFloat, CGFloat, CGFloat)// rgba
      let points: [CGPoint] // began, end
      
      func createAtFrame(frame: CGRect) -> UIBezierPath {
        
        let context = UIGraphicsGetCurrentContext()
        
        let aPoints = points.map { point -> CGPoint in
          let po = CGPoint(x: frame.minX + frame.width * point.x, y: frame.minY + frame.height * point.y)
          return po
        }
        
        var bezierPath = UIBezierPath()
        for (index, point) in enumerate(aPoints) {
          index == 0 ? bezierPath.moveToPoint(point) : bezierPath.addLineToPoint(point)
        }
        
        let strokeColor = UIColor(red: color.0, green: color.1, blue: color.2, alpha: color.3)
        strokeColor.setStroke()
        bezierPath.lineWidth = lineWidth
        CGContextSaveGState(context)
        if pattern == .Dash {
          
          CGContextSetLineDash(context, 5, [5, 5], 2)
          
          
        }
        bezierPath.stroke()
        CGContextRestoreGState(context)
        return bezierPath
      }
    }
    
    let frame = frame
    
    let hor = 3
    let ver = 5
    
    let horGap = 1.0 / CGFloat(hor + 1)
    let verGap = 1.0 / CGFloat(ver + 1)
    
    var guideLines = [GuideLine]()
    for i in 1...hor {
      let begainPoint = CGPoint(x: 0, y: horGap * CGFloat(i))
      let endPoint = CGPoint(x: 1, y: horGap * CGFloat(i))
      let guideLine = GuideLine(lineWidth: 0.5, pattern: .Solid, color: (0.59, 0.59, 0.59, 1.0), points: [begainPoint, endPoint])
      guideLines.append(guideLine)
    }
    
    for i in 1...ver {
      let begainPoint = CGPoint(x: verGap * CGFloat(i), y: 0)
      let endPoint = CGPoint(x: verGap * CGFloat(i), y: 1)
      let guideLine = GuideLine(lineWidth: 0.5, pattern: i % 2 > 0 ? .Dash : .Solid , color: (0.59, 0.59, 0.59, 1.0), points: [begainPoint, endPoint])
      guideLines.append(guideLine)
    }
    
    for line in guideLines {
      let path = line.createAtFrame(frame)
    }
  }
}