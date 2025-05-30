
import sdl2
import opengl
import opengl/glu
import thorvg, thorvg/[canvases, paints, shapes, gradients]
import windex

import figuro_opengl

{.passc: gorge("pkg-config --cflags sdl2").}
{.passl: gorge("pkg-config --libs sdl2").}

when defined(macosx):
  {.passC: "-Wno-incompatible-function-pointer-types".}
  {.passC: "-I/opt/homebrew/include".}
  {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
elif defined(windows):
  {.passC: "-I/usr/local/include".}
else:
  {.passC: "-I/usr/local/include".}

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 640
var screenHeight: cint = 480

proc setupOpenGL() =
  # # Initialize OpenGL
  discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE.cint)
  discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4.cint)
  discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1.cint)

  let engine = initThorEngine(threads = 4)

  var window = createWindow("SDL/OpenGL Skeleton", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
  var context = window.glCreateContext()

  loadExtensions()

  glClearColor(0.0, 0.0, 0.0, 1.0)                  # Set background color to black and opaque
  glClearDepth(1.0)                                 # Set background depth to farthest
  glEnable(GL_DEPTH_TEST)                           # Enable depth testing for z-culling
  glDepthFunc(GL_LEQUAL)                            # Set the type of depth-test
  glShadeModel(GL_SMOOTH)                           # Enable smooth shading
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) # Nice perspective corrections

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
    echo "resize"



proc newWindexWindow*(): Window =
  let window = newWindow("Example", ivec2(screenWidth, screenHeight), visible = false)
  result = window
  startOpenGL(openglVersion)

  setupWindow(window)



let window = newWindexWindow()


while true:
  var event: Event
  windex.pollEvents()

  window.swapBuffers()
