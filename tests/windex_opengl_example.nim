import std/os

import opengl
import opengl/glu
import thorvg, thorvg/[canvases, paints, shapes, gradients]
import windex

import figuro_opengl

import basic_ex

when defined(macosx):
  {.passC: "-Wno-incompatible-function-pointer-types".}
  {.passC: "-I/opt/homebrew/include".}
  {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
elif defined(windows):
  {.passC: "-I/usr/local/include".}
else:
  {.passC: "-I/usr/local/include".}

var screenWidth: cint = 640
var screenHeight: cint = 480

proc setupWindow*(
    window: Window,
) =
  window.visible = true
  window.makeContextCurrent()

  window.onCloseRequest = proc() =
    echo "onCloseRequest"
    quit(0)

  window.onMove = proc() =
    discard


proc newWindexWindow*(): Window =
  let window = newWindow("Example", ivec2(screenWidth, screenHeight), visible = false, vsync = true)
  result = window
  startOpenGL(openglVersion)

  setupWindow(window)

  glEnable(GL_MULTISAMPLE)


let engine = initThorEngine(threads = 4)

let window = newWindexWindow()
let glcontext = window.rawOpenglContext()

echo "glcontext: ", glcontext.repr()

let canvas = newGlCanvas()
canvas.setTarget(glcontext, 0, screenWidth, screenHeight, ColorspaceABGR8888S)

var basics: seq[BasicEx] = @[
  BasicEx(start: vec2(0, 0)),
  BasicEx(start: vec2(1 * screenWidth.float, 0 * screenHeight.float)),
  BasicEx(start: vec2(0 * screenWidth.float, 1 * screenHeight.float)),
]

proc draw(self: var seq[BasicEx]) =
  # testBasicFunctionality(canvas)
  for basic in self.mitems():
    testScene(canvas, basic)

  canvas.draw(true)
  canvas.sync()
  window.swapBuffers()

window.onResize = proc() =
  let size = window.size
  # echo "resize:: ", size
  canvas.setTarget(glcontext, 0, size.x, size.y)
  glViewport(0, 0, size.x, size.y);  #// Note: OpenGL Y is flipped

  draw(basics)

window.size = ivec2(4*screenWidth, 4*screenHeight)

while true:
  windex.pollEvents()

  draw(basics)

  os.sleep(15)
