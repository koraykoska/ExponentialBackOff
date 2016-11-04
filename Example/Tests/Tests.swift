// https://github.com/Quick/Quick

import Quick
import Nimble
import ExponentialBackOff
import Async

class TableOfContentsSpec: QuickSpec {

	class TestBackOff: BackOff {

		func run(_ lastIntervallMillis: Int, elapsedTimeMillis: Int, codeToRunAfterFinishedExecuting: @escaping (_ success: Bool) -> BackOffState) {
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
						_ = codeToRunAfterFinishedExecuting(false)
					} else {
						_ = codeToRunAfterFinishedExecuting(true)
					}
				}
			}
		}
	}

	var exponentialBackOff: ExponentialBackOffInstance!

	override func spec() {
		/*
		 describe("these will fail") {

		 it("can do maths") {
		 expect(1) == 2
		 }

		 it("can read") {
		 expect("number") == "string"
		 }

		 it("will eventually fail") {
		 expect("time").toEventually(equal("done"))
		 }

		 context("these will pass") {

		 it("can do maths") {
		 expect(23) == 23
		 }

		 it("can read") {
		 expect("🐮") == "🐮"
		 }

		 it("will eventually pass") {
		 var time = "passing"

		 dispatch_async(dispatch_get_main_queue()) {
		 time = "done"
		 }

		 waitUntil { done in
		 NSThread.sleepForTimeInterval(0.5)
		 expect(time) == "done"

		 done()
		 }
		 }
		 }
		 }*/

		// Test ExponentialBackOff algorithm

		beforeEach {
			let builder = ExponentialBackOffInstance.Builder()
			builder.maxElapsedTimeMillis = 10000
			self.exponentialBackOff = ExponentialBackOffInstance(builder: builder)
		}

		describe("Testing the exponential backoff algorithm") {

			it("Should back off the code exponentially") {
				self.exponentialBackOff.algorithm(TestBackOff())

				expect(self.exponentialBackOff.currentState) == BackOffState.running

				// expect(self.exponentialBackOff.currentState).toEventually(BackOffState.Failed)
			}
		}
	}
}
