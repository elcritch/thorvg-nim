import thorvg_capi

import engine
import paints, canvases

type
  Scene* = object of Paint

proc `=destroy`*(scene: var Scene) =
  if scene.handle != nil:
    # discard tvg_scene_destroy(scene.handle)
    scene.handle = nil

proc newScene*(): Scene =
  ## Create a new Scene
  let handle = tvg_scene_new()
  if handle == nil:
    raise newException(ThorVGError, "Failed to create scene")
  result = Scene(handle: handle)

proc push*(scene: Scene, paint: Paint) =
  ## Push the paint to the scene
  checkResult(tvg_scene_push(scene.handle, paint.handle))

proc init*(scene: var Scene, canvas: Canvas) =
  if scene.handle == nil:
    scene = newScene()
    canvas.push(scene)
  else:
    scene.reset()