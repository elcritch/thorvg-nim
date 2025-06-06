
import opengl
import opengl/glu
import thorvg, thorvg/[canvases, paints, shapes, gradients]
import windex

import figuro_opengl

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

proc testBasicFunctionality(canvas: GlCanvas) =
  # Test shape creation
  let rect = newRect(10, 10, 150, 130)
    .fill(rgb(255, 0, 0))
    .stroke(rgb(0, 0, 0), width = 2.0)
  
  let circle = newCircle(50, 50, 20)
    .fill(rgba(0, 255, 0, 128))
  
  # Test gradient
  let grad = newLinearGradient(0, 0, 100, 100)
    .stops(
      colorStop(0.0, rgb(255, 0, 0)),
      colorStop(1.0, rgb(0, 0, 255))
    )
  
  let gradShape = newRect(20, 20, 40, 40)
    .fill(grad)
  
  # Test transformations
  circle.translate(10, 10)
  circle.rotate(45)
  circle.scale(1.2)
  
  # Test canvas operations
  canvas.push(rect)
  canvas.push(circle)
  canvas.push(gradShape)

let engine = initThorEngine(threads = 4)

let window = newWindexWindow()
let glcontext = window.rawOpenglContext()

echo "glcontext: ", glcontext.repr()

let canvas = newGlCanvas()
canvas.setTarget(cast[pointer](glcontext), 0, uint32(screenWidth), uint32(screenHeight), TVG_COLORSPACE_ABGR8888S)

# glViewport(0, screenHeight - 600, 800, 600);  #// Note: OpenGL Y is flipped

proc draw() =
  testBasicFunctionality(canvas)
  canvas.render(true)
  window.swapBuffers()

window.onResize = proc() =
  let size = window.size
  # echo "resize:: ", size
  canvas.setTarget(cast[pointer](glcontext), 0, uint32(size.x), uint32(size.y), TVG_COLORSPACE_ABGR8888S)
  screenWidth = size.x
  screenHeight = size.y
  glViewport(0, 0, size.x, size.y);  #// Note: OpenGL Y is flipped

  draw()

while true:
  windex.pollEvents()

  draw()
