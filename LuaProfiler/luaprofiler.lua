------------------------------------------------------------------------------------------------------------------------------------------------------
-- local variables of profiler
------------------------------------------------------------------------------------------------------------------------------------------------------
-- try to fast up with locals (similar to penlight moduls)

local socket = require "socket"

-- init penlight
local pl = require "pl.import_into"()

local debug_getinfo, debug_sethook = debug.getinfo, debug.sethook
local pairs, type, format = pairs, type, string.format

--init logger as local variable (from object _init)
local tLog
local log_debug, log_warning, log_error, log_info

-- use the timer of the socket module
local getTime = socket.gettime -- os.clock

local tSetFncNames
local startTime, stopTime
local atEvalDataProfiler

-- Create the Profiler class.
local class = pl.class
local Profiler = class()

--- hook function must be registered by sethook.
function Profiler:_init(tLog_init)
  tLog = tLog_init
  log_error, log_debug, log_warning, log_info = tLog.error, tLog.debug, tLog.warning, tLog.info
end

---
local function hook(event, line, info)
  -- https://www.lua.org/pil/23.1.html
  -- Programming_in_Lua,_4th_ed Chapter 25. Reflection -> Introspective Facilities
  info = info or debug_getinfo(2, "n") -- "nS"

  -- -- ignore the profiler itself
  -- if self[info.name] or info.what ~= "Lua" then
  --   return
  -- end

  if event == "call" and tSetFncNames[info.name] == true then
    atEvalDataProfiler[info.name].StartTime = getTime()
    atEvalDataProfiler[info.name].count = atEvalDataProfiler[info.name].count + 1
  elseif event == "return" and tSetFncNames[info.name] == true then
    -- atEvalDataProfiler[info.name].AllTime[#atEvalDataProfiler[info.name].AllTime + 1] = time
    local time = (getTime() - atEvalDataProfiler[info.name].StartTime)
    atEvalDataProfiler[info.name].StartTime = 0
    atEvalDataProfiler[info.name].TotalTime = atEvalDataProfiler[info.name].TotalTime + time

    -- https://en.wikipedia.org/wiki/Moving_average
    -- cumulative average (CA)
    -- atEvalDataProfiler[info.name].CA = (time + (atEvalDataProfiler[info.name].count - 1) * atEvalDataProfiler[info.name].CA) / atEvalDataProfiler[info.name].count

  elseif event == "tail call" then
    -- - However, there are restrictions on the functions that can be tracked:
    -- - tail calls (https://en.wikipedia.org/wiki/Tail_call) 
    --  - There are 3 different events with a registered hook using sethook (calling and returning functions): "call","return" und "tail call" 
    --  - tail calls are not stored in the stack (https://stackoverflow.com/questions/56949901/strange-behavior-caused-by-debug-getinfo1-n-name oder http://lua-users.org/wiki/ProperTailRecursion), 
    --     so there is no information about the tracked function in the hook function using debug.getinfo.
    --  - Functions that end with a tail call cannot be tracked because there is no clear end ("return").
    --  - Functions that begin with a tail call cannot be tracked because there is no clear beginning ("call").
  end
end

--- start the profiler.
-- @param tFncNames table with function name(s) to profile
function Profiler:start(tFncNames)
  tSetFncNames = {}
  atEvalDataProfiler = {}

  if type(tFncNames) == "string" then
    tFncNames = {tFncNames}
  end

  if type(tFncNames) ~= "table" then
    local strMsg = format("The given table of function name(s) is not a table.")
    log_error(strMsg)
    error(strMsg)
  end

  tSetFncNames = {}
  for _, strFncName in pairs(tFncNames) do
    if type(strFncName) ~= "string" then
      local strMsg = format("The given table of function name(s) does only contain strings.")
      log_error(strMsg)
      error(strMsg)
    end

    tSetFncNames[strFncName] = true
  end

  for strFncName, _ in pairs(tSetFncNames) do
    atEvalDataProfiler[strFncName] = {
      StartTime = 0, -- temporary starting time
      count = 0, -- number of calls
      TotalTime = 0, -- total time
      -- CA = 0 -- cumulative average
    }
  end

  startTime = getTime()
  stopTime = nil
  debug_sethook(hook, "cr", 0)
end

--- stop the profiler.
function Profiler:stop()
  stopTime = getTime()
  debug_sethook()

  for _, tEvalDataProfiler in pairs(atEvalDataProfiler) do
    tEvalDataProfiler.StartTime = nil
    tEvalDataProfiler.ArithmeticMean = tEvalDataProfiler.TotalTime / tEvalDataProfiler.count
  end

  atEvalDataProfiler.TotalTime = stopTime - startTime

  return atEvalDataProfiler
end

return Profiler
