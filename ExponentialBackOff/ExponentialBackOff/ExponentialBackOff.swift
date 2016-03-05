//
//  ExponentialBackoff.swift
//  Walk
//
//  Created by Koray Koska on 03/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation
import Async

public class ExponentialBackOff {

	public static let sharedInstance = ExponentialBackOff()

	private init() {
	}

	/**
	 Stores all BackOffAlgorithms which you can restart or stop manually
	 */
	public private(set) var allBackOffInstances = [BackOffAlgorithm]()

	/**
	 Starts the given BackOffAlgorithm with the given closure as the code to run. The closure should always run `codeToRunAfterFinishedExecuting(success:)` when finished in order for the BackOffInstance to know what to do next

	 You should always call this method to start an instance.

	 Example:
	 ---

	 ```
	 let builder = ExponentialBackOffInstance.Builder()
	 let exponentialBackOff = ExponentialBackOffInstance(builder: builder)

	 ExponentialBackOff.sharedInstance.runGeneralBackOff(exponentialBackOff) {
	 ....(lastIntervallMilis, elapsedTimeMillis, codeToRunAfterFinishedExecuting) in

	 ....Async.background {
	 ........var number: Int = 0
	 ........for i in 1 ... 10000 {
	 ............number = number + i
	 ........}
	 ........Async.main {
	 ............print(number)
	 ............print("lastIntervallMillis: \(lastIntervallMilis)")
	 ............print("elapsedTimeMillis: \(elapsedTimeMillis)")
	 ............if number != 100 {
	 ................codeToRunAfterFinishedExecuting(success: false)
	 ............} else {
	 ................codeToRunAfterFinishedExecuting(success: true)
	 ............}
	 ........}
	 ....}
	 }
	 ```

	 Due to the fact that this is a singleton, you must call `ExponentialBackOff.sharedInstance` in order to get an instance of `ExponentialBackOff`.
	 */
	public func runGeneralBackOff(backOff: BackOffAlgorithm, codeToRun: (lastIntervallMilis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: (success: Bool) -> BackOffState) -> Void) {

		let backOffClosure: () -> BackOff = {

			class BackOffInstance: BackOff {

				let code: (lastIntervallMilis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: (success: Bool) -> BackOffState) -> Void

				init(code: (lastIntervallMilis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: (success: Bool) -> BackOffState) -> Void) {
					self.code = code
				}

				func run(lastIntervallMilis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: (success: Bool) -> BackOffState) -> Void {
					self.code(lastIntervallMilis: lastIntervallMilis, elapsedTimeMillis: elapsedTimeMillis) { success in
						codeToRunAfterFinishedExecuting(success: success)
					}
				}
			}
			let object = BackOffInstance(code: codeToRun)
			return object
		}

		Async.background {
			backOff.algorithm(backOffClosure())
		}

		allBackOffInstances.append(backOff)
	}
}
