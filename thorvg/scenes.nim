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

proc dropShadow*(scene: Scene,
                 r, g, b, a: uint8;
                 angle, distance, sigma: cfloat;
                 quality: uint8) =
  ## Apply DropShadow post effect (r, g, b, a, angle, distance, sigma of blurness, quality)
  checkResult: tvg_scene_push_effect(scene.handle,
    Tvg_Scene_Effect.TVG_SCENE_EFFECT_DROP_SHADOW, r, g, b, a, angle, distance, sigma, quality)

proc clearEffects*(scene: Scene) =
  ## Clear all effects
  checkResult: tvg_scene_push_effect(scene.handle, Tvg_Scene_Effect.TVG_SCENE_EFFECT_CLEAR_ALL)
