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
  result = Scene()
  result.handle = handle
  assert result.handle != nil

proc push*(scene: Scene, paint: Paint) =
  ## Push the paint to the scene
  checkResult(tvg_scene_push(scene.handle, paint.handle))

proc init*(scene: var Scene, canvas: Canvas, reset: bool = true): bool {.discardable.} =
  if scene.handle == nil:
    scene = newScene()
    canvas.push(scene)
    result = true

proc dropShadow*(scene: Scene,
                 r, g, b, a: uint8;
                 angle, distance, sigma: float;
                 quality: int) =
  ## Apply DropShadow post effect (r, g, b, a, angle, distance, sigma of blurness, quality)
  when defined(thorvgSceneEffects):
    checkResult: tvg_scene_push_drop_shadow(scene.handle,
      r.cint, g.cint, b.cint, a.cint,
      angle.cdouble, distance.cdouble, sigma.cdouble,
      quality.cint
    )

proc resetEffects*(scene: Scene) =
  ## Clear all effects
  when defined(thorvgSceneEffects):
    checkResult: tvg_scene_reset_effects(scene.handle)
