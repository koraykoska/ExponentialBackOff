//
//  ExponentialBackOffInstance.swift
//  ExponentialBackOff
//
//  Created by Koray Koska on 04/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation
import Async

open class ExponentialBackOffInstance: BackOffAlgorithm {

	// MARK: - Properties

	/**
	 The initial interval value in milliseconds.
	 */
    public let initialIntervalMillis: Int

	/**
	 The maximum elapsed time after which the BackOff stops executing in milliseconds.
	 */
    public let maxElapsedTimeMillis: Int

	/**
	 The maximum back off time in milliseconds.
	 */
    public let maxIntervalMillis: Int

	/**
	 The multiplier value.
	 */
    public let multiplier: Double

	/**
	 The randomization factor.
	 */
    public let randomizationFactor: Double

	/**
	 The number of attempts to run the BackOffAlgorithm successfully
	 */
	open fileprivate(set) var attempts: Int = 0

	// MARK: - Algorithm specific private Properties
	fileprivate var savedBackOff: BackOff?

	fileprivate var lastIntervallMillis: Double!

	fileprivate var elapsedTimeMillis: Double = 0

	// MARK: - Initializers
	public init(initialIntervalMillis: Int, maxElapsedTimeMillis: Int, maxIntervalMillis: Int, multiplier: Double, randomizationFactor: Double) {
		self.initialIntervalMillis = initialIntervalMillis
		self.maxElapsedTimeMillis = maxElapsedTimeMillis
		self.maxIntervalMillis = maxIntervalMillis
		self.multiplier = multiplier
		self.randomizationFactor = randomizationFactor
	}

	public init(builder: ExponentialBackOffInstance.Builder) {
		self.initialIntervalMillis = builder.initialIntervalMillis
		self.maxElapsedTimeMillis = builder.maxElapsedTimeMillis
		self.maxIntervalMillis = builder.maxIntervalMillis
		self.multiplier = builder.multiplier
		self.randomizationFactor = builder.randomizationFactor
	}

	// MARK: - BackOffAlgorithm fields

	open fileprivate(set) var currentState: BackOffState = BackOffState.stopped

    open func algorithm(_ backOff: BackOff, completion: ((_ state: BackOffState) -> Void)?) -> BackOffAlgorithm {
		self.savedBackOff = backOff
		attempts += 1

		if attempts != 1 && currentState == .stopped {
            completion?(currentState)
			return self
		}

		if elapsedTimeMillis >= Double(maxElapsedTimeMillis) {
			self.currentState = .failed
            completion?(currentState)
			return self
		}

		// Calculate next delay
		var currentDelay: Double

		if let lastValue = lastIntervallMillis {
			if lastValue <= 0 {
				lastIntervallMillis = Double(initialIntervalMillis)
			} else {
				lastIntervallMillis = lastValue * multiplier
			}
		} else {
			lastIntervallMillis = Double(initialIntervalMillis)
		}
		let lower: Double = 1 - randomizationFactor
		let upper: Double = 1 + randomizationFactor

		currentDelay = lastIntervallMillis * Random.within(lower ... upper)

		currentDelay = currentDelay > Double(maxIntervalMillis) ? Double(maxIntervalMillis) : currentDelay

		elapsedTimeMillis = elapsedTimeMillis + currentDelay

		// Set state to .Running
		currentState = .running

		Async.main(after: Tools.millisToSeconds(currentDelay)) {
			backOff.run(Int(currentDelay), elapsedTimeMillis: Int(self.elapsedTimeMillis))
			{ success in
				if success == true {
					self.currentState = BackOffState.succeeded
                    completion?(self.currentState)
					return self.currentState
				} else {
					Async.background {
						self.algorithm(backOff, completion: completion)
					}
					return self.currentState
				}
			}
		}

		return self
	}

	open func stopExecution() -> BackOffState {
		if currentState == .running {
			currentState = .stopped
			return BackOffState.stopped
		}
		return currentState
	}

	open func reset() -> BackOffState {
		if currentState != .running && attempts != 0 {
			if let backOff = savedBackOff {
				attempts = 0
				lastIntervallMillis = nil
				elapsedTimeMillis = 0
				Async.background {
					self.algorithm(backOff)
				}
			}
		}

		return currentState
	}

	// MARK: - Helper classes
	open class Builder {

		// MARK: - Properties
		/**
		 The initial interval value in milliseconds, defaulted to BackOffProperties.DEFAULT_INITIAL_INTERVAL_MILLIS.
		 */
		open var initialIntervalMillis: Int

		/**
		 The maximum elapsed time after which the BackOff stops executing in milliseconds, defaulted to BackOffProperties.DEFAULT_MAX_ELAPSED_TIME_MILLIS.
		 */
		open var maxElapsedTimeMillis: Int

		/**
		 The maximum back off time in milliseconds, defaulted to BackOffProperties.DEFAULT_MAX_INTERVAL_MILLIS.
		 */
		open var maxIntervalMillis: Int

		/**
		 The multiplier value, defaulted to BackOffProperties.DEFAULT_MULTIPLIER.
		 */
		open var multiplier: Double

		/**
		 The default randomization factor, defaulted to BackOffProperties.DEFAULT_RANDOMIZATION_FACTOR.
		 */
		open var randomizationFactor: Double

		// MARK: - Initializers

		public init(initialIntervalMillis: Int = BackOffProperties.DEFAULT_INITIAL_INTERVAL_MILLIS, maxElapsedTimeMillis: Int = BackOffProperties.DEFAULT_MAX_ELAPSED_TIME_MILLIS, maxIntervalMillis: Int = BackOffProperties.DEFAULT_MAX_INTERVAL_MILLIS, multiplier: Double = BackOffProperties.DEFAULT_MULTIPLIER, randomizationFactor: Double = BackOffProperties.DEFAULT_RANDOMIZATION_FACTOR) {
			self.initialIntervalMillis = initialIntervalMillis
			self.maxElapsedTimeMillis = maxElapsedTimeMillis
			self.maxIntervalMillis = maxIntervalMillis
			self.multiplier = multiplier
			self.randomizationFactor = randomizationFactor
		}
	}
}
