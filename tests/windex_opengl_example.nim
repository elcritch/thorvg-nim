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

  window.onResize = proc() =
    # updateWindowSize(renderer.frame, window)
    let size = window.size
    echo "resize:: ", size


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

var self = BasicEx()

proc draw(self: var BasicEx) =
  # testBasicFunctionality(canvas)
  testScene(canvas, self)

  canvas.draw(true)
  canvas.sync()
  window.swapBuffers()

window.onResize = proc() =
  let size = window.size
  # echo "resize:: ", size
  canvas.setTarget(glcontext, 0, size.x, size.y)
  screenWidth = size.x
  screenHeight = size.y
  glViewport(0, 0, size.x, size.y);  #// Note: OpenGL Y is flipped

  draw(self)

while true:
  windex.pollEvents()

  draw(self)

  os.sleep(15)
