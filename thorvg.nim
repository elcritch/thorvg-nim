## ThorVG Nim Wrapper
## 
## A comprehensive Nim wrapper for the ThorVG C API with idiomatic Nim conventions
## and dynamic library loading support.

import dynlib, os, strutils, math

import thorvg/thorvg_capi

export thorvg_capi

# const hdr = "<thorvg_capi.h>"
# when defined(macosx):
#   {.passC: "-I/opt/homebrew/include".}
#   {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
# elif defined(windows):
#   {.passC: "-I/usr/local/include".}
# else:
#   {.passC: "-I/usr/local/include".}

# when defined(windows):
#   const thorvgLibName = "thorvg.dll"
# elif defined(macosx):
#   const thorvgLibName = "libthorvg.dylib"
# else:
#   const thorvgLibName = "libthorvg.so"

type
  ThorVGError* = object of CatchableError
  
#   # Core types
#   TvgResult* {.importc: "Tvg_Result", header: hdr.} = enum
#     tvgSuccess = 0
#     tvgInvalidArgument
#     tvgInsufficientCondition
#     tvgFailedAllocation
#     tvgMemoryCorruption
#     tvgNotSupported
#     tvgUnknown = 255

#   TvgColorspace* {.importc: "Tvg_Colorspace", header: hdr.} = enum
#     tvgAbgr8888 = 0
#     tvgArgb8888
#     tvgAbgr8888s
#     tvgArgb8888s
#     tvgUnknownColorspace = 255

#   TvgMaskMethod* {.importc: "Tvg_Mask_Method", header: hdr.} = enum
#     tvgMaskNone = 0
#     tvgMaskAlpha
#     tvgMaskInverseAlpha
#     tvgMaskLuma
#     tvgMaskInverseLuma
#     tvgMaskAdd
#     tvgMaskSubtract
#     tvgMaskIntersect
#     tvgMaskDifference
#     tvgMaskLighten
#     tvgMaskDarken

#   TvgBlendMethod* {.importc: "Tvg_Blend_Method", header: hdr.} = enum
#     tvgBlendNormal = 0
#     tvgBlendMultiply
#     tvgBlendScreen
#     tvgBlendOverlay
#     tvgBlendDarken
#     tvgBlendLighten
#     tvgBlendColorDodge
#     tvgBlendColorBurn
#     tvgBlendHardLight
#     tvgBlendSoftLight
#     tvgBlendDifference
#     tvgBlendExclusion
#     tvgBlendHue
#     tvgBlendSaturation
#     tvgBlendColor
#     tvgBlendLuminosity
#     tvgBlendAdd
#     tvgBlendHardMix

#   TvgType* {.importc: "Tvg_Type", header: hdr.} = enum
#     tvgTypeUndef = 0
#     tvgTypeShape
#     tvgTypeScene
#     tvgTypePicture
#     tvgTypeText
#     tvgTypeLinearGrad = 10
#     tvgTypeRadialGrad

#   TvgPathCommand* = uint8

#   TvgStrokeCap* {.importc: "Tvg_Stroke_Cap", header: hdr.} = enum
#     tvgStrokeCapButt = 0
#     tvgStrokeCapRound
#     tvgStrokeCapSquare

#   TvgStrokeJoin* {.importc: "Tvg_Stroke_Join", header: hdr.} = enum
#     tvgStrokeJoinMiter = 0
#     tvgStrokeJoinRound
#     tvgStrokeJoinBevel

#   TvgStrokeFill* {.importc: "Tvg_Stroke_Fill", header: hdr.} = enum
#     tvgStrokeFillPad = 0
#     tvgStrokeFillReflect
#     tvgStrokeFillRepeat

#   TvgFillRule* {.importc: "Tvg_Fill_Rule", header: hdr.} = enum
#     tvgFillRuleNonZero = 0
#     tvgFillRuleEvenOdd

#   # Opaque pointer types
#   TvgCanvas* {.importc: "Tvg_Canvas", header: hdr, bycopy.} = object
#   TvgPaint* {.importc: "Tvg_Paint", header: hdr, bycopy.} = object
#   TvgGradient* {.importc: "Tvg_Gradient", header: hdr, bycopy.} = object
#   TvgSaver* {.importc: "Tvg_Saver", header: hdr, bycopy.} = object
#   TvgAnimation* {.importc: "Tvg_Animation", header: hdr, bycopy.} = object
#   TvgAccessor* {.importc: "Tvg_Accessor", header: hdr, bycopy.} = object

#   # Data structures
#   TvgColorStop* {.importc: "Tvg_Color_Stop", header: hdr, bycopy.} = object
#     offset*: cfloat
#     r*, g*, b*, a*: uint8

#   TvgPoint* {.importc: "Tvg_Point", header: hdr, bycopy.} = object
#     x*, y*: cfloat

#   TvgMatrix* {.importc: "Tvg_Matrix", header: hdr, bycopy.} = object
#     e11*, e12*, e13*: cfloat
#     e21*, e22*, e23*: cfloat
#     e31*, e32*, e33*: cfloat

# # Path command constants
# const
#   TvgPathCommandClose* = 0'u8
#   TvgPathCommandMoveTo* = 1'u8
#   TvgPathCommandLineTo* = 2'u8
#   TvgPathCommandCubicTo* = 3'u8

# # Global library handle - make it accessible to other modules
# var
  # thorvgLib*: LibHandle

# # Function pointer types
# type
#   # Engine functions
#   TvgEngineInitProc = proc(threads: cuint): TvgResult {.cdecl.}
#   TvgEngineTermProc = proc(): TvgResult {.cdecl.}
#   TvgEngineVersionProc = proc(major, minor, micro: ptr uint32, version: ptr cstring): TvgResult {.cdecl.}

#   # Canvas functions
#   TvgSwCanvasCreateProc = proc(): TvgCanvas {.cdecl.}
#   TvgSwCanvasSetTargetProc = proc(canvas: TvgCanvas, buffer: ptr uint32, stride, w, h: uint32, cs: TvgColorspace): TvgResult {.cdecl.}
#   TvgCanvasDestroyProc = proc(canvas: TvgCanvas): TvgResult {.cdecl.}
#   TvgCanvasPushProc = proc(canvas: TvgCanvas, paint: TvgPaint): TvgResult {.cdecl.}
#   TvgCanvasUpdateProc = proc(canvas: TvgCanvas): TvgResult {.cdecl.}
#   TvgCanvasDrawProc = proc(canvas: TvgCanvas, clear: bool): TvgResult {.cdecl.}
#   TvgCanvasSyncProc = proc(canvas: TvgCanvas): TvgResult {.cdecl.}

#   # Paint functions
#   TvgPaintDelProc = proc(paint: TvgPaint): TvgResult {.cdecl.}
#   TvgPaintScaleProc = proc(paint: TvgPaint, factor: cfloat): TvgResult {.cdecl.}
#   TvgPaintRotateProc = proc(paint: TvgPaint, degree: cfloat): TvgResult {.cdecl.}
#   TvgPaintTranslateProc = proc(paint: TvgPaint, x, y: cfloat): TvgResult {.cdecl.}
#   TvgPaintSetTransformProc = proc(paint: TvgPaint, m: ptr TvgMatrix): TvgResult {.cdecl.}
#   TvgPaintGetTransformProc = proc(paint: TvgPaint, m: ptr TvgMatrix): TvgResult {.cdecl.}
#   TvgPaintSetOpacityProc = proc(paint: TvgPaint, opacity: uint8): TvgResult {.cdecl.}
#   TvgPaintGetOpacityProc = proc(paint: TvgPaint, opacity: ptr uint8): TvgResult {.cdecl.}
#   TvgPaintDuplicateProc = proc(paint: TvgPaint): TvgPaint {.cdecl.}

#   # Shape functions
#   TvgShapeNewProc = proc(): TvgPaint {.cdecl.}
#   TvgShapeResetProc = proc(paint: TvgPaint): TvgResult {.cdecl.}
#   TvgShapeMoveToProc = proc(paint: TvgPaint, x, y: cfloat): TvgResult {.cdecl.}
#   TvgShapeLineToProc = proc(paint: TvgPaint, x, y: cfloat): TvgResult {.cdecl.}
#   TvgShapeCubicToProc = proc(paint: TvgPaint, cx1, cy1, cx2, cy2, x, y: cfloat): TvgResult {.cdecl.}
#   TvgShapeCloseProc = proc(paint: TvgPaint): TvgResult {.cdecl.}
#   TvgShapeAppendRectProc = proc(paint: TvgPaint, x, y, w, h, rx, ry: cfloat, cw: bool): TvgResult {.cdecl.}
#   TvgShapeAppendCircleProc = proc(paint: TvgPaint, cx, cy, rx, ry: cfloat, cw: bool): TvgResult {.cdecl.}
#   TvgShapeSetFillColorProc = proc(paint: TvgPaint, r, g, b, a: uint8): TvgResult {.cdecl.}
#   TvgShapeGetFillColorProc = proc(paint: TvgPaint, r, g, b, a: ptr uint8): TvgResult {.cdecl.}
#   TvgShapeSetStrokeWidthProc = proc(paint: TvgPaint, width: cfloat): TvgResult {.cdecl.}
#   TvgShapeSetStrokeColorProc = proc(paint: TvgPaint, r, g, b, a: uint8): TvgResult {.cdecl.}

# # Function pointers
# var
#   tvgEngineInit*: TvgEngineInitProc
#   tvgEngineTerm*: TvgEngineTermProc
#   tvgEngineVersion*: TvgEngineVersionProc
#   tvgSwCanvasCreate*: TvgSwCanvasCreateProc
#   tvgSwCanvasSetTarget*: TvgSwCanvasSetTargetProc
#   tvgCanvasDestroy*: TvgCanvasDestroyProc
#   tvgCanvasPush*: TvgCanvasPushProc
#   tvgCanvasUpdate*: TvgCanvasUpdateProc
#   tvgCanvasDraw*: TvgCanvasDrawProc
#   tvgCanvasSync*: TvgCanvasSyncProc
#   tvgPaintDel*: TvgPaintDelProc
#   tvgPaintScale*: TvgPaintScaleProc
#   tvgPaintRotate*: TvgPaintRotateProc
#   tvgPaintTranslate*: TvgPaintTranslateProc
#   tvgPaintSetTransform*: TvgPaintSetTransformProc
#   tvgPaintGetTransform*: TvgPaintGetTransformProc
#   tvgPaintSetOpacity*: TvgPaintSetOpacityProc
#   tvgPaintGetOpacity*: TvgPaintGetOpacityProc
#   tvgPaintDuplicate*: TvgPaintDuplicateProc
#   tvgShapeNew*: TvgShapeNewProc
#   tvgShapeReset*: TvgShapeResetProc
#   tvgShapeMoveTo*: TvgShapeMoveToProc
#   tvgShapeLineTo*: TvgShapeLineToProc
#   tvgShapeCubicTo*: TvgShapeCubicToProc
#   tvgShapeClose*: TvgShapeCloseProc
#   tvgShapeAppendRect*: TvgShapeAppendRectProc
#   tvgShapeAppendCircle*: TvgShapeAppendCircleProc
#   tvgShapeSetFillColor*: TvgShapeSetFillColorProc
#   tvgShapeGetFillColor*: TvgShapeGetFillColorProc
#   tvgShapeSetStrokeWidth*: TvgShapeSetStrokeWidthProc
#   tvgShapeSetStrokeColor*: TvgShapeSetStrokeColorProc

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
