## ThorVG Paint Module
## 
## High-level Nim wrapper for ThorVG Paint functionality
import std/math
import chroma

export chroma
import ../thorvg
export thorvg

type
  PaintObj* = object of RootObj
    handle*: ptr Tvg_Paint
  
  Paint* = ref object of PaintObj

  Transform* = Tvg_Matrix

proc `=destroy`*(paint: var PaintObj) =
  if paint.handle != nil:
    echo "destroy paint:", paint.handle.repr
    echo "destroy paint: count: ", tvg_paint_unref(paint.handle, true)
    paint.handle = nil

proc newPaint*(handle: ptr Tvg_Paint): Paint =
  ## Create a new Paint wrapper
  if result.handle == nil:
    raise newException(ThorVGError, "Invalid paint handle")

  result = Paint(handle: handle)
  # discard tvg_paint_ref(handle)

proc newScene*(): Paint =
  ## Create a new Scene
  let handle = tvg_scene_new()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create scene")
  result = Paint(handle: handle)

proc push*(scene: Paint, paint: Paint) =
  ## Push the paint to the scene
  checkResult(tvg_scene_push(scene.handle, paint.handle))

proc pushAt*(scene: Paint, target: Paint, at: Paint) =
  ## Push the paint to the scene at a specific position
  checkResult(tvg_scene_push_at(scene.handle, target.handle, at.handle))

proc remove*(scene: Paint, paint: Paint) =
  ## Remove the paint from the scene
  checkResult(tvg_scene_remove(scene.handle, paint.handle))

proc scale*(paint: Paint, factor: float) =
  ## Scale the paint by a factor
  checkResult(tvgPaintScale(paint.handle, factor.cfloat))

proc rotate*(paint: Paint, degrees: float) =
  ## Rotate the paint by degrees
  checkResult(tvgPaintRotate(paint.handle, degrees.cfloat))

proc translate*(paint: Paint, x, y: float) =
  ## Translate the paint by x, y
  checkResult(tvgPaintTranslate(paint.handle, x.cfloat, y.cfloat))

proc setTransform*(paint: Paint, transform: Transform) =
  ## Set the paint's transformation matrix
  checkResult(tvgPaintSetTransform(paint.handle, addr transform))

proc getTransform*(paint: Paint): Transform =
  ## Get the paint's transformation matrix
  var matrix: TvgMatrix
  checkResult(tvgPaintGetTransform(paint.handle, addr matrix))
  result = matrix

proc setOpacity*(paint: Paint, opacity: uint8) =
  ## Set the paint's opacity (0-255)
  checkResult(tvgPaintSetOpacity(paint.handle, opacity))

proc getOpacity*(paint: Paint): uint8 =
  ## Get the paint's opacity
  var opacity: uint8
  checkResult(tvgPaintGetOpacity(paint.handle, addr opacity))
  result = opacity

proc duplicate*(paint: Paint): Paint =
  ## Create a duplicate of the paint
  let newHandle = tvgPaintDuplicate(paint.handle)
  if newHandle == nil:
    raise newException(ThorVGError, "Failed to duplicate paint")
  result = Paint(handle: newHandle)

# Transform helper functions
proc identityMatrix*(): TvgMatrix =
  ## Create an identity transformation matrix
  result = TvgMatrix(
    e11: 1.0, e12: 0.0, e13: 0.0,
    e21: 0.0, e22: 1.0, e23: 0.0,
    e31: 0.0, e32: 0.0, e33: 1.0
  )

proc translationMatrix*(x, y: float): TvgMatrix =
  ## Create a translation matrix
  result = identityMatrix()
  result.e13 = x.cfloat
  result.e23 = y.cfloat

proc scaleMatrix*(sx, sy: float): TvgMatrix =
  ## Create a scale matrix
  result = identityMatrix()
  result.e11 = sx.cfloat
  result.e22 = sy.cfloat

proc rotationMatrix*(degrees: float): TvgMatrix =
  ## Create a rotation matrix
  let radians = degrees * PI / 180.0
  let cos_val = cos(radians).cfloat
  let sin_val = sin(radians).cfloat
  
  result = TvgMatrix(
    e11: cos_val, e12: -sin_val, e13: 0.0,
    e21: sin_val, e22: cos_val, e23: 0.0,
    e31: 0.0, e32: 0.0, e33: 1.0
  )
