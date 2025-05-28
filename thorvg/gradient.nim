## ThorVG Gradient Module
## 
## High-level Nim wrapper for ThorVG Gradient functionality

import std/dynlib

import ../thorvg, paint, shape
export chroma, thorvg, paint

type
  GradientObj* = object of RootObj
    handle: ptr Tvg_Gradient
    colorStops: seq[Tvg_Color_Stop]
  Gradient* = ref object of GradientObj

  LinearGradient* = ref object of Gradient
    x1, y1, x2, y2: float

  RadialGradient* = ref object of Gradient
    cx, cy, r, fx, fy, fr: float

  ColorStop* = object
    offset*: float
    color*: ColorRGBA

proc newLinearGradient*(x1, y1, x2, y2: float): LinearGradient =
  ## Create a new linear gradient
  let handle = tvg_linear_gradient_new()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create linear gradient")
  
  result = LinearGradient(x1: x1, y1: y1, x2: x2, y2: y2)
  result.handle = handle
  checkResult(tvg_linear_gradient_set(handle, x1.cfloat, y1.cfloat, x2.cfloat, y2.cfloat))

proc newRadialGradient*(cx, cy, r: float, fx: float = 0, fy: float = 0, fr: float = 0): RadialGradient =
  ## Create a new radial gradient
  let handle = tvg_radial_gradient_new()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create radial gradient")
  
  let actualFx = if fx == 0: cx else: fx
  let actualFy = if fy == 0: cy else: fy
  
  result = RadialGradient(cx: cx, cy: cy, r: r, fx: actualFx, fy: actualFy, fr: fr)
  result.handle = handle
  checkResult(tvg_radial_gradient_set(handle, cx.cfloat, cy.cfloat, r.cfloat, 
                                   actualFx.cfloat, actualFy.cfloat, fr.cfloat))

proc colorStop*(offset: float, color: SomeColor): ColorStop =
  ## Create a color stop
  let rgba = color.asRgba()
  ColorStop(offset: offset, color: rgba)

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

proc addColorStop*(grad: Gradient, offset: float, color: ColorRGBA) =
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
    checkResult(tvg_gradient_set_color_stops(grad.handle, addr grad.colorStops[0], grad.colorStops.len.uint32))

proc setSpread*(grad: Gradient, spread: TvgStrokeFill) =
  ## Set the gradient spread method
  checkResult(tvg_gradient_set_spread(grad.handle, spread))

proc getSpread*(grad: Gradient): TvgStrokeFill =
  ## Get the gradient spread method
  var spread: TvgStrokeFill
  checkResult(tvg_gradient_get_spread(grad.handle, addr spread))
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
  checkResult(tvg_shape_set_gradient(shape.handle, grad.handle))

proc fill*(shape: Shape, grad: Gradient): Shape {.discardable.} =
  ## Set gradient fill using fluent API
  shape.setGradient(grad)
  result = shape 