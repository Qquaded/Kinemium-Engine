--!strict
--!native
--!optimize 2
return {
    spawn = function(f: (() -> ()) | thread): thread
        if (type(f) == "function") then
            local thread = coroutine.create(f);
            assert(coroutine.resume(thread));
            return thread
        end
        assert(coroutine.resume(f));
        return f;
    end,
    wait = function(f: (() -> ()) | thread): (() -> ())
        error("Not implemented");
    end,
    delay = function(time: number, f: (() -> ()) | thread): thread
        error("Not implemented");
    end,
    defer = function(f: (() -> ()) | thread): thread
        error("Not implemented");
    end,
};
