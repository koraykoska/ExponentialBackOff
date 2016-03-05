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

	 func run(lastIntervallMilis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: (success: Bool) -> BackOffState) {
	 Async.background {
	 var number: Int = 0
	 for i in 1 ... 10000 {
	 number = number + i
	 }
	 Async.main {
	 print(number)
	 print("lastIntervallMillis: \(lastIntervallMilis)")
	 print("elapsedTimeMillis: \(elapsedTimeMillis)")
	 if number != 100 {
	 codeToRunAfterFinishedExecuting(success: false)
	 } else {
	 codeToRunAfterFinishedExecuting(success: true)
	 }
	 }
	 }
	 }
	 }*/

	// Define the closure which will be passed to the exponential backoff algorithm
	let code: (lastIntervallMilis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: (success: Bool) -> BackOffState) -> Void = { (lastIntervallMilis, elapsedTimeMillis, codeToRunAfterFinishedExecuting) in
		Async.background {
			var number: Int = 0
			for i in 1 ... 10000 {
				number = number + i
			}
			Async.main {
				print(number)
				print("lastIntervallMillis: \(lastIntervallMilis)")
				print("elapsedTimeMillis: \(elapsedTimeMillis)")
				if number != 100 {
					codeToRunAfterFinishedExecuting(success: false)
				} else {
					codeToRunAfterFinishedExecuting(success: true)
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
