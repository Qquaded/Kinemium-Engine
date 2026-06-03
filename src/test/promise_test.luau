local Promise = require("../environment/datatypes/Promise")

local testing = zune.testing
local expect = testing.expect

testing.describe("Promise", function()
	testing.test("resolve and andThen", function()
		local value = nil
		Promise.resolve(123):andThen(function(v)
			value = v
		end)
		expect(value).toBe(123)
	end)

	testing.test("reject and catch", function()
		local reason = nil
		Promise.reject("nope"):catch(function(e)
			reason = e
		end)
		expect(reason).toBe("nope")
	end)

	testing.test("double resolve is ignored", function()
		local value = nil
		Promise.new(function(resolve)
			resolve("first")
			resolve("second")
		end):andThen(function(v)
			value = v
		end)
		expect(value).toBe("first")
	end)

	testing.test("finally runs for fulfillment and rejection", function()
		local hits = 0
		Promise.resolve(1):finally(function()
			hits += 1
		end)
		Promise.reject("x"):catch(function() end):finally(function()
			hits += 1
		end)
		expect(hits).toBe(2)
	end)

	testing.test("state helpers", function()
		local resolveFn = nil
		local p = Promise.new(function(resolve)
			resolveFn = resolve
		end)
		expect(p:isPending()).toBeTruthy()
		expect(p:isSettled()).toBeFalsy()
		resolveFn(7)
		expect(p:isFulfilled()).toBeTruthy()
		expect(p:isSettled()).toBeTruthy()
	end)

	testing.test("cancel pending promise", function()
		local cancelHookHit = false
		local p = Promise.new(function(_, _, onCancel)
			onCancel(function()
				cancelHookHit = true
			end)
		end)
		expect(p:cancel()).toBeTruthy()
		expect(p:isCanceled()).toBeTruthy()
		expect(cancelHookHit).toBeTruthy()
	end)

	testing.test("cancel settled promise returns false", function()
		local p = Promise.resolve("done")
		expect(p:cancel()).toBeFalsy()
	end)

	testing.test("Promise.all resolves and rejects", function()
		local okValues = nil
		local allErr = nil

		Promise.all({ Promise.resolve(1), 2, Promise.resolve(3) }):andThen(function(v)
			okValues = v
		end)
		expect(okValues[1]).toBe(1)
		expect(okValues[2]).toBe(2)
		expect(okValues[3]).toBe(3)

		Promise.all({ Promise.resolve(1), Promise.reject("bad"), Promise.resolve(3) }):catch(function(e)
			allErr = e
		end)
		expect(allErr).toBe("bad")
	end)

	testing.test("Promise.all with empty table resolves immediately", function()
		local okValues = nil
		Promise.all({}):andThen(function(v)
			okValues = v
		end)
		expect(type(okValues)).toBe("table")
		expect(#okValues).toBe(0)
	end)

	testing.test("Promise.race resolves with first settled", function()
		local resolveA, resolveB
		local result = nil
		local pA = Promise.new(function(resolve)
			resolveA = resolve
		end)
		local pB = Promise.new(function(resolve)
			resolveB = resolve
		end)

		Promise.race({ pA, pB }):andThen(function(v)
			result = v
		end)

		resolveB("fast")
		resolveA("slow")
		expect(result).toBe("fast")
	end)

	testing.test("Promise.any resolves one and rejects when all reject", function()
		local value = nil
		local errorObj = nil
		Promise.any({ Promise.reject("a"), Promise.resolve("ok"), Promise.reject("b") }):andThen(function(v)
			value = v
		end)
		expect(value).toBe("ok")

		Promise.any({ Promise.reject("a"), Promise.reject("b") }):catch(function(e)
			errorObj = e
		end)
		expect(errorObj.message).toBe("All promises rejected")
		expect(errorObj.errors[1]).toBe("a")
		expect(errorObj.errors[2]).toBe("b")
	end)

	testing.test("Promise.allSettled gives mixed statuses", function()
		local results = nil
		Promise.allSettled({ Promise.resolve(5), Promise.reject("x") }):andThen(function(v)
			results = v
		end)
		expect(results[1].status).toBe("fulfilled")
		expect(results[1].value).toBe(5)
		expect(results[2].status).toBe("rejected")
		expect(results[2].reason).toBe("x")
	end)

	testing.test("Promise.delay resolves value", function()
		local value = nil
		Promise.delay(1, "tick"):andThen(function(v)
			value = v
		end)
		expect(value).toBe("tick")
	end)

	testing.test("Promise.await errors outside coroutine", function()
		local ok = pcall(function()
			Promise.await(Promise.resolve(1))
		end)
		expect(ok).toBeFalsy()
	end)

	testing.test("Promise.promisify wraps callback APIs", function()
		local addAsync = Promise.promisify(function(a, b, cb)
			cb(nil, a + b)
		end)
		local failAsync = Promise.promisify(function(cb)
			cb("boom")
		end)

		local sum = nil
		local err = nil
		addAsync(2, 3):andThen(function(v)
			sum = v
		end)
		failAsync():catch(function(e)
			err = e
		end)

		expect(sum).toBe(5)
		expect(err).toBe("boom")
	end)
end)
