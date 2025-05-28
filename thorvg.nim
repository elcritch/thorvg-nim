## ThorVG Nim Wrapper
## 
## A comprehensive Nim wrapper for the ThorVG C API with idiomatic Nim conventions
## and dynamic library loading support.

import dynlib, os, strutils, math

const hdr = "<thorvg_capi.h>"
when defined(macosx):
  {.passC: "-I/opt/homebrew/include".}
  {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
elif defined(windows):
  {.passC: "-I/usr/local/include".}
else:
  {.passC: "-I/usr/local/include".}

when defined(windows):
  const thorvgLibName = "thorvg.dll"
elif defined(macosx):
  const thorvgLibName = "libthorvg.dylib"
else:
  const thorvgLibName = "libthorvg.so"

type
  ThorVGError* = object of CatchableError
  
  # Core types
  TvgResult* {.importc: "Tvg_Result", header: hdr.} = enum
    tvgSuccess = 0
    tvgInvalidArgument
    tvgInsufficientCondition
    tvgFailedAllocation
    tvgMemoryCorruption
    tvgNotSupported
    tvgUnknown = 255

  TvgColorspace* {.importc: "Tvg_Colorspace", header: hdr.} = enum
    tvgAbgr8888 = 0
    tvgArgb8888
    tvgAbgr8888s
    tvgArgb8888s
    tvgUnknownColorspace = 255

  TvgMaskMethod* {.importc: "Tvg_Mask_Method", header: hdr.} = enum
    tvgMaskNone = 0
    tvgMaskAlpha
    tvgMaskInverseAlpha
    tvgMaskLuma
    tvgMaskInverseLuma
    tvgMaskAdd
    tvgMaskSubtract
    tvgMaskIntersect
    tvgMaskDifference
    tvgMaskLighten
    tvgMaskDarken

  TvgBlendMethod* {.importc: "Tvg_Blend_Method", header: hdr.} = enum
    tvgBlendNormal = 0
    tvgBlendMultiply
    tvgBlendScreen
    tvgBlendOverlay
    tvgBlendDarken
    tvgBlendLighten
    tvgBlendColorDodge
    tvgBlendColorBurn
    tvgBlendHardLight
    tvgBlendSoftLight
    tvgBlendDifference
    tvgBlendExclusion
    tvgBlendHue
    tvgBlendSaturation
    tvgBlendColor
    tvgBlendLuminosity
    tvgBlendAdd
    tvgBlendHardMix

  TvgType* {.importc: "Tvg_Type", header: hdr.} = enum
    tvgTypeUndef = 0
    tvgTypeShape
    tvgTypeScene
    tvgTypePicture
    tvgTypeText
    tvgTypeLinearGrad = 10
    tvgTypeRadialGrad

  TvgPathCommand* = uint8

  TvgStrokeCap* {.importc: "Tvg_Stroke_Cap", header: hdr.} = enum
    tvgStrokeCapButt = 0
    tvgStrokeCapRound
    tvgStrokeCapSquare

  TvgStrokeJoin* {.importc: "Tvg_Stroke_Join", header: hdr.} = enum
    tvgStrokeJoinMiter = 0
    tvgStrokeJoinRound
    tvgStrokeJoinBevel

  TvgStrokeFill* {.importc: "Tvg_Stroke_Fill", header: hdr.} = enum
    tvgStrokeFillPad = 0
    tvgStrokeFillReflect
    tvgStrokeFillRepeat

  TvgFillRule* {.importc: "Tvg_Fill_Rule", header: hdr.} = enum
    tvgFillRuleNonZero = 0
    tvgFillRuleEvenOdd

  # Opaque pointer types
  TvgCanvas* {.importc: "Tvg_Canvas", header: hdr, bycopy.} = object
  TvgPaint* {.importc: "Tvg_Paint", header: hdr, bycopy.} = object
  TvgGradient* {.importc: "Tvg_Gradient", header: hdr, bycopy.} = object
  TvgSaver* {.importc: "Tvg_Saver", header: hdr, bycopy.} = object
  TvgAnimation* {.importc: "Tvg_Animation", header: hdr, bycopy.} = object
  TvgAccessor* {.importc: "Tvg_Accessor", header: hdr, bycopy.} = object

  # Data structures
  TvgColorStop* {.importc: "Tvg_Color_Stop", header: hdr, bycopy.} = object
    offset*: cfloat
    r*, g*, b*, a*: uint8

  TvgPoint* {.importc: "Tvg_Point", header: hdr, bycopy.} = object
    x*, y*: cfloat

  TvgMatrix* {.importc: "Tvg_Matrix", header: hdr, bycopy.} = object
    e11*, e12*, e13*: cfloat
    e21*, e22*, e23*: cfloat
    e31*, e32*, e33*: cfloat

# Path command constants
const
  TvgPathCommandClose* = 0'u8
  TvgPathCommandMoveTo* = 1'u8
  TvgPathCommandLineTo* = 2'u8
  TvgPathCommandCubicTo* = 3'u8

# Global library handle - make it accessible to other modules
var
  thorvgLib*: LibHandle
  thorvgEngineRunning*: bool

# Function pointer types
type
  # Engine functions
  TvgEngineInitProc = proc(threads: cuint): TvgResult {.cdecl.}
  TvgEngineTermProc = proc(): TvgResult {.cdecl.}
  TvgEngineVersionProc = proc(major, minor, micro: ptr uint32, version: ptr cstring): TvgResult {.cdecl.}

  # Canvas functions
  TvgSwCanvasCreateProc = proc(): TvgCanvas {.cdecl.}
  TvgSwCanvasSetTargetProc = proc(canvas: TvgCanvas, buffer: ptr uint32, stride, w, h: uint32, cs: TvgColorspace): TvgResult {.cdecl.}
  TvgCanvasDestroyProc = proc(canvas: TvgCanvas): TvgResult {.cdecl.}
  TvgCanvasPushProc = proc(canvas: TvgCanvas, paint: TvgPaint): TvgResult {.cdecl.}
  TvgCanvasUpdateProc = proc(canvas: TvgCanvas): TvgResult {.cdecl.}
  TvgCanvasDrawProc = proc(canvas: TvgCanvas, clear: bool): TvgResult {.cdecl.}
  TvgCanvasSyncProc = proc(canvas: TvgCanvas): TvgResult {.cdecl.}

  # Paint functions
  TvgPaintDelProc = proc(paint: TvgPaint): TvgResult {.cdecl.}
  TvgPaintScaleProc = proc(paint: TvgPaint, factor: cfloat): TvgResult {.cdecl.}
  TvgPaintRotateProc = proc(paint: TvgPaint, degree: cfloat): TvgResult {.cdecl.}
  TvgPaintTranslateProc = proc(paint: TvgPaint, x, y: cfloat): TvgResult {.cdecl.}
  TvgPaintSetTransformProc = proc(paint: TvgPaint, m: ptr TvgMatrix): TvgResult {.cdecl.}
  TvgPaintGetTransformProc = proc(paint: TvgPaint, m: ptr TvgMatrix): TvgResult {.cdecl.}
  TvgPaintSetOpacityProc = proc(paint: TvgPaint, opacity: uint8): TvgResult {.cdecl.}
  TvgPaintGetOpacityProc = proc(paint: TvgPaint, opacity: ptr uint8): TvgResult {.cdecl.}
  TvgPaintDuplicateProc = proc(paint: TvgPaint): TvgPaint {.cdecl.}

  # Shape functions
  TvgShapeNewProc = proc(): TvgPaint {.cdecl.}
  TvgShapeResetProc = proc(paint: TvgPaint): TvgResult {.cdecl.}
  TvgShapeMoveToProc = proc(paint: TvgPaint, x, y: cfloat): TvgResult {.cdecl.}
  TvgShapeLineToProc = proc(paint: TvgPaint, x, y: cfloat): TvgResult {.cdecl.}
  TvgShapeCubicToProc = proc(paint: TvgPaint, cx1, cy1, cx2, cy2, x, y: cfloat): TvgResult {.cdecl.}
  TvgShapeCloseProc = proc(paint: TvgPaint): TvgResult {.cdecl.}
  TvgShapeAppendRectProc = proc(paint: TvgPaint, x, y, w, h, rx, ry: cfloat, cw: bool): TvgResult {.cdecl.}
  TvgShapeAppendCircleProc = proc(paint: TvgPaint, cx, cy, rx, ry: cfloat, cw: bool): TvgResult {.cdecl.}
  TvgShapeSetFillColorProc = proc(paint: TvgPaint, r, g, b, a: uint8): TvgResult {.cdecl.}
  TvgShapeGetFillColorProc = proc(paint: TvgPaint, r, g, b, a: ptr uint8): TvgResult {.cdecl.}
  TvgShapeSetStrokeWidthProc = proc(paint: TvgPaint, width: cfloat): TvgResult {.cdecl.}
  TvgShapeSetStrokeColorProc = proc(paint: TvgPaint, r, g, b, a: uint8): TvgResult {.cdecl.}

# Function pointers
var
  tvgEngineInit*: TvgEngineInitProc
  tvgEngineTerm*: TvgEngineTermProc
  tvgEngineVersion*: TvgEngineVersionProc
  tvgSwCanvasCreate*: TvgSwCanvasCreateProc
  tvgSwCanvasSetTarget*: TvgSwCanvasSetTargetProc
  tvgCanvasDestroy*: TvgCanvasDestroyProc
  tvgCanvasPush*: TvgCanvasPushProc
  tvgCanvasUpdate*: TvgCanvasUpdateProc
  tvgCanvasDraw*: TvgCanvasDrawProc
  tvgCanvasSync*: TvgCanvasSyncProc
  tvgPaintDel*: TvgPaintDelProc
  tvgPaintScale*: TvgPaintScaleProc
  tvgPaintRotate*: TvgPaintRotateProc
  tvgPaintTranslate*: TvgPaintTranslateProc
  tvgPaintSetTransform*: TvgPaintSetTransformProc
  tvgPaintGetTransform*: TvgPaintGetTransformProc
  tvgPaintSetOpacity*: TvgPaintSetOpacityProc
  tvgPaintGetOpacity*: TvgPaintGetOpacityProc
  tvgPaintDuplicate*: TvgPaintDuplicateProc
  tvgShapeNew*: TvgShapeNewProc
  tvgShapeReset*: TvgShapeResetProc
  tvgShapeMoveTo*: TvgShapeMoveToProc
  tvgShapeLineTo*: TvgShapeLineToProc
  tvgShapeCubicTo*: TvgShapeCubicToProc
  tvgShapeClose*: TvgShapeCloseProc
  tvgShapeAppendRect*: TvgShapeAppendRectProc
  tvgShapeAppendCircle*: TvgShapeAppendCircleProc
  tvgShapeSetFillColor*: TvgShapeSetFillColorProc
  tvgShapeGetFillColor*: TvgShapeGetFillColorProc
  tvgShapeSetStrokeWidth*: TvgShapeSetStrokeWidthProc
  tvgShapeSetStrokeColor*: TvgShapeSetStrokeColorProc

proc checkResult*(result: TvgResult) =
  ## Check ThorVG result and raise exception if error
  if result != tvgSuccess:
    case result:
    of tvgInvalidArgument:
      raise newException(ThorVGError, "Invalid argument")
    of tvgInsufficientCondition:
      raise newException(ThorVGError, "Insufficient condition")
    of tvgFailedAllocation:
      raise newException(ThorVGError, "Failed allocation")
    of tvgMemoryCorruption:
      raise newException(ThorVGError, "Memory corruption")
    of tvgNotSupported:
      raise newException(ThorVGError, "Not supported")
    else:
      raise newException(ThorVGError, "Unknown error: " & $result)

proc loadThorVG*(libPath: string = ""): bool =
  ## Load ThorVG dynamic library
  if thorvgLib != nil:
    return true

  let path = if libPath.len > 0: libPath else: thorvgLibName
  
  thorvgLib = loadLib(path)
  if thorvgLib == nil:
    return false

  # Load function pointers
  tvgEngineInit = cast[TvgEngineInitProc](symAddr(thorvgLib, "tvg_engine_init"))
  tvgEngineTerm = cast[TvgEngineTermProc](symAddr(thorvgLib, "tvg_engine_term"))
  tvgEngineVersion = cast[TvgEngineVersionProc](symAddr(thorvgLib, "tvg_engine_version"))
  tvgSwCanvasCreate = cast[TvgSwCanvasCreateProc](symAddr(thorvgLib, "tvg_swcanvas_create"))
  tvgSwCanvasSetTarget = cast[TvgSwCanvasSetTargetProc](symAddr(thorvgLib, "tvg_swcanvas_set_target"))
  tvgCanvasDestroy = cast[TvgCanvasDestroyProc](symAddr(thorvgLib, "tvg_canvas_destroy"))
  tvgCanvasPush = cast[TvgCanvasPushProc](symAddr(thorvgLib, "tvg_canvas_push"))
  tvgCanvasUpdate = cast[TvgCanvasUpdateProc](symAddr(thorvgLib, "tvg_canvas_update"))
  tvgCanvasDraw = cast[TvgCanvasDrawProc](symAddr(thorvgLib, "tvg_canvas_draw"))
  tvgCanvasSync = cast[TvgCanvasSyncProc](symAddr(thorvgLib, "tvg_canvas_sync"))
  tvgPaintDel = cast[TvgPaintDelProc](symAddr(thorvgLib, "tvg_paint_del"))
  tvgPaintScale = cast[TvgPaintScaleProc](symAddr(thorvgLib, "tvg_paint_scale"))
  tvgPaintRotate = cast[TvgPaintRotateProc](symAddr(thorvgLib, "tvg_paint_rotate"))
  tvgPaintTranslate = cast[TvgPaintTranslateProc](symAddr(thorvgLib, "tvg_paint_translate"))
  tvgPaintSetTransform = cast[TvgPaintSetTransformProc](symAddr(thorvgLib, "tvg_paint_set_transform"))
  tvgPaintGetTransform = cast[TvgPaintGetTransformProc](symAddr(thorvgLib, "tvg_paint_get_transform"))
  tvgPaintSetOpacity = cast[TvgPaintSetOpacityProc](symAddr(thorvgLib, "tvg_paint_set_opacity"))
  tvgPaintGetOpacity = cast[TvgPaintGetOpacityProc](symAddr(thorvgLib, "tvg_paint_get_opacity"))
  tvgPaintDuplicate = cast[TvgPaintDuplicateProc](symAddr(thorvgLib, "tvg_paint_duplicate"))
  tvgShapeNew = cast[TvgShapeNewProc](symAddr(thorvgLib, "tvg_shape_new"))
  tvgShapeReset = cast[TvgShapeResetProc](symAddr(thorvgLib, "tvg_shape_reset"))
  tvgShapeMoveTo = cast[TvgShapeMoveToProc](symAddr(thorvgLib, "tvg_shape_move_to"))
  tvgShapeLineTo = cast[TvgShapeLineToProc](symAddr(thorvgLib, "tvg_shape_line_to"))
  tvgShapeCubicTo = cast[TvgShapeCubicToProc](symAddr(thorvgLib, "tvg_shape_cubic_to"))
  tvgShapeClose = cast[TvgShapeCloseProc](symAddr(thorvgLib, "tvg_shape_close"))
  tvgShapeAppendRect = cast[TvgShapeAppendRectProc](symAddr(thorvgLib, "tvg_shape_append_rect"))
  tvgShapeAppendCircle = cast[TvgShapeAppendCircleProc](symAddr(thorvgLib, "tvg_shape_append_circle"))
  tvgShapeSetFillColor = cast[TvgShapeSetFillColorProc](symAddr(thorvgLib, "tvg_shape_set_fill_color"))
  tvgShapeGetFillColor = cast[TvgShapeGetFillColorProc](symAddr(thorvgLib, "tvg_shape_get_fill_color"))
  tvgShapeSetStrokeWidth = cast[TvgShapeSetStrokeWidthProc](symAddr(thorvgLib, "tvg_shape_set_stroke_width"))
  tvgShapeSetStrokeColor = cast[TvgShapeSetStrokeColorProc](symAddr(thorvgLib, "tvg_shape_set_stroke_color"))

  # Check if all required functions were loaded
  result = tvgEngineInit != nil and tvgEngineTerm != nil and tvgSwCanvasCreate != nil

proc unloadThorVG*() =
  ## Unload ThorVG dynamic library
  if thorvgLib != nil:
    unloadLib(thorvgLib)
    thorvgLib = nil

proc getVersion*(): tuple[major, minor, micro: uint32, version: string] =
  ## Get ThorVG version
  var major, minor, micro: uint32
  var version: cstring
  checkResult(tvgEngineVersion(addr major, addr minor, addr micro, addr version))
  result = (major, minor, micro, $version) 

type ThorEngine* = object

proc termEngine*() =
  ## Terminate ThorVG engine
  if thorvgEngineRunning:
    discard tvgEngineTerm()
    thorvgEngineRunning = false

proc `=destroy`*(engine: var ThorEngine) =
  ## Destroy ThorVG engine
  termEngine()

# High-level Nim API
proc initThorEngine*(threads: uint = 0): ThorEngine =
  ## Initialize ThorVG engine
  doAssert not thorvgEngineRunning

  if not loadThorVG():
    raise newException(ThorVGError, "Failed to load ThorVG library")
  checkResult(tvgEngineInit(threads.cuint))
  thorvgEngineRunning = true
