//
//  BackOffState.swift
//  ExponentialBackOff
//
//  Created by Koray Koska on 04/03/16.
//  Copyright © 2016 KW Technologies. All rights reserved.
//

import Foundation

public enum BackOffState {

	/**
	 Indicates that the BackOff has not succeeded yet but is still valid and running
	 */
	case running

	/**
	 The BackOff has not started yet
	 */
	case stopped

	/**
	 The BackOff finished proccessing because of the Timeout but never returned true
	 */
	case failed

	/**
	 The BackOff returned true and stopped proccessing
	 */
	case succeeded
}
