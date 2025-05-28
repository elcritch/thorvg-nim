## ThorVG Shape Module
## 
## High-level Nim wrapper for ThorVG Shape functionality

import ../thorvg, paint
export thorvg, paint

type
  Shape* = ref object of Paint
    
  PathBuilder* = object
    shape: Shape

proc newShape*(): Shape =
  ## Create a new shape
  let handle = tvgShapeNew()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create shape")
  result = Shape()
  result.handle = handle
  result.owned = true

proc reset*(shape: Shape) =
  ## Reset the shape path
  checkResult(tvgShapeReset(shape.handle))

# Path building methods
proc moveTo*(shape: Shape, x, y: float) =
  ## Move to a point
  checkResult(tvgShapeMoveTo(shape.handle, x.cfloat, y.cfloat))

proc lineTo*(shape: Shape, x, y: float) =
  ## Draw a line to a point
  checkResult(tvgShapeLineTo(shape.handle, x.cfloat, y.cfloat))

proc cubicTo*(shape: Shape, cx1, cy1, cx2, cy2, x, y: float) =
  ## Draw a cubic Bezier curve
  checkResult(tvgShapeCubicTo(shape.handle, 
    cx1.cfloat, cy1.cfloat, cx2.cfloat, cy2.cfloat, x.cfloat, y.cfloat))

proc close*(shape: Shape) =
  ## Close the current path
  checkResult(tvgShapeClose(shape.handle))

proc appendRect*(shape: Shape, x, y, width, height: float, rx: float = 0, ry: float = 0, clockwise: bool = true) =
  ## Append a rectangle to the path
  checkResult(tvgShapeAppendRect(shape.handle, 
    x.cfloat, y.cfloat, width.cfloat, height.cfloat, rx.cfloat, ry.cfloat, clockwise))

proc appendCircle*(shape: Shape, cx, cy, rx, ry: float, clockwise: bool = true) =
  ## Append an ellipse/circle to the path
  checkResult(tvgShapeAppendCircle(shape.handle, 
    cx.cfloat, cy.cfloat, rx.cfloat, ry.cfloat, clockwise))

proc appendCircle*(shape: Shape, cx, cy, radius: float, clockwise: bool = true) =
  ## Append a circle to the path
  shape.appendCircle(cx, cy, radius, radius, clockwise)

# Fill methods
proc setFillColor*(shape: Shape, color: Color) =
  ## Set the fill color
  checkResult(tvgShapeSetFillColor(shape.handle, color.r, color.g, color.b, color.a))

proc setFillColor*(shape: Shape, r, g, b: uint8, a: uint8 = 255) =
  ## Set the fill color from RGBA values
  shape.setFillColor(rgba(r, g, b, a))

proc getFillColor*(shape: Shape): Color =
  ## Get the fill color
  var r, g, b, a: uint8
  checkResult(tvgShapeGetFillColor(shape.handle, addr r, addr g, addr b, addr a))
  result = rgba(r, g, b, a)

# Stroke methods
proc setStrokeWidth*(shape: Shape, width: float) =
  ## Set the stroke width
  checkResult(tvgShapeSetStrokeWidth(shape.handle, width.cfloat))

proc setStrokeColor*(shape: Shape, color: Color) =
  ## Set the stroke color
  checkResult(tvgShapeSetStrokeColor(shape.handle, color.r, color.g, color.b, color.a))

proc setStrokeColor*(shape: Shape, r, g, b: uint8, a: uint8 = 255) =
  ## Set the stroke color from RGBA values
  shape.setStrokeColor(rgba(r, g, b, a))

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
  builder.shape.appendRect(x, y, width, height, rx, ry)
  result = builder

proc circle*(builder: var PathBuilder, cx, cy, radius: float): PathBuilder {.discardable.} =
  builder.shape.appendCircle(cx, cy, radius)
  result = builder

proc ellipse*(builder: var PathBuilder, cx, cy, rx, ry: float): PathBuilder {.discardable.} =
  builder.shape.appendCircle(cx, cy, rx, ry)
  result = builder

# Convenience constructors
proc newRect*(x, y, width, height: float, rx: float = 0, ry: float = 0): Shape =
  ## Create a rectangle shape
  result = newShape()
  result.appendRect(x, y, width, height, rx, ry)

proc newCircle*(cx, cy, radius: float): Shape =
  ## Create a circle shape
  result = newShape()
  result.appendCircle(cx, cy, radius)

proc newEllipse*(cx, cy, rx, ry: float): Shape =
  ## Create an ellipse shape
  result = newShape()
  result.appendCircle(cx, cy, rx, ry)

# Method chaining for fluent API
proc fill*(shape: Shape, color: Color): Shape {.discardable.} =
  shape.setFillColor(color)
  result = shape

proc fill*(shape: Shape, r, g, b: uint8, a: uint8 = 255): Shape {.discardable.} =
  shape.setFillColor(r, g, b, a)
  result = shape

proc stroke*(shape: Shape, color: Color, width: float = 1.0): Shape {.discardable.} =
  shape.setStrokeColor(color)
  shape.setStrokeWidth(width)
  result = shape

proc stroke*(shape: Shape, r, g, b: uint8, width: float = 1.0, a: uint8 = 255): Shape {.discardable.} =
  shape.setStrokeColor(r, g, b, a)
  shape.setStrokeWidth(width)
  result = shape 