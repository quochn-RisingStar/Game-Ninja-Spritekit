//
//  CGfloat.swift
//  Game
//
//  Created by Nitrotech Asia on 16/04/2024.
//

import Foundation

extension CGFloat {
    func radiansToDegrees() -> CGFloat {
        return self * 180.0 * CGFloat.pi
    }

    func degreesToRadians() -> CGFloat {
        return self *  CGFloat.pi/180.0
    }
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }

    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}
