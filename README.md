# Lua Profiling Tool

### HowTo

The module luaprofile is a small, non-intrusive module to find bottlenecks in Lua code.
  
The following code block shows how to implement the luaprofile module:
  
```
local tProfiler = require("luaprofiler")(tLog)

tProfiler:start({"extract_evalData", "get_DefaultEvalData", "update_evalData"})

-- Code block with called functions to profile

local tProfilerData = tProfiler:stop()
```


1. The luaprofile module is initialized by: require("luaprofiler")(tLog)
2. A table with function names to be examined is passed to the "start" function of the profiling module
3. The "stop" function returns a table with the result of the profiling like for example:
```
{
  TotalTime = 34.09699010849,
  extract_evalData = {
    ArithmeticMean = 0.0017528112422037,
    TotalTime = 0.31725883483887,
    count = 181
  },
  get_DefaultEvalData = {
    ArithmeticMean = 15.499127149582,
    TotalTime = 15.499127149582,
    count = 1
  },
  update_evalData = {
    ArithmeticMean = 0.00088546420987798,
    TotalTime = 0.16026902198792,
    count = 181
  }
}
```
whereby all measured time is in seconds [s].

### Issues
- However, there are restrictions on the functions that can be tracked:
  - tail calls (https://en.wikipedia.org/wiki/Tail_call) 
  - There are 3 different events with a registered hook using sethook (calling and returning functions): "call","return" und "tail call" 
  - tail calls are not stored in the stack (https://stackoverflow.com/questions/56949901/strange-behavior-caused-by-debug-getinfo1-n-name oder http://lua-users.org/wiki/ProperTailRecursion), so there is no information about the tracked function in the hook function using debug.getinfo.
  - Functions that end with a tail call cannot be tracked because there is no clear end ("return").
  - Functions that begin with a tail call cannot be tracked because there is no clear beginning ("call").
- By repeatedly calling the defined hook function and reading out the function information using debug.getinfo (stack information), the profiling of lua with the module luaprofiler results in an increase of computational effort. This falsifies the measured runtimes of the registered functions.

### Improvements

- The hook function could be implemented in C. This could reduce a little bit the computational effort and hence improve the measured runtime of the registered function.
- The profiling could be in a separate Lua state and a separate thread.

