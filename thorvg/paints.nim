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
  
  Paint* = object of PaintObj

  Matrix* = Tvg_Matrix

proc `=destroy`*(paint: var PaintObj) =
  if paint.handle != nil:
    # echo "destroy paint:", paint.handle.repr
    # echo "destroy paint: count: ", tvg_paint_unref(paint.handle, true)
    paint.handle = nil

proc isNil*(paint: Paint): bool =
  paint.handle == nil

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

proc newPicture*(): Paint =
  ## Create a new Picture
  let handle = tvg_picture_new()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create picture")
  result = Paint(handle: handle)

proc matrix*(e11, e12, e13, e21, e22, e23, e31, e32, e33: float): Matrix =
  ## Create a new Matrix
  result = Matrix(
    e11: e11.cfloat, e12: e12.cfloat, e13: e13.cfloat,
    e21: e21.cfloat, e22: e22.cfloat, e23: e23.cfloat,
    e31: e31.cfloat, e32: e32.cfloat, e33: e33.cfloat
  )

proc load*(picture: Paint, path: string) =
  ## Load a picture from a file
  checkResult(tvg_picture_load(picture.handle, path.cstring))

proc getPictureSize*(picture: Paint): (float, float) =
  ## Get the size of the picture
  var w, h: cfloat
  checkResult(tvg_picture_get_size(picture.handle, addr w, addr h))
  result = (w.float, h.float)

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

proc setTransform*(paint: Paint, transform: Matrix) =
  ## Set the paint's transformation matrix
  checkResult(tvgPaintSetTransform(paint.handle, addr transform))

proc getTransform*(paint: Paint): Matrix =
  ## Get the paint's transformation matrix
  var matrix: Matrix
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
proc identityMatrix*(): Matrix =
  ## Create an identity transformation matrix
  result = Matrix(
    e11: 1.0, e12: 0.0, e13: 0.0,
    e21: 0.0, e22: 1.0, e23: 0.0,
    e31: 0.0, e32: 0.0, e33: 1.0
  )

proc translationMatrix*(x, y: float): Matrix =
  ## Create a translation matrix
  result = identityMatrix()
  result.e13 = x.cfloat
  result.e23 = y.cfloat

proc scaleMatrix*(sx, sy: float): Matrix =
  ## Create a scale matrix
  result = identityMatrix()
  result.e11 = sx.cfloat
  result.e22 = sy.cfloat

proc rotationMatrix*(degrees: float): Matrix =
  ## Create a rotation matrix
  let radians = degrees * PI / 180.0
  let cos_val = cos(radians).cfloat
  let sin_val = sin(radians).cfloat
  
  result = Matrix(
    e11: cos_val, e12: -sin_val, e13: 0.0,
    e21: sin_val, e22: cos_val, e23: 0.0,
    e31: 0.0, e32: 0.0, e33: 1.0
  )
