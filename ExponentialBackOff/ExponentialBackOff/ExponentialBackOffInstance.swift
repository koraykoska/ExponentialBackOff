//
//  ExponentialBackOffInstance.swift
//  ExponentialBackOff
//
//  Created by Koray Koska on 04/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation
import Async

public class ExponentialBackOffInstance: BackOffAlgorithm {

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
	public private(set) var attempts: Int = 0

	// MARK: - Algorithm specific private Properties
	private var savedBackOff: BackOff?

	private var lastIntervallMilis: Double!

	private var elapsedTimeMillis: Double = 0

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

	public var currentState: BackOffState = BackOffState.Stopped

	public func algorithm(backOff: BackOff) -> BackOffAlgorithm {
		self.savedBackOff = backOff
		attempts++

		if attempts != 1 && currentState == .Stopped {
			return self
		}

		if elapsedTimeMillis >= Double(maxElapsedTimeMillis) {
			self.currentState = .Failed
			return self
		}

		// Calculate next delay
		var currentDelay: Double

		if let lastValue = lastIntervallMilis {
			if lastValue <= 0 {
				lastIntervallMilis = Double(initialIntervalMillis)
			} else {
				lastIntervallMilis = lastValue * multiplier
			}
		} else {
			lastIntervallMilis = Double(initialIntervalMillis)
		}
		let lower: Double = 1 - randomizationFactor
		let upper: Double = 1 + randomizationFactor

		currentDelay = lastIntervallMilis * Random.within(lower ... upper)

		currentDelay = currentDelay > Double(maxIntervalMillis) ? Double(maxIntervalMillis) : currentDelay

		elapsedTimeMillis = elapsedTimeMillis + currentDelay

		// Set state to .Running
		currentState = .Running

		Async.background(after: Tools.millisToSeconds(currentDelay)) {
			backOff.run(Int(currentDelay), elapsedTimeMillis: Int(self.elapsedTimeMillis))
			{ success in
				if success == true {
					self.currentState = BackOffState.Succeeded
					return self.currentState
				} else {
					Async.background {
						self.algorithm(backOff)
					}
					return self.currentState
				}
			}
		}

		return self
	}

	public func stopExecution() -> BackOffState {
		if currentState == .Running {
			currentState = .Stopped
			return BackOffState.Stopped
		}
		return currentState
	}

	public func reset() -> BackOffState {
		if currentState != .Running && attempts != 0 {
			if let backOff = savedBackOff {
				attempts = 0
				lastIntervallMilis = nil
				elapsedTimeMillis = 0
				Async.background {
					self.algorithm(backOff)
				}
			}
		}

		return currentState
	}

	// MARK: - Helper classes
	public class Builder {

		// MARK: - Properties
		/**
		 The initial interval value in milliseconds, defaulted to BackOffProperties.DEFAULT_INITIAL_INTERVAL_MILLIS.
		 */
		public var initialIntervalMillis: Int = BackOffProperties.DEFAULT_INITIAL_INTERVAL_MILLIS

		/**
		 The maximum elapsed time after which the BackOff stops executing in milliseconds, defaulted to BackOffProperties.DEFAULT_MAX_ELAPSED_TIME_MILLIS.
		 */
		public var maxElapsedTimeMillis: Int = BackOffProperties.DEFAULT_MAX_ELAPSED_TIME_MILLIS

		/**
		 The maximum back off time in milliseconds, defaulted to BackOffProperties.DEFAULT_MAX_INTERVAL_MILLIS.
		 */
		public var maxIntervalMillis: Int = BackOffProperties.DEFAULT_MAX_INTERVAL_MILLIS

		/**
		 The multiplier value, defaulted to BackOffProperties.DEFAULT_MULTIPLIER.
		 */
		public var multiplier: Double = BackOffProperties.DEFAULT_MULTIPLIER

		/**
		 The default randomization factor, defaulted to BackOffProperties.DEFAULT_RANDOMIZATION_FACTOR.
		 */
		public var randomizationFactor: Double = BackOffProperties.DEFAULT_RANDOMIZATION_FACTOR

		// MARK: - Initializers

		public init() {
		}

		public init(initialIntervalMillis: Int, maxElapsedTimeMillis: Int, maxIntervalMillis: Int, multiplier: Double, randomizationFactor: Double) {
			self.initialIntervalMillis = initialIntervalMillis
			self.maxElapsedTimeMillis = maxElapsedTimeMillis
			self.maxIntervalMillis = maxIntervalMillis
			self.multiplier = multiplier
			self.randomizationFactor = randomizationFactor
		}
	}
}
