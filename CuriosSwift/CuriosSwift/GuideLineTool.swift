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
  
 class func check(rect: CGRect, acheckPoints: [CGPoint]) -> CGRect {
    
    let targetRect = CGRectInset(rect, -0, -0)
    let targetDistance: CGFloat = 2.0
    var x = CGRectGetMinX(rect)
    var y = CGRectGetMinY(rect)
    
    let top_left = CGPoint(x: targetRect.minX, y: targetRect.minY)
    let top_right = CGPoint(x: targetRect.maxX, y: targetRect.minY)
    let bottom_left = CGPoint(x: targetRect.minX, y: targetRect.maxY)
    let bottom_right = CGPoint(x: targetRect.maxX, y: targetRect.maxY)
    let center = CGPoint(x: targetRect.midX, y: targetRect.midY)
    
    let aPoints = [
      top_left,
      top_right,
      bottom_left,
      bottom_right,
      center
    ]
  
  for aPoint in aPoints {
    for bPoint in acheckPoints {
      
      if circle(targetDistance, aPoint)(bPoint) {
        let dx = bPoint.x - aPoint.x
        let dy = bPoint.y - aPoint.y
        x += dx
        y += dy
        return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
      }
    }
  }
  
    
    for aPoint in aPoints {
      for bPoint in acheckPoints {
        let dx = bPoint.x - aPoint.x
        let dy = bPoint.y - aPoint.y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        let distanceX = fabs(dx)
        let distanceY = fabs(dy)
        
//        debugPrint.p("disX = \(distanceX), disY = \(distanceY)")
//        if distance <= targetDistance * sqrt(2) {
//          x += dx
//          y += dy
//          return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
//        }
        
        if distanceX <= targetDistance {
          x += dx
          return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
        }
        
        if distanceY <= targetDistance {
          y += dy
          return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
        }
        
//        return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
      }
    }
    return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
//    for checkedRect in checkedRects {
//      
//      let top_left = CGPoint(x: checkedRect.minX, y: checkedRect.minY)
//      let top_right = CGPoint(x: checkedRect.maxX, y: checkedRect.minY)
//      let bottom_left = CGPoint(x: checkedRect.minX, y: checkedRect.maxY)
//      let bottom_right = CGPoint(x: checkedRect.maxY, y: checkedRect.maxY)
//      let center = CGPoint(x: checkedRect.midX, y: checkedRect.midY)
//      
//      let bPoints = [
//        top_left,
//        top_right,
//        bottom_left,
//        bottom_right,
//        center
//      ]
//      
//      for aPoint in aPoints {
//        for bPoint in bPoints {
//          let dx = bPoint.x - aPoint.x
//          let dy = bPoint.y - aPoint.y
//          let distance = sqrt(pow(dx, 2) + pow(dy, 2))
//          let distanceX = fabs(dx)
//          let distanceY = fabs(dy)
//          if distance <= targetDistance * sqrt(2) {
//            x += dx
//            y += dy
//            return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
//          } else if distanceX <= targetDistance {
//            x += dx
//            return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
//          } else if distanceY <= targetDistance {
//            y += dy
//            return CGRect(origin: CGPoint(x: x, y: y), size: rect.size)
//          }
//        }
//      }
//    }
  
  }

  
  class func checkPoints(frame: CGRect) -> [CGPoint] {
    
    let height = frame.height
    let width = frame.width
    
    let hor = 3
    let ver = 3
    
    let horGap = 1.0 / CGFloat(hor + 1)
    let verGap = 1.0 / CGFloat(ver + 1)
    
    //    let horCen: CGFloat = 0.5
    //    let verCen: CGFloat = 0.5
    
    var guideLines = [CGPoint]()
    
    for i in 0...(hor + 1) {
      for j in 0...(ver + 1) {
        
        let point = CGPoint(x: frame.minX + verGap * CGFloat(j) * width , y: frame.minY + horGap * CGFloat(i) * height)
        guideLines.append(point)
      }
    }
    
    //    let center = CGPoint(x: horCen * width , y: verCen * height)
    //    guideLines.append(center)
    
    return guideLines
  }
  
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
        
        let bezierPath = UIBezierPath()
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
    let ver = 3
    
    let horGap = 1.0 / CGFloat(hor + 1)
    let verGap = 1.0 / CGFloat(ver + 1)
    
    var guideLines = [GuideLine]()
    for i in 1...hor {
      let begainPoint = CGPoint(x: 0, y: horGap * CGFloat(i))
      let endPoint = CGPoint(x: 1, y: horGap * CGFloat(i))
      let guideLine = GuideLine(lineWidth: 0.5, pattern: i % 2 == 0 ? .Dash : .Solid, color: (0.59, 0.59, 0.59, 1.0), points: [begainPoint, endPoint])
      guideLines.append(guideLine)
    }
    
    for i in 1...ver {
      let begainPoint = CGPoint(x: verGap * CGFloat(i), y: 0)
      let endPoint = CGPoint(x: verGap * CGFloat(i), y: 1)
      let guideLine = GuideLine(lineWidth: 0.5, pattern: i % 2 == 0 ? .Dash : .Solid , color: (0.59, 0.59, 0.59, 1.0), points: [begainPoint, endPoint])
      guideLines.append(guideLine)
    }
    
    //    let vbp = CGPoint(x: 0.5, y: 0)
    //    let vep = CGPoint(x: 0.5, y: 1)
    //    let vg = GuideLine(lineWidth: 0.5, pattern: .Dash, color: (0.59, 0.59, 0.59, 1.0), points: [vbp, vep])
    //
    //    let hbp = CGPoint(x: 0, y: 0.5)
    //    let hep = CGPoint(x: 1, y: 0.5)
    //    let hg = GuideLine(lineWidth: 0.5, pattern: .Dash, color: (0.59, 0.59, 0.59, 1.0), points: [hbp, hep])
    //
    //    guideLines.append(vg)
    //    guideLines.append(hg)
    
    for line in guideLines {
      line.createAtFrame(frame)
    }
  }
}