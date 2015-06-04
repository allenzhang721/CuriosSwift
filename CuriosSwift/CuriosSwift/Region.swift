//
//  Region.swift
//  controlPannel
//
//  Created by Emiaostein on 6/2/15.
//  Copyright (c) 2015 BoTai Technology. All rights reserved.
//

import Foundation
import UIKit

typealias Postion = CGPoint
typealias Distance = CGFloat
typealias Size = CGSize
typealias Region = Postion -> Bool

func circle(radius: Distance, center: Postion) -> Region {
    
    return { point in
        let transition = CGPointMake(point.x - center.x, point.y - center.y)
        return sqrt(transition.x * transition.x + transition.y * transition.y) <= radius
    }
}

func retangle(size: Size, center: Postion) -> Region {
    
    return { point in
        let x = center.x - size.width / 2.0
        let y = center.y - size.height / 2.0
        let rect = CGRectMake(x, y, size.width, size.height)
        return CGRectContainsPoint(rect, point)
    }
}

func invert(region: Region) -> Region {
    return { point in
        return !region(point)
    }
}

func union(region1: Region, region2: Region) -> Region {
    
    return { point in
        return region1(point) || region2(point)
    }
}

func interSection(region1: Region, region2: Region) -> Region {
    
    return { point in
        return region1(point) && region2(point)
    }
}

func difference(region: Region, minusRegion: Region) -> Region {
    
    return { point in
        return interSection(region, invert(minusRegion))(point)
    }
}