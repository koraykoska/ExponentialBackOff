//
//  Random.swift
//  ExponentialBackOff
//
//  Created by Koray Koska on 05/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation

struct Random {
    
    static func within(_ range: ClosedRange<Int>) -> Int {
        var offset = 0
        
        if range.lowerBound < 0 {
            offset = abs(range.lowerBound)
        }
        
        let mini = UInt32(range.lowerBound + offset)
        let maxi = UInt32(range.upperBound + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }

	static func within(_ range: ClosedRange<Float>) -> Float {
		return (range.upperBound - range.lowerBound) * Float(Float(arc4random()) / Float(UInt32.max)) + range.lowerBound
	}

	static func within(_ range: ClosedRange<Double>) -> Double {
		return (range.upperBound - range.lowerBound) * Double(Double(arc4random()) / Double(UInt32.max)) + range.lowerBound
	}

	static func generate() -> Int {
		return Random.within(0 ... 1)
	}

	static func generate() -> Bool {
		return Random.generate() == 0
	}

	static func generate() -> Float {
		return Random.within(0.0 ... 1.0)
	}

	static func generate() -> Double {
		return Random.within(0.0 ... 1.0)
	}
}
