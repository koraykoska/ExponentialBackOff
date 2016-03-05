//
//  Random.swift
//  ExponentialBackOff
//
//  Created by Koray Koska on 05/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation

struct Random {
	static func within<B: protocol<Comparable, ForwardIndexType>>(range: ClosedInterval<B>) -> B {
		let inclusiveDistance = range.start.distanceTo(range.end).successor()
		let randomAdvance = B.Distance(arc4random_uniform(UInt32(inclusiveDistance.toIntMax())).toIntMax())
		return range.start.advancedBy(randomAdvance)
	}

	static func within(range: ClosedInterval<Float>) -> Float {
		return (range.end - range.start) * Float(Float(arc4random()) / Float(UInt32.max)) + range.start
	}

	static func within(range: ClosedInterval<Double>) -> Double {
		return (range.end - range.start) * Double(Double(arc4random()) / Double(UInt32.max)) + range.start
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
