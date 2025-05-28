## SDL2 Surface Example
## 
## This example demonstrates how to use getSurface and updateSurface
## to draw directly to the window surface in SDL2 with Nim
{.passc: gorge("pkg-config --cflags sdl2").}
{.passl: gorge("pkg-config --libs sdl2").}

when defined(macosx):
  {.passC: "-I/opt/homebrew/include".}
  {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
elif defined(windows):
  {.passC: "-I/usr/local/include".}
else:
  {.passC: "-I/usr/local/include".}

import sdl2
import std/[random, math]
import sdl2

import thorvg, thorvg/[canvases, paints, shapes, gradients]

proc contents() =
  ## Create the scene content (port of contents() function from Capi.cpp)
  
  # Linear gradient shape with a linear gradient stroke
  block:
    # Set a shape
    let shape1 = newShape()
    shape1.moveTo(25.0, 25.0)
    shape1.lineTo(375.0, 25.0)
    shape1.cubicTo(500.0, 100.0, -500.0, 200.0, 375.0, 375.0)
    shape1.close()

  # Scene
  when false:
    # Set a scene
    let scene = newScene()

    # Set circles
    let sceneShape1 = newShape()
    sceneShape1.appendCircle(80.0, 650.0, 40.0, 140.0, true)
    sceneShape1.appendCircle(180.0, 600.0, 40.0, 60.0, true)
    sceneShape1.setFillColor(rgb(0, 0, 255))
    sceneShape1.setStrokeColor(rgb(75, 25, 155))
    sceneShape1.setStrokeWidth(10.0)
    sceneShape1.setStrokeCap(TVG_STROKE_CAP_ROUND)
    sceneShape1.setStrokeJoin(TVG_STROKE_JOIN_ROUND)
    sceneShape1.setTrimPath(0.25, 0.75, true)
    scene.push(sceneShape1)

proc testBasicFunctionality(canvas: SwCanvas) =
  # Test shape creation
  let rect = newRect(10, 10, 50, 30)
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

# Initialize SDL2
discard sdl2.init(INIT_EVERYTHING)

const
  WINDOW_WIDTH = 640
  WINDOW_HEIGHT = 480

# Helper function to set a pixel color
proc setPixel(surface: SurfacePtr, x, y: int, color: uint32) =
  if x >= 0 and x < surface.w and y >= 0 and y < surface.h:
    let pixels = cast[ptr UncheckedArray[uint32]](surface.pixels)
    let offset = y * (surface.pitch div 4) + x
    pixels[offset] = color

# Helper function to create a color value
proc makeColor(r, g, b: uint8): uint32 =
  # Assuming ARGB format (common on many systems)
  return (0xFF'u32 shl 24) or (r.uint32 shl 16) or (g.uint32 shl 8) or b.uint32

proc main() =
  let engine = initThorEngine(threads = 1)

  # Create window
  let window = createWindow(
    "SDL2 Surface Example", 
    100, 100, 
    WINDOW_WIDTH, WINDOW_HEIGHT, 
    SDL_WINDOW_SHOWN
  )

  if window.isNil:
    echo "Failed to create window: ", getError()
    quit(1)

  # Get the window surface
  let surface = getSurface(window)
  if surface.isNil:
    echo "Failed to get window surface: ", getError()
    destroyWindow(window)
    quit(1)

  echo "Window surface created successfully"
  echo "Surface dimensions: ", surface.w, "x", surface.h
  echo "Surface format: ", surface.format.format

  # Create the canvas
  let canvas = newSwCanvas()
  # canvas.setTarget(100, 100, TVG_COLORSPACE_ARGB8888)
  canvas.setTarget(
    cast[ptr uint32](surface.pixels),
    uint32(surface.pitch div 4),
    uint32(surface.w),
    uint32(surface.h),
     TVG_COLORSPACE_ARGB8888
  )

  # Animation variables
  var
    frame = 0
    running = true
    event: Event

  echo "Starting animation loop..."

  while running:
    # Handle events
    while pollEvent(event):
      case event.kind:
      of QuitEvent:
        running = false
      of KeyDown:
        if event.key.keysym.sym == K_ESCAPE:
          running = false
      else:
        discard

    # Lock surface if needed
    if SDL_MUSTLOCK(surface):
      if lockSurface(surface) < 0:
        echo "Failed to lock surface: ", getError()
        break

    # Clear surface to black
    let blackColor = makeColor(0, 0, 0)
    for y in 0..<surface.h:
      for x in 0..<surface.w:
        setPixel(surface, x, y, blackColor)

    testBasicFunctionality(canvas)

    canvas.render()
    # canvas.update()
    # canvas.draw(false)
    # canvas.sync()

    let res = updateSurface(window)
    if res != SdlSuccess:
      echo "Failed to update surface: ", getError()
      break

    # Draw some animated content
    let centerX = WINDOW_WIDTH div 2
    let centerY = WINDOW_HEIGHT div 2
    let radius = 50
    
    # Draw a moving circle
    let circleX = centerX + int(cos(frame.float * 0.05) * 100)
    let circleY = centerY + int(sin(frame.float * 0.05) * 50)
    
    # Draw circle by setting pixels
    for y in (circleY - radius)..(circleY + radius):
      for x in (circleX - radius)..(circleX + radius):
        let dx = x - circleX
        let dy = y - circleY
        let distance = sqrt(dx.float * dx.float + dy.float * dy.float)
        
        if distance <= radius.float:
          # Create a colorful gradient based on distance
          let intensity = uint8(255 - (distance / radius.float * 255))
          let red = uint8((sin(frame.float * 0.02) * 127 + 128) * intensity.float / 255)
          let green = uint8((sin(frame.float * 0.03 + 2) * 127 + 128) * intensity.float / 255)
          let blue = uint8((sin(frame.float * 0.04 + 4) * 127 + 128) * intensity.float / 255)
          
          setPixel(surface, x, y, makeColor(red, green, blue))

    # Unlock surface if it was locked
    if SDL_MUSTLOCK(surface):
      unlockSurface(surface)

    # Update the window surface - this is the key function!
    let updateResult = updateSurface(window)
    if updateResult != SdlSuccess:
      echo "Failed to update surface: ", getError()
      break

    # Small delay to control frame rate
    delay(16) # ~60 FPS
    
    frame += 1
    
    # Print progress every 60 frames
    if frame mod 60 == 0:
      echo "Frame: ", frame

  echo "Animation finished"

  # Cleanup
  destroyWindow(window)
  sdl2.quit()
  echo "SDL2 Surface Example completed successfully" 

when isMainModule:
  main()