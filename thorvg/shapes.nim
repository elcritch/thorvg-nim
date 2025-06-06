## ThorVG Shape Module
## 
## High-level Nim wrapper for ThorVG Shape functionality
import std/sequtils
import chroma
import vmath
export vmath

import thorvg_capi
import engine, paints, canvases
export chroma, engine, paints, canvases

type
  Shape* = object of Paint
    
  PathBuilder* = object
    shape: Shape

proc newShape*(): Shape =
  ## Create a new shape
  let handle = tvg_shape_new()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create shape")
  result = Shape()
  result.handle = handle
  # discard tvg_paint_ref(handle)
  # discard tvg_paint_unref(handle, false)

proc reset*(shape: Shape) =
  ## Reset the shape path
  checkResult(tvg_shape_reset(shape.handle))

proc init*(shape: var Shape, canvas: Canvas, reset: bool = true): bool {.discardable.} =
  if shape.handle == nil:
    shape = newShape()
    canvas.push(shape)
    result = true
  elif reset:
    shape.reset()

# Path building methods
proc moveTo*(shape: Shape, x, y: float) =
  ## Move to a point
  checkResult(tvg_shape_move_to(shape.handle, x.cfloat, y.cfloat))

proc lineTo*(shape: Shape, x, y: float) =
  ## Draw a line to a point
  checkResult(tvg_shape_line_to(shape.handle, x.cfloat, y.cfloat))

proc cubicTo*(shape: Shape, cx1, cy1, cx2, cy2, x, y: float) =
  ## Draw a cubic Bezier curve
  checkResult(tvg_shape_cubic_to(shape.handle, 
    cx1.cfloat, cy1.cfloat, cx2.cfloat, cy2.cfloat, x.cfloat, y.cfloat))

proc close*(shape: Shape) =
  ## Close the current path
  checkResult(tvg_shape_close(shape.handle))

proc addRect*(shape: Shape, x, y, width, height: float, rx: float = 0, ry: float = 0, clockwise: bool = true) =
  ## Append a rectangle to the path
  checkResult(tvg_shape_append_rect(shape.handle, 
    x.cfloat, y.cfloat, width.cfloat, height.cfloat, rx.cfloat, ry.cfloat, clockwise))

proc addCircle*(shape: Shape, center: Vec2, rx, ry: float, clockwise: bool = true) =
  ## Append an ellipse/circle to the path
  checkResult(tvg_shape_append_circle(shape.handle, 
    center[0].cfloat, center[1].cfloat, rx.cfloat, ry.cfloat, clockwise))

proc addCircle*(shape: Shape, center: Vec2, radius: float, clockwise: bool = true) =
  ## Append a circle to the path
  shape.addCircle(center, radius, radius, clockwise)

# Fill methods
proc setFillColor*(shape: Shape, color: SomeColor) =
  ## Set the fill color
  let rgba = color.asRgba()
  checkResult(tvg_shape_set_fill_color(shape.handle, rgba.r, rgba.g, rgba.b, rgba.a))

proc setFillColor*(shape: Shape, r, g, b: uint8, a: uint8 = 255) =
  ## Set the fill color from RGBA values
  shape.setFillColor(rgba(r, g, b, a))

proc getFillColor*(shape: Shape): ColorRGBA =
  ## Get the fill color
  var r, g, b, a: uint8
  checkResult(tvg_shape_get_fill_color(shape.handle, addr r, addr g, addr b, addr a))
  result = rgba(r, g, b, a)

# Stroke methods
proc setStrokeWidth*(shape: Shape, width: float) =
  ## Set the stroke width
  checkResult(tvg_shape_set_stroke_width(shape.handle, width.cfloat))

proc setStrokeColor*(shape: Shape, color: SomeColor) =
  ## Set the stroke color
  let rgba = color.asRgba()
  checkResult(tvg_shape_set_stroke_color(shape.handle, rgba.r, rgba.g, rgba.b, rgba.a))

proc setStrokeColor*(shape: Shape, r, g, b: uint8, a: uint8 = 255) =
  ## Set the stroke color from RGBA values
  shape.setStrokeColor(rgba(r, g, b, a))

proc setStrokeCap*(shape: Shape, cap: TvgStrokeCap) =
  ## Set the stroke cap
  checkResult(tvg_shape_set_stroke_cap(shape.handle, cap))

proc setStrokeJoin*(shape: Shape, join: TvgStrokeJoin) =
  ## Set the stroke join
  checkResult(tvg_shape_set_stroke_join(shape.handle, join))

proc setStrokeDash*(shape: Shape, dash: seq[cfloat], offset: float = 0.0) =
  ## Set the stroke dash
  checkResult(tvg_shape_set_stroke_dash(shape.handle, addr dash[0], dash.len.uint32, offset.cfloat))

proc setStrokeDash*(shape: Shape, dash: seq[float], offset: float = 0.0) =
  when sizeof(cfloat) == sizeof(float):
    shape.setStrokeDash(cast[seq[cfloat]](dash), offset)
  else:
    shape.setStrokeDash(dash.mapIt(it.cfloat), offset)

proc setTrimPath*(shape: Shape, start, ends: float, clockwise: bool = true) =
  ## Set the trim path
  checkResult(tvg_shape_set_trim_path(shape.handle, start.cfloat, ends.cfloat, clockwise))

proc getStrokeDash*(shape: Shape): seq[float] =
  ## Get the stroke dash
  var dash: ptr UncheckedArray[cfloat]
  var cnt: uint32
  var offset: cfloat
  checkResult(tvg_shape_get_stroke_dash(shape.handle, cast[ptr ptr cfloat](addr dash), addr cnt, addr offset))
  result = newSeq[float](cnt)
  for i in 0..<cnt:
    result[i] = dash[i]

# Path builder pattern
proc path*(shape: Shape): PathBuilder =
  ## Start building a path
  PathBuilder(shape: shape)

proc moveTo*(builder: var PathBuilder, x, y: float): PathBuilder {.discardable.} =
  builder.shape.moveTo(x, y)
  result = builder

proc lineTo*(builder: var PathBuilder, x, y: float): PathBuilder {.discardable.} =
  builder.shape.lineTo(x, y)
  result = builder

proc cubicTo*(builder: var PathBuilder, cx1, cy1, cx2, cy2, x, y: float): PathBuilder {.discardable.} =
  builder.shape.cubicTo(cx1, cy1, cx2, cy2, x, y)
  result = builder

proc close*(builder: var PathBuilder): PathBuilder {.discardable.} =
  builder.shape.close()
  result = builder

proc rect*(builder: var PathBuilder, x, y, width, height: float, rx: float = 0, ry: float = 0): PathBuilder {.discardable.} =
  builder.shape.addRect(x, y, width, height, rx, ry)
  result = builder

proc circle*(builder: var PathBuilder, center: Vec2, radius: float): PathBuilder {.discardable.} =
  builder.shape.addCircle(center, radius)
  result = builder

proc ellipse*(builder: var PathBuilder, center: Vec2, rx, ry: float): PathBuilder {.discardable.} =
  builder.shape.addCircle(center, rx, ry)
  result = builder

# Convenience constructors
proc newRect*(x, y, width, height: float, rx: float = 0, ry: float = 0): Shape =
  ## Create a rectangle shape
  result = newShape()
  result.addRect(x, y, width, height, rx, ry)

proc newCircle*(center: Vec2, radius: float): Shape =
  ## Create a circle shape
  result = newShape()
  result.addCircle(center, radius)

proc newEllipse*(center: Vec2, rx, ry: float): Shape =
  ## Create an ellipse shape
  result = newShape()
  result.addCircle(center, rx, ry)

# Method chaining for fluent API
proc fill*(shape: Shape, color: SomeColor): Shape {.discardable.} =
  shape.setFillColor(color)
  result = shape

proc fill*(shape: Shape, r, g, b: uint8, a: uint8 = 255): Shape {.discardable.} =
  shape.setFillColor(r, g, b, a)
  result = shape

proc stroke*(shape: Shape, color: SomeColor, width: float = 1.0): Shape {.discardable.} =
  let rgba = color.asRgba()
  shape.setStrokeColor(rgba)
  shape.setStrokeWidth(width)
  result = shape

proc stroke*(shape: Shape, r, g, b: uint8, width: float = 1.0, a: uint8 = 255): Shape {.discardable.} =
  shape.setStrokeColor(rgba(r, g, b, a))
  shape.setStrokeWidth(width)
  result = shape 