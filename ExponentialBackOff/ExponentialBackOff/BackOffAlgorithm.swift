//
//  BackOffAlgorithm.swift
//  ExponentialBackOff
//
//  Created by Koray Koska on 04/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation

public protocol BackOffAlgorithm {

	/**
	 This read-only variable indicates which state the BackOffAlgorithm is currently in.

	 - returns: The state in which the algorithm is currently in.
	 */
	var currentState: BackOffState { get }

	/**
	 This method is responsible for calculating the time to wait until running the next attempt. It should exit once `backOff.run()` returns `true` or the timeout exceeded. Once called, the algorithm should start executing.

	 - returns: self
	 */
	func algorithm(backOff: BackOff) -> BackOffAlgorithm

	/**
	 Should stop the execution if `currentState` is `BackOffState.Running`. Returns `BackOffState.Stopped` if it was running and has been stopped or `currentState`.

	 - returns: BackOffState.Stopped if it was running, `currentState` otherwise.
	 */
	func stopExecution() -> BackOffState

	/**
	 Should reset the backoff to its initial state and start the algorithm again. This should not do anything if `currentState` equals `BackOffState.Running`.

	 - returns: `currentState`
	 */
	func reset() -> BackOffState
}
