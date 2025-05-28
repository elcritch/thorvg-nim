
## ThorVG Capi Example Port to Nim
## 
## This is a port of the examples/Capi.cpp example to Nim using the ThorVG wrapper

{.passc: gorge("pkg-config --cflags sdl2").}
{.passl: gorge("pkg-config --libs sdl2").}

import std/[math, strutils]
import thorvg, thorvg/[canvases, paints, shapes, gradients]

import sdl2

discard sdl2.init(INIT_EVERYTHING)

const
  WIDTH = 800'u32
  HEIGHT = 800'u32

var
  animation: Tvg_Animation
  canvas: SwCanvas

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

  # Masked picture
  when false:
    # Set a picture
    # Note: In a real implementation, you'd need to provide the actual path to tiger.svg
    try:
      let pict = newPicture()
      pict.load("tiger.svg")
      let (w, h) = pict.getPictureSize()
      pict.scale(0.5)
      pict.setTransform(matrix(0.8, 0.0, 400.0, 0.0, 0.8, 400.0, 0.0, 0.0, 1.0))

      # Set a composite shape
      let comp = newShape()
      comp.appendCircle(600.0, 600.0, 100.0, 100.0, true)
      comp.setFillColor(rgb(0, 0, 0))
      pict.setMaskMethod(comp, TVG_MASK_METHOD_INVERSE_ALPHA)

      # Push the picture into the canvas
      canvas.push(pict)
    except ThorVGError as e:
      echo "Problem with loading the picture: ", e.msg

  # Animation with a picture
  when false:
    animation = tvgAnimationNew()
    let pictLottie = tvgAnimationGetPicture(animation)
    # Note: In a real implementation, you'd need to provide the actual path to sample.json
    let loadResult = tvgPictureLoad(pictLottie, "sample.json")
    if loadResult != tvgSuccess:
      echo "Problem with loading a lottie file"
      discard tvgAnimationDel(animation)
      animation = nil
    else:
      checkResult(tvgPaintScale(pictLottie, 0.75))
      checkResult(tvgCanvasPush(canvas.handle, pictLottie))

  # Text 1
  when false:
    # Load from a file
    # Note: In a real implementation, you'd need to provide the actual path to the font
    let fontResult = tvgFontLoad("SentyCloud.ttf")
    if fontResult != tvgSuccess:
      echo "Problem with loading the font from the file. Did you enable TTF Loader?"

    let text = tvgTextNew()
    text.setFont("SentyCloud", 25.0, "")
    text.setFillColor(0, 0, 255)
    text.setText("\xE7\xB4\xA2\xE5\xB0\x94\x56\x47\x20\xE6\x98\xAF\xE6\x9C\x80\xE5\xA5\xBD\xE7\x9A\x84")
    text.translate(50.0, 380.0)
    canvas.push(text)

  # Text 2
  when false:
    # Note: In a real implementation, you'd load font data from memory
    # This is a simplified version
    let fontDataResult = loadFontData("Arial", nil, 0, "ttf", true)
    if fontDataResult != tvgSuccess:
      echo "Problem with loading the font file from memory. Did you enable TTF Loader?"

    let grad = newRadialGradient(200.0, 200.0, 20.0, 200.0, 200.0, 0.0)
    var colorStops = [
      TvgColorStop(offset: 0.0, r: 255, g: 0, b: 255, a: 255),
      TvgColorStop(offset: 1.0, r: 0, g: 0, b: 255, a: 255)
    ]
    grad.setColorStops(colorStops)
    grad.setSpread(TVG_STROKE_FILL_REFLECT)

    let text = newText()
    text.setFont("Arial", 20.0, "italic")
    text.setGradient(grad)
    text.setText("ThorVG is the best")
    text.translate(70.0, 420.0)
    canvas.push(text)

proc progress(elapsed: uint32, durationInSec: float): float =
  ## Calculate animation progress
  let duration = uint32(durationInSec * 1000.0) # sec -> millisec
  let clamped = elapsed mod duration
  result = float(clamped) / float(duration)

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
  ## Main function - port of main() from Capi.cpp
  
  # Initialize ThorVG engine
  let engine = initThorEngine(4)
  
  echo "ThorVG Example (Software)"
  
  let window = createWindow("ThorVG Example (Software)", 10, 10, WIDTH.cint, HEIGHT.cint, SDL_WINDOW_SHOWN)

  if window.isNil:
    echo "Failed to create window: ", getError()
    quit(1)

  # Get the window surface
  let surface = getSurface(window)
  if surface.isNil:
    echo "Failed to get window surface: ", getError()
    destroyWindow(window)
    quit(1)

  # Create the canvas
  canvas = newSwCanvas()
  canvas.setTarget(cast[ptr uint32](surface.pixels), uint32(surface.pitch div 4), uint32(surface.w), uint32(surface.h), TVG_COLORSPACE_ARGB8888)
  
  var running = true
  var event: Event
  var frame = 0

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

    # Draw some animated content
    let centerX = int(WIDTH div 2)
    let centerY = int(HEIGHT div 2)
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
    
    # Small delay to control frame rate
    delay(16) # ~60 FPS
    frame += 1


  # Create content
  # contents()
  
    # Clear surface to black
  let blackColor = makeColor(0, 0, 0)
  for y in 0..<surface.h:
    for x in 0..<surface.w:
      setPixel(surface, x, y, blackColor)

  # Display the first frame
  # canvas.draw(false)
  # canvas.sync()

  let res = updateSurface(window)
  if res != SdlSuccess:
    echo "Failed to update surface: ", getError()
    quit(1)

  echo "Rendered first frame"

  
  # Simulate main loop (simplified version without SDL)
  var elapsed = 0'u32
  let maxFrames = 100 # Simulate 100 frames
  
  for frame in 0..<maxFrames:
    # Update the animation
    # if animation != nil:
    #   var duration, totalFrame: cfloat
    #   checkResult(tvgAnimationGetDuration(animation, addr duration))
    #   checkResult(tvgAnimationGetTotalFrame(animation, addr totalFrame))
    #   let frameNo = totalFrame * progress(elapsed, duration)
    #   checkResult(tvgAnimationSetFrame(animation, frameNo))
    
    # Draw the canvas
    # canvas.draw(false)
    # canvas.sync()
    let res = updateSurface(window)
    echo "updateSurface: ", res
    
    # Simulate time progression
    elapsed += 16 # ~60 FPS
    
    if frame mod 10 == 0:
      echo "Frame ", frame, " rendered"
  
  echo "Animation complete"
  
  # Get final buffer
  let buffer = canvas.getBuffer()
  echo "Final buffer size: ", buffer.len, " pixels"

  destroyWindow(window)
  sdl2.quit()
  echo "SDL2 Surface Example completed successfully" 

when isMainModule:
  main() 