//
//  ExponentialBackoff.swift
//  Walk
//
//  Created by Koray Koska on 03/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation
import Async

open class ExponentialBackOff {

	open static let sharedInstance = ExponentialBackOff()

	fileprivate init() {
	}

	/**
	 Stores all BackOffAlgorithms which you can restart or stop manually
	 */
	open fileprivate(set) var allBackOffInstances = [BackOffAlgorithm]()

	/**
	 Starts the given BackOffAlgorithm with the given closure as the code to run. The closure should always run `codeToRunAfterFinishedExecuting(success:)` when finished in order for the BackOffInstance to know what to do next

	 You should always call this method to start an instance.

	 Example:
	 ---

	 ```
	 let builder = ExponentialBackOffInstance.Builder()
	 let exponentialBackOff = ExponentialBackOffInstance(builder: builder)

	 ExponentialBackOff.sharedInstance.runGeneralBackOff(exponentialBackOff) {
	 ....(lastIntervallMillis, elapsedTimeMillis, codeToRunAfterFinishedExecuting) in

	 ....Async.background {
	 ........var number: Int = 0
	 ........for i in 1 ... 10000 {
	 ............number = number + i
	 ........}
	 ........Async.main {
	 ............print(number)
	 ............print("lastIntervallMillis: \(lastIntervallMillis)")
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
	open func runGeneralBackOff(_ backOff: BackOffAlgorithm, codeToRun: @escaping (_ lastIntervallMillis: Int, _ elapsedTimeMillis: Int, _ codeToRunAfterFinishedExecuting: @escaping (_ success: Bool) -> BackOffState) -> Void) {

		let backOffClosure: () -> BackOff = {

            class BackOffInstance: BackOff {

				let code: (_ lastIntervallMillis: Int, _ elapsedTimeMillis: Int, _ codeToRunAfterFinishedExecuting: @escaping (_ success: Bool) -> BackOffState) -> Void

				init(code: @escaping (_ lastIntervallMillis: Int, _ elapsedTimeMillis: Int, _ codeToRunAfterFinishedExecuting: @escaping (_ success: Bool) -> BackOffState) -> Void) {
					self.code = code
				}
                
                public func run(_ lastIntervallMillis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: @escaping (Bool) -> BackOffState) {
                    self.code(lastIntervallMillis, elapsedTimeMillis) { success in
                        codeToRunAfterFinishedExecuting(success)
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

	/**
	 If you want to pass a custom class instead of a closure you can implement `BackOff` to your class and use this method instead of `runGeneralBackOff(backOff:codeToRun:)`
	 */
	open func runGeneralBackOff(_ backOff: BackOffAlgorithm, backOffProtocolToRun: BackOff) {

		Async.background {
			backOff.algorithm(backOffProtocolToRun)
		}

		allBackOffInstances.append(backOff)
	}
}
