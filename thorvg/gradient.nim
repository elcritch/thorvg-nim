## ThorVG Gradient Module
## 
## High-level Nim wrapper for ThorVG Gradient functionality

import std/dynlib

import ../thorvg, paint, shape
export thorvg, paint

# Add gradient function pointers to the main module
type
  # Gradient function types
  TvgLinearGradientNewProc = proc(): TvgGradient {.cdecl.}
  TvgRadialGradientNewProc = proc(): TvgGradient {.cdecl.}
  TvgLinearGradientSetProc = proc(grad: TvgGradient, x1, y1, x2, y2: cfloat): TvgResult {.cdecl.}
  TvgLinearGradientGetProc = proc(grad: TvgGradient, x1, y1, x2, y2: ptr cfloat): TvgResult {.cdecl.}
  TvgRadialGradientSetProc = proc(grad: TvgGradient, cx, cy, r, fx, fy, fr: cfloat): TvgResult {.cdecl.}
  TvgRadialGradientGetProc = proc(grad: TvgGradient, cx, cy, r, fx, fy, fr: ptr cfloat): TvgResult {.cdecl.}
  TvgGradientSetColorStopsProc = proc(grad: TvgGradient, colorStops: ptr TvgColorStop, cnt: uint32): TvgResult {.cdecl.}
  TvgGradientGetColorStopsProc = proc(grad: TvgGradient, colorStops: ptr ptr TvgColorStop, cnt: ptr uint32): TvgResult {.cdecl.}
  TvgGradientSetSpreadProc = proc(grad: TvgGradient, spread: TvgStrokeFill): TvgResult {.cdecl.}
  TvgGradientGetSpreadProc = proc(grad: TvgGradient, spread: ptr TvgStrokeFill): TvgResult {.cdecl.}
  TvgGradientDelProc = proc(grad: TvgGradient): TvgResult {.cdecl.}
  TvgShapeSetGradientProc = proc(paint: TvgPaint, grad: TvgGradient): TvgResult {.cdecl.}

var
  tvgLinearGradientNew: TvgLinearGradientNewProc
  tvgRadialGradientNew: TvgRadialGradientNewProc
  tvgLinearGradientSet: TvgLinearGradientSetProc
  tvgLinearGradientGet: TvgLinearGradientGetProc
  tvgRadialGradientSet: TvgRadialGradientSetProc
  tvgRadialGradientGet: TvgRadialGradientGetProc
  tvgGradientSetColorStops: TvgGradientSetColorStopsProc
  tvgGradientGetColorStops: TvgGradientGetColorStopsProc
  tvgGradientSetSpread: TvgGradientSetSpreadProc
  tvgGradientGetSpread: TvgGradientGetSpreadProc
  tvgGradientDel: TvgGradientDelProc
  tvgShapeSetGradient: TvgShapeSetGradientProc

proc loadGradientFunctions*() =
  ## Load gradient-related function pointers
  if thorvgLib == nil:
    return
    
  tvgLinearGradientNew = cast[TvgLinearGradientNewProc](symAddr(thorvgLib, "tvg_linear_gradient_new"))
  tvgRadialGradientNew = cast[TvgRadialGradientNewProc](symAddr(thorvgLib, "tvg_radial_gradient_new"))
  tvgLinearGradientSet = cast[TvgLinearGradientSetProc](symAddr(thorvgLib, "tvg_linear_gradient_set"))
  tvgLinearGradientGet = cast[TvgLinearGradientGetProc](symAddr(thorvgLib, "tvg_linear_gradient_get"))
  tvgRadialGradientSet = cast[TvgRadialGradientSetProc](symAddr(thorvgLib, "tvg_radial_gradient_set"))
  tvgRadialGradientGet = cast[TvgRadialGradientGetProc](symAddr(thorvgLib, "tvg_radial_gradient_get"))
  tvgGradientSetColorStops = cast[TvgGradientSetColorStopsProc](symAddr(thorvgLib, "tvg_gradient_set_color_stops"))
  tvgGradientGetColorStops = cast[TvgGradientGetColorStopsProc](symAddr(thorvgLib, "tvg_gradient_get_color_stops"))
  tvgGradientSetSpread = cast[TvgGradientSetSpreadProc](symAddr(thorvgLib, "tvg_gradient_set_spread"))
  tvgGradientGetSpread = cast[TvgGradientGetSpreadProc](symAddr(thorvgLib, "tvg_gradient_get_spread"))
  tvgGradientDel = cast[TvgGradientDelProc](symAddr(thorvgLib, "tvg_gradient_del"))
  tvgShapeSetGradient = cast[TvgShapeSetGradientProc](symAddr(thorvgLib, "tvg_shape_set_gradient"))

type
  GradientObj* = object of RootObj
    handle: TvgGradient
    colorStops: seq[TvgColorStop]
  Gradient* = ref object of GradientObj

  LinearGradient* = ref object of Gradient
    x1, y1, x2, y2: float

  RadialGradient* = ref object of Gradient
    cx, cy, r, fx, fy, fr: float

  ColorStop* = object
    offset*: float
    color*: Color

proc newLinearGradient*(x1, y1, x2, y2: float): LinearGradient =
  ## Create a new linear gradient
  loadGradientFunctions()
  let handle = tvgLinearGradientNew()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create linear gradient")
  
  result = LinearGradient(x1: x1, y1: y1, x2: x2, y2: y2)
  result.handle = handle
  checkResult(tvgLinearGradientSet(handle, x1.cfloat, y1.cfloat, x2.cfloat, y2.cfloat))

proc newRadialGradient*(cx, cy, r: float, fx: float = 0, fy: float = 0, fr: float = 0): RadialGradient =
  ## Create a new radial gradient
  loadGradientFunctions()
  let handle = tvgRadialGradientNew()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create radial gradient")
  
  let actualFx = if fx == 0: cx else: fx
  let actualFy = if fy == 0: cy else: fy
  
  result = RadialGradient(cx: cx, cy: cy, r: r, fx: actualFx, fy: actualFy, fr: fr)
  result.handle = handle
  checkResult(tvgRadialGradientSet(handle, cx.cfloat, cy.cfloat, r.cfloat, 
                                   actualFx.cfloat, actualFy.cfloat, fr.cfloat))

proc colorStop*(offset: float, color: Color): ColorStop =
  ## Create a color stop
  ColorStop(offset: offset, color: color)

proc colorStop*(offset: float, r, g, b: uint8, a: uint8 = 255): ColorStop =
  ## Create a color stop from RGBA values
  colorStop(offset, rgba(r, g, b, a))

proc addColorStop*(grad: Gradient, stop: ColorStop) =
  ## Add a color stop to the gradient
  let tvgStop = TvgColorStop(
    offset: stop.offset.cfloat,
    r: stop.color.r,
    g: stop.color.g,
    b: stop.color.b,
    a: stop.color.a
  )
  grad.colorStops.add(tvgStop)

proc addColorStop*(grad: Gradient, offset: float, color: Color) =
  ## Add a color stop to the gradient
  grad.addColorStop(colorStop(offset, color))

proc addColorStop*(grad: Gradient, offset: float, r, g, b: uint8, a: uint8 = 255) =
  ## Add a color stop to the gradient
  grad.addColorStop(colorStop(offset, r, g, b, a))

proc setColorStops*(grad: Gradient, stops: seq[ColorStop]) =
  ## Set all color stops for the gradient
  grad.colorStops.setLen(0)
  for stop in stops:
    grad.addColorStop(stop)

proc applyColorStops*(grad: Gradient) =
  ## Apply the color stops to the gradient
  if grad.colorStops.len > 0:
    checkResult(tvgGradientSetColorStops(grad.handle, addr grad.colorStops[0], grad.colorStops.len.uint32))

proc setSpread*(grad: Gradient, spread: TvgStrokeFill) =
  ## Set the gradient spread method
  checkResult(tvgGradientSetSpread(grad.handle, spread))

proc getSpread*(grad: Gradient): TvgStrokeFill =
  ## Get the gradient spread method
  var spread: TvgStrokeFill
  checkResult(tvgGradientGetSpread(grad.handle, addr spread))
  result = spread

# Fluent API for gradients
proc stops*(grad: Gradient, stops: seq[ColorStop]): Gradient {.discardable.} =
  grad.setColorStops(stops)
  grad.applyColorStops()
  result = grad

proc stops*(grad: Gradient, stops: varargs[ColorStop]): Gradient {.discardable.} =
  grad.setColorStops(@stops)
  grad.applyColorStops()
  result = grad

proc spread*(grad: Gradient, spread: TvgStrokeFill): Gradient {.discardable.} =
  grad.setSpread(spread)
  result = grad

# Shape gradient methods
proc setGradient*(shape: Shape, grad: Gradient) =
  ## Set a gradient fill for the shape
  grad.applyColorStops()
  checkResult(tvgShapeSetGradient(shape.handle, grad.handle))

proc fill*(shape: Shape, grad: Gradient): Shape {.discardable.} =
  ## Set gradient fill using fluent API
  shape.setGradient(grad)
  result = shape 