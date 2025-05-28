# OpenGL example using SDL2

import sdl2
import opengl
import opengl/glu
import thorvg, thorvg/[canvases, paints, shapes, gradients]


{.passc: gorge("pkg-config --cflags sdl2").}
{.passl: gorge("pkg-config --libs sdl2").}

when defined(macosx):
  {.passC: "-I/opt/homebrew/include".}
  {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
elif defined(windows):
  {.passC: "-I/usr/local/include".}
else:
  {.passC: "-I/usr/local/include".}

type GLFrameBuffer = object
  fbo: GLuint
  texture: GLuint

proc createFbo(screenWidth: cint, screenHeight: cint): GLFrameBuffer =
  result.fbo = 0
  result.texture = 0

  glGenFramebuffers(1, addr result.fbo)
  glBindFramebuffer(GL_FRAMEBUFFER_EXT, result.fbo)
  glGenTextures(1, addr result.texture)
  glBindTexture(GL_TEXTURE_2D, result.texture)
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8.GLint, screenWidth, screenHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, nil)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glFramebufferTexture2D(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, result.texture, 0)
  glBindFramebuffer(GL_FRAMEBUFFER_EXT, 0)
  glBindTexture(GL_TEXTURE_2D, 0)
  echo "FBO created: ", result.fbo


discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 640
var screenHeight: cint = 480

let engine = initThorEngine(threads = 4)

var window = createWindow("SDL/OpenGL Skeleton", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
var context = window.glCreateContext()

let canvas = newGlCanvas()
canvas.setTarget(context, 0, uint32(screenWidth), uint32(screenHeight), TVG_COLORSPACE_ABGR8888S)


# # Initialize OpenGL
discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE.cint)
discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3.cint)
discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3.cint)
# discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY.cint)

loadExtensions()

# Check actual OpenGL version
let version = cast[cstring](glGetString(GL_VERSION))
echo "OpenGL Version: ", $version
let renderer = cast[cstring](glGetString(GL_RENDERER))
echo "Renderer: ", $renderer

# glClearColor(0.0, 0.0, 0.0, 1.0)                  # Set background color to black and opaque
# glClearDepth(1.0)                                 # Set background depth to farthest
# glEnable(GL_DEPTH_TEST)                           # Enable depth testing for z-culling
# glDepthFunc(GL_LEQUAL)                            # Set the type of depth-test
# glShadeModel(GL_SMOOTH)                           # Enable smooth shading
# glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) # Nice perspective corrections

proc blitToScreen(fbo: GLFrameBuffer, posX: uint32, posY: uint32, width: uint32, height: uint32) =
  glBindFramebuffer(GL_FRAMEBUFFER_EXT, 0)
  glBindFramebuffer(GL_FRAMEBUFFER_EXT, fbo.fbo)
  glBlitFramebuffer(0, 0,
        screenWidth, screenHeight,
        posX.GLint, posY.GLint, (posX + width).GLint, (posY + height).GLint,
        GL_COLOR_BUFFER_BIT, GL_NEAREST.GLEnum)


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

proc reshape(newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window
  glMatrixMode(GL_PROJECTION)             # To operate on the projection matrix
  glLoadIdentity()                        # Reset
  gluPerspective(45.0, newWidth / newHeight, 0.1, 100.0)  # Enable perspective projection with fovy, aspect, zNear and zFar

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

# reshape(screenWidth, screenHeight) # Set up initial viewport and projection


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
        # reshape(newWidth, newHeight)

  # render()
  testBasicFunctionality(canvas)
  # canvas.setTarget(context, 0, uint32(screenWidth), uint32(screenHeight), TVG_COLORSPACE_ABGR8888S)
  canvas.draw(true)
  canvas.sync()
  # blitToScreen(fbo, 0, 0, uint32(screenWidth), uint32(screenHeight))

  window.glSwapWindow()

  limitFrameRate()

destroy window
