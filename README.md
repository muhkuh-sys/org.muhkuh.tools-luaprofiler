# Lua Profiling Tool

### HowTo

The module luaprofile is a small, non-intrusive module to find bottlenecks in Lua code.
  
The following code block shows how to implement the luaprofile module:
  
```
local tProfiler = require("luaprofiler")(tLog)

tProfiler:start({"netIOLGate_set_ilim", "netIOLGate_set", "usbMatrixTree_set","sample_raw","measureAnnabella"})

-- Code block with called functions to profile

local tProfilerData = tProfiler:stop()
```


1. The luaprofile module is initialized by: require("luaprofiler")(tLog)
2. A table with function names to be examined is passed to the "start" function of the profiling module
3. The "stop" function returns the result of the profiling like for example:
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
whereby all measured time is in [s].

### Issues

- By repeatedly calling the defined hook function and reading out the function information using debug.getinfo (stack information), the profiling of lua with the module luaprofiler results in an increase of computational effort. This falsifies the measured runtimes of the registered functions.

### Improvements

- The hook function could be implemented in C. This could reduce a little bit the computational effort and hence improve the measured runtime of the registered function.
- Thread

