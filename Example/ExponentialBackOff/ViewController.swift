//
//  ViewController.swift
//  ExponentialBackOff
//
//  Created by Ybrin on 03/04/2016.
//  Copyright (c) 2016 Ybrin. All rights reserved.
//

import UIKit
import ExponentialBackOff
import Async

class ViewController: UIViewController {

	var exponentialBackOff: ExponentialBackOffInstance!

	/*class TestBackOff: BackOff {

	 func run(lastIntervallMillis: Int, elapsedTimeMillis: Int, completion: (success: Bool) -> BackOffState) {
	 Async.background {
	 var number: Int = 0
	 for i in 1 ... 10000 {
	 number = number + i
	 }
	 Async.main {
	 print(number)
	 print("lastIntervallMillis: \(lastIntervallMillis)")
	 print("elapsedTimeMillis: \(elapsedTimeMillis)")
	 if number != 100 {
	 completion(success: false)
	 } else {
	 completion(success: true)
	 }
	 }
	 }
	 }
	 }*/

	// Define the closure which will be passed to the exponential backoff algorithm
	let code: (_ lastIntervallMillis: Int, _ elapsedTimeMillis: Int, _ completion: @escaping (_ success: Bool) -> BackOffState) -> Void = { (lastIntervallMillis, elapsedTimeMillis, completion) in
		Async.background {
			var number: Int = 0
            for i in 1 ... 10000 {
				number = number + i
			}
			Async.main {
				print(number)
				print("lastIntervallMillis: \(lastIntervallMillis)")
				print("elapsedTimeMillis: \(elapsedTimeMillis)")
				if number != 100 {
					_ = completion(false)
				} else {
                    _ = completion(true)
				}
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		testAlgorithm()
	}

	// Test the algorithm
	func testAlgorithm() {
		let builder = ExponentialBackOffInstance.Builder()
		builder.initialIntervalMillis = 2
		builder.maxElapsedTimeMillis = 10000
		builder.randomizationFactor = 0.0
		builder.multiplier = 2.0

		self.exponentialBackOff = ExponentialBackOffInstance(builder: builder)
		/*
		 self.exponentialBackOff.algorithm(TestBackOff())*/

		ExponentialBackOff.sharedInstance.runGeneralBackOff(exponentialBackOff, codeToRun: code)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
