import thorvg_capi

type
  ThorVGError* = object of CatchableError

proc checkResult*(result: TvgResult) =
  ## Check ThorVG result and raise exception if error
  if result != TVG_RESULT_SUCCESS:
    case result:
    of TVG_RESULT_INVALID_ARGUMENT:
      raise newException(ThorVGError, "Invalid argument")
    of TVG_RESULT_INSUFFICIENT_CONDITION:
      raise newException(ThorVGError, "Insufficient condition")
    of TVG_RESULT_FAILED_ALLOCATION:
      raise newException(ThorVGError, "Failed allocation")
    of TVG_RESULT_MEMORY_CORRUPTION:
      raise newException(ThorVGError, "Memory corruption")
    of TVG_RESULT_NOT_SUPPORTED:
      raise newException(ThorVGError, "Not supported")
    else:
      raise newException(ThorVGError, "Unknown error: " & $result)

proc getVersion*(): tuple[major, minor, micro: uint32, version: string] =
  ## Get ThorVG version
  var major, minor, micro: uint32
  var version: cstring
  checkResult(tvgEngineVersion(addr major, addr minor, addr micro, cast[cstringArray](addr version)))
  result = (major, minor, micro, $version) 

type ThorEngine* = object

var
  thorvgEngineRunning*: bool

proc termEngine*() =
  ## Terminate ThorVG engine
  if thorvgEngineRunning:
    discard tvg_engine_term()
    thorvgEngineRunning = false

proc `=destroy`*(engine: var ThorEngine) =
  ## Destroy ThorVG engine
  termEngine()

# High-level Nim API
proc initThorEngine*(threads: uint = 0): ThorEngine =
  ## Initialize ThorVG engine
  doAssert not thorvgEngineRunning

  # if not loadThorVG():
  #   raise newException(ThorVGError, "Failed to load ThorVG library")
  checkResult(tvg_engine_init(threads.cuint))
  thorvgEngineRunning = true

  echo "ThorVG engine version: ", getVersion()