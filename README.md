# ExponentialBackOff

[![CI Status](http://img.shields.io/travis/Ybrin/ExponentialBackOff.svg?style=flat)](https://travis-ci.org/Ybrin/ExponentialBackOff)
[![Version](https://img.shields.io/cocoapods/v/ExponentialBackOff.svg?style=flat)](http://cocoapods.org/pods/ExponentialBackOff)
[![License](https://img.shields.io/cocoapods/l/ExponentialBackOff.svg?style=flat)](http://cocoapods.org/pods/ExponentialBackOff)
[![Platform](https://img.shields.io/cocoapods/p/ExponentialBackOff.svg?style=flat)](http://cocoapods.org/pods/ExponentialBackOff)

## Description

This framework implements the ExponentialBackOff algorithm which reruns given code after an amount of time which you can change until it succeeds or the Timeout exceeds. This can be usefull for Networking in your application.

If you want to refresh a list by calling an API Request, you may want to check the Internet availability with ***[Reachability](https://github.com/tonymillion/Reachability)*** and if there is no connection available you would recheck it after some time manually.    
And this is where this API comes into play. It rereuns your code automatically on a exponential basis.    
The time to wait until the next attempt is calculated as follows:

```
next_interval = retry_interval * (random value in range [1 - randomization_factor, 1 + randomization_factor])
```

and `retry_interval` is calculated like that:

`retry_interval = last_retry_interval * multiplier`

If this is the first re-attempt, `last_retry_interval` will be set to `initial_retry_interval`

The default values are as follows:

```Swift
public static let DEFAULT_INITIAL_INTERVAL_MILLIS: Int = 500 // 0.5 seconds

public static let DEFAULT_MAX_ELAPSED_TIME_MILLIS: Int = 900000 // 15 minutes

public static let DEFAULT_MAX_INTERVAL_MILLIS: Int = 60000 // Intervall won't increase any more - 5 minutes

public static let DEFAULT_MULTIPLIER: Double = 1.5 // 1.5

public static let DEFAULT_RANDOMIZATION_FACTOR: Double = 0.5 // 0.5 or 50%
```

You can change any of these values to whatever you want but they are also the default values at Google's Java API library which should be used to request GCM tokens for example.

## Installation

ExponentialBackOff is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ExponentialBackOff"
```

## Usage

Basic usage is very straightforward. The following code shows a simple example on how to use the framework.

```Swift
let builder = ExponentialBackOffInstance.Builder()
let exponentialBackOff = ExponentialBackOffInstance(builder: builder)

ExponentialBackOff.sharedInstance.runGeneralBackOff(exponentialBackOff) {
    (lastIntervallMillis, elapsedTimeMillis, completion) in
    
    print("Last interval: \(lastIntervallMillis)")
    print("Elapsed time overall: \(elapsedTimeMillis)")
    
    let randomNumber = arc4random_uniform(100)
    
    if randomNumber == 28 {
        print("Success! Terminating the back-off instance.")
        completion(success: true)
    } else {
        print("Failed, retrying after some time.")
        completion(success: false)
    }
    
	 }
```

Actually thats it. Now build the project and lean back. If you are lucky, it will eventually print *Success*. If not it will try again and again with bigger intervals between the attempts each time until it reaches the Timeout (`maxElapsedTimeMillis`).

> Note: Your code will be executed on a background Thread so if you must run it on the main Thread you should wrap it either with [AsyncSwift](https://github.com/duemunk/Async) like that: `Async.main {}` or like that: `dispatch_async(dispatch_get_main_queue()) {}`.

---

If you want to change some default values you can manipulate your `Builder`'s members:

```Swift
let builder = ExponentialBackOffInstance.Builder()
builder.initialIntervalMillis = 2000
builder.maxElapsedTimeMillis = 100000
builder.maxIntervalMillis = 10000
builder.randomizationFactor = 0.2
builder.multiplier = 2.0

let exponentialBackOff = ExponentialBackOffInstance(builder: builder)

ExponentialBackOff.sharedInstance.runGeneralBackOff(exponentialBackOff) {
    (lastIntervallMillis, elapsedTimeMillis, completion) in
    
    // Last interval millis is never greater than maxIntervalMillis
    print("Last interval: \(lastIntervallMillis)")
    
    // If the elapsedTime exceeds maxElapsedTimeMillis the ExponentialBackOffInstance exits with
    // BackOffState.Failed as the currentState
    print("Elapsed time overall: \(elapsedTimeMillis)")
    
    let randomNumber = arc4random_uniform(100)
    
    if randomNumber == 97 {
        print("Success! Terminating the back-off instance.")
        completion(success: true)
    } else {
        print("Failed, retrying after some time.")
        completion(success: false)
    }
    
}
```

You can read some values from your ExponentialBackOffInstance:

```Swift
let exponentialBackOff = ExponentialBackOffInstance(builder: builder)
.
.
.

if exponentialBackOff.currentState == .Failed {
    exponentialBackOff.reset() // Restarts the back-off with the same code.
}

if exponentialBackOff.attempts >= 100 {
    exponentialBackOff.stopExecution() // Stops the execution and sets currentState to BackOffState.Stopped
}
```

More examples soon...

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7.2+
- [AsyncSwift](https://github.com/duemunk/Async) 1.7+ (Cocoapods will install all dependencies automatically)

## Author

Ybrin, koray@koska.at

## License

ExponentialBackOff is available under the MIT license. See the LICENSE file for more info.
