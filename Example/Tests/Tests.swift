// https://github.com/Quick/Quick

import Quick
import Nimble
import ExponentialBackOff
import Async

class TableOfContentsSpec: QuickSpec {

	var exponentialBackOff: ExponentialBackOffInstance!

    var timeOut: TimeInterval!

	override func spec() {
		beforeEach {
			let builder = ExponentialBackOffInstance.Builder()
			builder.maxElapsedTimeMillis = 1500
            builder.maxIntervalMillis = 500
			self.exponentialBackOff = ExponentialBackOffInstance(builder: builder)

            self.timeOut = (TimeInterval(builder.maxIntervalMillis) + TimeInterval(builder.maxIntervalMillis)) * 2
		}

		describe("Testing the exponential backoff algorithm") {

			it("Should finish with the state failed") {
                waitUntil(timeout: self.timeOut, action: { (done) in
                    ExponentialBackOff.sharedInstance.runGeneralBackOff(self.exponentialBackOff, codeToRun: { (last, elapsed, completion) in
                        var number: Int = 0
                        for i in 1 ... 100 {
                            number = number + i
                        }

                        if number != 5051 {
                            _ = completion(false)
                        } else {
                            _ = completion(true)
                        }
                    }, completion: { state in
                        if state == .failed {
                            print("Failed!?")
                            done()
                        }
                    })
                })
			}

            it("Should finish with the state succeeded") {
                waitUntil(timeout: self.timeOut, action: { (done) in
                    ExponentialBackOff.sharedInstance.runGeneralBackOff(self.exponentialBackOff, codeToRun: { (last, elapsed, completion) in
                        var number: Int = 0
                        for i in 1 ... 100 {
                            number = number + i
                        }

                        if number != 5050 {
                            _ = completion(false)
                        } else {
                            _ = completion(true)
                        }
                    }, completion: { state in
                        if state == .succeeded {
                            done()
                        }
                    })
                })
            }
		}
	}
}
