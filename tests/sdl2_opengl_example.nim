# OpenGL example using SDL2

import std/math, std/times, std/monotimes
import sdl2
import opengl
import opengl/glu
import thorvg, thorvg/[canvases, paints, shapes, gradients]

import basic_ex

{.passc: gorge("pkg-config --cflags sdl2").}
{.passl: gorge("pkg-config --libs sdl2").}

when defined(macosx):
  {.passC: "-I/opt/homebrew/include".}
  {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
elif defined(windows):
  {.passC: "-I/usr/local/include".}
else:
  {.passC: "-I/usr/local/include".}

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 640
var screenHeight: cint = 480

# # Initialize OpenGL
discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE.cint)
discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3.cint)
discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3.cint)

let engine = initThorEngine(threads = 4)

var window = createWindow("SDL/OpenGL Skeleton", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
var context = window.glCreateContext()

loadExtensions()
glClearColor(0.0, 0.0, 0.0, 1.0)                  # Set background color to black and opaque
glClearDepth(1.0)                                 # Set background depth to farthest
glEnable(GL_DEPTH_TEST)                           # Enable depth testing for z-culling
glDepthFunc(GL_LEQUAL)                            # Set the type of depth-test
# glShadeModel(GL_SMOOTH)                           # Enable smooth shading
# glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) # Nice perspective corrections

let canvas = newGlCanvas()
canvas.setTarget(context, 0, uint32(screenWidth), uint32(screenHeight), TVG_COLORSPACE_ABGR8888S)

# Check actual OpenGL version
let version = cast[cstring](glGetString(GL_VERSION))
echo "OpenGL Version: ", $version
let renderer = cast[cstring](glGetString(GL_RENDERER))
echo "Renderer: ", $renderer


proc reshape(canvas: GlCanvas, newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window
  glMatrixMode(GL_PROJECTION)             # To operate on the projection matrix
  glLoadIdentity()                        # Reset
  gluPerspective(45.0, newWidth / newHeight, 0.1, 100.0)  # Enable perspective projection with fovy, aspect, zNear and zFar
  canvas.setTarget(context, 0, uint32(newWidth), uint32(newHeight), TVG_COLORSPACE_ABGR8888S)

# Frame rate limiter

let targetFramePeriod: uint32 = 20 # 20 milliseconds corresponds to 50 fps
var frameTime: uint32 = 0

proc limitFrameRate() =
  let now = getTicks()
  if frameTime > now:
    delay(frameTime - now) # Delay to maintain steady frame rate
  frameTime += targetFramePeriod

# Main loop

var
  evt = sdl2.defaultEvent
  runGame = true

canvas.setTarget(context, 0, uint32(screenWidth), uint32(screenHeight), TVG_COLORSPACE_ABGR8888S)

var ts = getMonoTime()

while runGame:
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      runGame = false
      break
    if evt.kind == WindowEvent:
      var windowEvent = cast[WindowEventPtr](addr(evt))
      if windowEvent.event == WindowEvent_Resized:
        let newWidth = windowEvent.data1
        let newHeight = windowEvent.data2
        reshape(canvas, newWidth, newHeight)

  echo "fps: ", 1_000.0 / ((getMonoTime() - ts).inMilliseconds.toFloat)
  ts = getMonoTime()

  testBasicFunctionality(canvas)
  canvas.render(true)

  window.glSwapWindow()

  limitFrameRate()

destroy window
