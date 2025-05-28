## ThorVG Canvas Module
## 
## High-level Nim wrapper for ThorVG Canvas functionality

import ../thorvg
export thorvg

type
  CanvasObj* = object of RootObj
    handle: ptr TvgCanvas

  Canvas* = ref object of CanvasObj

  SwCanvas* = ref object of Canvas
    buffer: seq[uint32]
    stride: uint32
    colorspace: TvgColorspace


proc `=destroy`*(canvas: var CanvasObj) =
  echo "Destroying canvas: ", canvas.addr.repr
  if canvas.handle != nil:
    echo "Destroying canvas: ", canvas.handle.repr()
    discard tvgCanvasDestroy(canvas.handle)
  canvas.handle = nil

proc newSwCanvas*(): SwCanvas =
  ## Create a new software canvas
  result = SwCanvas()
  echo "Creating SwCanvas"
  result.handle = tvgSwCanvasCreate()
  echo "SwCanvas created: ", result.handle.repr()
  if result.handle == nil:
    raise newException(ThorVGError, "Failed to create software canvas")
  echo "SwCanvas created: ", getVersion()

proc setTarget*(canvas: SwCanvas, width, height: uint32, colorspace: TvgColorspace = TVG_COLORSPACE_ARGB8888) =
  ## Set the target buffer for the software canvas
  # canvas.width = width
  # canvas.height = height
  # canvas.stride = width
  # canvas.colorspace = colorspace
  # canvas.buffer = newSeq[uint32](width * height)
  
  checkResult(tvgSwCanvasSetTarget(
    canvas.handle,
    addr canvas.buffer[0],
    canvas.stride,
    width,
    height,
    colorspace
  ))

proc getBuffer*(canvas: SwCanvas): seq[uint32] =
  ## Get the canvas buffer
  result = canvas.buffer

proc push*(canvas: Canvas, paint: ptr TvgPaint) =
  ## Push a paint object to the canvas
  checkResult(tvgCanvasPush(canvas.handle, paint))

proc update*(canvas: Canvas) =
  ## Update all paints in the canvas
  checkResult(tvgCanvasUpdate(canvas.handle))

proc draw*(canvas: Canvas, clear: bool = true) =
  ## Draw all paints to the canvas
  checkResult(tvgCanvasDraw(canvas.handle, clear))

proc sync*(canvas: Canvas) =
  ## Synchronize drawing operations
  checkResult(tvgCanvasSync(canvas.handle))

proc render*(canvas: Canvas, clear: bool = true) =
  ## Convenience method to update, draw and sync
  canvas.update()
  canvas.draw(clear)
  canvas.sync()

proc dimensions*(canvas: Canvas): tuple[width, height: uint32] =
  ## Get canvas dimensions
  let width = tvgCanvasWidth(canvas.handle)
  let height = tvgCanvasHeight(canvas.handle)
  result = (width, height) 
