//
//  CuriosMaskKit+Extension.swift
//  CuriosSwift
//
//  Created by Emiaostein on 9/6/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

extension CuriosMaskKit {
  
  public class func drawXPath(#frame: CGRect) -> UIBezierPath {

    //// Bezier Drawing
    var bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.25672 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.24085 * frame.width, frame.minY + 0.50000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.74322 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.25484 * frame.width, frame.minY + 1.00000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.49985 * frame.width, frame.minY + 0.75721 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.74562 * frame.width, frame.minY + 1.00000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.99999 * frame.width, frame.minY + 0.74527 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.75966 * frame.width, frame.minY + 0.50000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.99999 * frame.width, frame.minY + 0.25871 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.74665 * frame.width, frame.minY + 0.00000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.50203 * frame.width, frame.minY + 0.24852 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.25588 * frame.width, frame.minY + 0.00000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.25672 * frame.height))
    bezierPath.closePath()

    return bezierPath
  }
  
  public class func drawHeartPath(#frame: CGRect) -> UIBezierPath {
    
    //// Bezier Drawing
    var bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPointMake(frame.minX + 0.49110 * frame.width, frame.minY + 0.19249 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.38912 * frame.width, frame.minY + 0.07373 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.49110 * frame.width, frame.minY + 0.19249 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.47053 * frame.width, frame.minY + 0.11861 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.19819 * frame.width, frame.minY + 0.04619 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.30771 * frame.width, frame.minY + 0.02886 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.23890 * frame.width, frame.minY + 0.03702 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.01024 * frame.width, frame.minY + 0.24821 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.15748 * frame.width, frame.minY + 0.05536 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.06369 * frame.width, frame.minY + 0.08482 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.09933 * frame.width, frame.minY + 0.56427 * frame.height), controlPoint1: CGPointMake(frame.minX + -0.03558 * frame.width, frame.minY + 0.42499 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.08650 * frame.width, frame.minY + 0.54907 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.25150 * frame.width, frame.minY + 0.76109 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.11217 * frame.width, frame.minY + 0.57946 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.23299 * frame.width, frame.minY + 0.73244 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.34370 * frame.width, frame.minY + 0.96872 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.28006 * frame.width, frame.minY + 0.80533 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.30260 * frame.width, frame.minY + 0.83655 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.94254 * frame.width, frame.minY + 0.48065 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.41154 * frame.width, frame.minY + 0.93468 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.74589 * frame.width, frame.minY + 0.78658 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.91401 * frame.width, frame.minY + 0.11027 * frame.height), controlPoint1: CGPointMake(frame.minX + 1.00553 * frame.width, frame.minY + 0.33392 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.99957 * frame.width, frame.minY + 0.19062 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.49110 * frame.width, frame.minY + 0.19249 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.83511 * frame.width, frame.minY + 0.02496 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.63670 * frame.width, frame.minY + -0.05996 * frame.height))
    bezierPath.closePath()
    
    return bezierPath
  }
  
  public class func drawPentagramPath(#frame: CGRect) -> UIBezierPath {
    
    //// Star Drawing
    var starPath = UIBezierPath()
    starPath.moveToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.61797 * frame.width, frame.minY + 0.38206 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.38197 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.69087 * frame.width, frame.minY + 0.61800 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.80902 * frame.width, frame.minY + 1.00000 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.76381 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.19098 * frame.width, frame.minY + 1.00000 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.30913 * frame.width, frame.minY + 0.61800 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.38197 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.38203 * frame.width, frame.minY + 0.38206 * frame.height))
    starPath.addLineToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height))
    starPath.closePath()
    
    return starPath
  }
  
  public class func drawPentagonPath(#frame: CGRect) -> UIBezierPath {
    
    //// Polygon Drawing
    var polygonPath = UIBezierPath()
    polygonPath.moveToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.38197 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 0.80902 * frame.width, frame.minY + 1.00000 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 0.19098 * frame.width, frame.minY + 1.00000 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.38197 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height))
    polygonPath.closePath()
    
    return polygonPath
  }
  
  public class func drawCirclePath(#frame: CGRect) -> UIBezierPath {
    
    //// Oval Drawing
    var ovalPath = UIBezierPath(ovalInRect: CGRectMake(frame.minX + floor(frame.width * 0.00000 + 0.5), frame.minY + floor(frame.height * 0.00000 + 0.5), floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5)))
    
    return ovalPath
  }
  
  public class func drawRoundRetanglePath(#frame: CGRect) -> UIBezierPath {
    
    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(roundedRect: CGRectMake(frame.minX + floor(frame.width * 0.00000 + 0.5), frame.minY + floor(frame.height * 0.00000 + 0.5), floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5)), cornerRadius: 22)
    return rectanglePath
  }
  
  public class func drawFanPath(#frame: CGRect) -> UIBezierPath {
    
    //// Bezier Drawing
    var bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.41472 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.29018 * frame.width, frame.minY + 0.99102 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.70759 * frame.width, frame.minY + 1.00000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.29018 * frame.width, frame.minY + 0.99102 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.62657 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.42370 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.84263 * frame.width, frame.minY + 0.73968 * frame.height), controlPoint2: CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.42370 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.50173 * frame.width, frame.minY + 0.00000 * frame.height), controlPoint1: CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.42370 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.80704 * frame.width, frame.minY + 0.00000 * frame.height))
    bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.41472 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.19643 * frame.width, frame.minY + 0.00000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.01339 * frame.width, frame.minY + 0.37702 * frame.height))
    bezierPath.closePath()
    
    return bezierPath
  }
  
  public class func drawTrianglePath(#frame: CGRect) -> UIBezierPath {
    
    //// Polygon Drawing
    var polygonPath = UIBezierPath()
    polygonPath.moveToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 1.00000 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 1.00000 * frame.height))
    polygonPath.addLineToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height))
    polygonPath.closePath()
    
    return polygonPath
  }
  
  public class func drawDiamondPath(#frame: CGRect) -> UIBezierPath {
    
    //// Bezier Drawing
    var bezierPath = UIBezierPath()
    bezierPath.moveToPoint(CGPointMake(frame.minX + 0.49436 * frame.width, frame.minY + 0.00000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.50122 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.49050 * frame.width, frame.minY + 1.00000 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.49904 * frame.height))
    bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.49436 * frame.width, frame.minY + 0.00000 * frame.height))
    bezierPath.closePath()
    
    return bezierPath
  }
  
}