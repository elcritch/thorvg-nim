## ThorVG Canvas Module
## 
## High-level Nim wrapper for ThorVG Canvas functionality

import engine, thorvg_capi

type
  Colorspace = distinct Tvg_Colorspace

  CanvasObj* = object of RootObj
    handle*: ptr Tvg_Canvas
    width, height: uint32
    colorspace: Colorspace

  Canvas* = ref object of CanvasObj

  SwCanvas* = ref object of Canvas
    buffer: seq[uint32]
    stride: uint32

  GlCanvas* = ref object of Canvas

const
  ColorspaceABGR8888* = Colorspace(TVG_COLORSPACE_ABGR8888) ## < The channels are joined in the order: alpha, blue, green, red. Colors are alpha-premultiplied.
  ColorspaceARGB8888* = Colorspace(TVG_COLORSPACE_ARGB8888) ## < The channels are joined in the order: alpha, red, green, blue. Colors are alpha-premultiplied.
  ColorspaceABGR8888S* = Colorspace(TVG_COLORSPACE_ABGR8888S) ## < The channels are joined in the order: alpha, blue, green, red. Colors are un-alpha-premultiplied. (since 0.13)
  ColorspaceARGB8888S* = Colorspace(TVG_COLORSPACE_ARGB8888S) ## < The channels are joined in the order: alpha, red, green, blue. Colors are un-alpha-premultiplied. (since 0.13)
  ColorspaceUNKNOWN* = Colorspace(TVG_COLORSPACE_UNKNOWN) ## < Unknown channel data. This is reserved for an initial ColorSpace value. (since 1.0)

proc `=destroy`*(canvas: var CanvasObj) =
  echo "Destroying canvas: ", canvas.addr.repr
  if canvas.handle != nil:
    echo "Destroying canvas: ", canvas.handle.repr()
    discard tvg_canvas_destroy(canvas.handle)
  canvas.handle = nil

proc toTvgColorspace*(colorspace: Colorspace): Tvg_Colorspace =
  cast[Tvg_Colorspace](colorspace)

proc newSwCanvas*(): SwCanvas =
  ## Create a new software canvas
  result = SwCanvas()
  echo "Creating SwCanvas"
  result.handle = tvg_sw_canvas_create()
  echo "SwCanvas created: ", result.handle.repr()
  if result.handle == nil:
    raise newException(ThorVGError, "Failed to create software canvas")
  echo "SwCanvas created: ", getVersion()

proc setInfo(canvas: Canvas, width, height: uint32, colorspace: TVG_Colorspace) =
  canvas.width = width
  canvas.height = height
  canvas.colorspace = Colorspace(colorspace)

proc setInfo*(canvas: Canvas, width, height: uint32, colorspace: Colorspace) =
  canvas.width = width
  canvas.height = height
  canvas.colorspace = colorspace

proc setTarget*(canvas: SwCanvas, width, height: uint32, colorspace: Colorspace = Colorspace(TVG_COLORSPACE_ARGB8888)) =
  ## Set the target buffer for the software canvas
  canvas.setInfo(width, height, colorspace)
  canvas.buffer = newSeq[uint32](width * height)
  
  checkResult(tvg_swcanvas_set_target(
    canvas.handle,
    addr canvas.buffer[0],
    canvas.stride,
    width,
    height,
    colorspace.toTvgColorspace()
  ))

proc setTarget*(canvas: SwCanvas, buffer: ptr uint32, stride: uint32, width: uint32, height: uint32, colorspace: TvgColorspace = TVG_COLORSPACE_ARGB8888) =
  ## Set the target buffer for the software canvas
  canvas.setInfo(width, height, colorspace)
  
  checkResult(tvg_swcanvas_set_target(
    canvas.handle,
    buffer,
    stride,
    width,
    height,
    colorspace
  ))

proc setTarget*[T](canvas: SwCanvas, buffer: T, stride: int, width: int, height: int, colorspace: Colorspace = Colorspace(TVG_COLORSPACE_ARGB8888)) =
  ## Set the target buffer for the software canvas
  setTarget(canvas, cast[ptr uint32](buffer), stride.uint32, width.uint32, height.uint32, colorspace.toTvgColorspace())

proc getBuffer*(canvas: SwCanvas): seq[uint32] =
  ## Get the canvas buffer
  result = canvas.buffer

proc newGlCanvas*(): GlCanvas =
  ## Create a new OpenGL canvas
  result = GlCanvas()
  result.handle = tvg_glcanvas_create()
  if result.handle == nil:
    raise newException(ThorVGError, "Failed to create OpenGL canvas")

proc setTarget*(canvas: GlCanvas, context: pointer, id: int32, width, height: uint32, colorspace: TvgColorspace = TVG_COLORSPACE_ARGB8888) =
  canvas.setInfo(width, height, colorspace)
  checkResult(tvg_glcanvas_set_target(
    canvas.handle,
    context,
    id,
    width,
    height,
    colorspace
  ))

proc setTarget*[T](canvas: GlCanvas, context: T, id: int, width, height: int, colorspace: Colorspace = Colorspace(ColorspaceABGR8888S)) =
  setTarget(canvas, cast[pointer](context), id.int32, width.uint32, height.uint32, colorspace.toTvgColorspace())

proc update*(canvas: Canvas) =
  ## Update all paints in the canvas
  let res = tvg_canvas_update(canvas.handle)
  checkResult(res)

proc draw*(canvas: Canvas, clear: bool = true) =
  ## Draw all paints to the canvas
  let res = tvg_canvas_draw(canvas.handle, clear)
  checkResult(res)

proc sync*(canvas: Canvas) =
  ## Synchronize drawing operations
  let res = tvg_canvas_sync(canvas.handle)
  checkResult(res)

proc render*(canvas: Canvas, clear: bool = true) =
  ## Convenience method to update, draw and sync
  canvas.update()
  canvas.draw(clear)
  canvas.sync()


proc dimensions*(canvas: Canvas): tuple[width, height: uint32] =
  ## Get canvas dimensions
  result = (canvas.width, canvas.height) 

proc width*(canvas: Canvas): uint32 =
  ## Get canvas width
  result = canvas.width

proc height*(canvas: Canvas): uint32 =
  ## Get canvas height
  result = canvas.height