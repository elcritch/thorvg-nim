## ThorVG Canvas Module
## 
## High-level Nim wrapper for ThorVG Canvas functionality

import paints
export paints

type
  CanvasObj* = object of RootObj
    handle: ptr Tvg_Canvas
    width, height: uint32

  Canvas* = ref object of CanvasObj

  SwCanvas* = ref object of Canvas
    buffer: seq[uint32]
    stride: uint32
    colorspace: TvgColorspace

proc `=destroy`*(canvas: var CanvasObj) =
  echo "Destroying canvas: ", canvas.addr.repr
  if canvas.handle != nil:
    echo "Destroying canvas: ", canvas.handle.repr()
    discard tvg_canvas_destroy(canvas.handle)
  canvas.handle = nil

proc newSwCanvas*(): SwCanvas =
  ## Create a new software canvas
  result = SwCanvas()
  echo "Creating SwCanvas"
  result.handle = tvg_sw_canvas_create()
  echo "SwCanvas created: ", result.handle.repr()
  if result.handle == nil:
    raise newException(ThorVGError, "Failed to create software canvas")
  echo "SwCanvas created: ", getVersion()

proc setTarget*(canvas: SwCanvas, width, height: uint32, colorspace: TvgColorspace = TVG_COLORSPACE_ARGB8888) =
  ## Set the target buffer for the software canvas
  canvas.width = width
  canvas.height = height
  canvas.stride = width
  canvas.colorspace = colorspace
  canvas.buffer = newSeq[uint32](width * height)
  
  checkResult(tvg_swcanvas_set_target(
    canvas.handle,
    addr canvas.buffer[0],
    canvas.stride,
    width,
    height,
    colorspace
  ))

proc setTarget*(canvas: SwCanvas, buffer: ptr uint32, stride: uint32, width: uint32, height: uint32, colorspace: TvgColorspace = TVG_COLORSPACE_ARGB8888) =
  ## Set the target buffer for the software canvas
  
  checkResult(tvg_swcanvas_set_target(
    canvas.handle,
    buffer,
    stride,
    width,
    height,
    colorspace
  ))

proc getBuffer*(canvas: SwCanvas): seq[uint32] =
  ## Get the canvas buffer
  result = canvas.buffer

proc push*(canvas: Canvas, paint: Paint) =
  ## Push a paint object to the canvas
  checkResult(tvg_canvas_push(canvas.handle, paint.handle))

proc update*(canvas: Canvas) =
  ## Update all paints in the canvas
  checkResult(tvg_canvas_update(canvas.handle))

proc draw*(canvas: Canvas, clear: bool = true) =
  ## Draw all paints to the canvas
  let res = tvg_canvas_draw(canvas.handle, clear)
  echo "draw: ", res
  # checkResult(res)

proc sync*(canvas: Canvas) =
  ## Synchronize drawing operations
  let res = tvg_canvas_sync(canvas.handle)
  echo "sync: ", res
  # checkResult(res)

proc render*(canvas: Canvas, clear: bool = true) =
  ## Convenience method to update, draw and sync
  canvas.update()
  canvas.draw(clear)
  canvas.sync()

proc dimensions*(canvas: Canvas): tuple[width, height: uint32] =
  ## Get canvas dimensions
  result = (canvas.width, canvas.height) 