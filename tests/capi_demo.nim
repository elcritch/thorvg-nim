
## ThorVG Capi Example Port to Nim
## 
## This is a port of the examples/Capi.cpp example to Nim using the ThorVG wrapper

import std/[math, strutils]
import thorvg, thorvg/[canvases, paints, shapes, gradients]

const
  WIDTH = 800
  HEIGHT = 800

var
  animation: TvgAnimation
  canvas: Canvas

proc contents() =
  ## Create the scene content (port of contents() function from Capi.cpp)
  
  # Linear gradient shape with a linear gradient stroke
  block:
    # Set a shape
    let shape1 = tvgShapeNew()
    checkResult(tvgShapeMoveTo(shape1, 25.0, 25.0))
    checkResult(tvgShapeLineTo(shape1, 375.0, 25.0))
    checkResult(tvgShapeCubicTo(shape1, 500.0, 100.0, -500.0, 200.0, 375.0, 375.0))
    checkResult(tvgShapeClose(shape1))

  # Scene
  block:
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
  block:
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
    checkResult(tvgTextSetFont(text, "SentyCloud", 25.0, ""))
    checkResult(tvgTextSetFillColor(text, 0, 0, 255))
    checkResult(tvgTextSetText(text, "\xE7\xB4\xA2\xE5\xB0\x94\x56\x47\x20\xE6\x98\xAF\xE6\x9C\x80\xE5\xA5\xBD\xE7\x9A\x84"))
    checkResult(tvgPaintTranslate(text, 50.0, 380.0))
    checkResult(tvgCanvasPush(canvas.handle, text))

  # Text 2
  when false:
    # Note: In a real implementation, you'd load font data from memory
    # This is a simplified version
    let fontDataResult = tvgFontLoadData("Arial", nil, 0, "ttf", true)
    if fontDataResult != tvgSuccess:
      echo "Problem with loading the font file from memory. Did you enable TTF Loader?"

    let grad = tvgRadialGradientNew()
    checkResult(tvgRadialGradientSet(grad, 200.0, 200.0, 20.0, 200.0, 200.0, 0.0))
    var colorStops = [
      TvgColorStop(offset: 0.0, r: 255, g: 0, b: 255, a: 255),
      TvgColorStop(offset: 1.0, r: 0, g: 0, b: 255, a: 255)
    ]
    checkResult(tvgGradientSetColorStops(grad, addr colorStops[0], 2))
    checkResult(tvgGradientSetSpread(grad, tvgStrokeFillReflect))

    let text = tvgTextNew()
    checkResult(tvgTextSetFont(text, "Arial", 20.0, "italic"))
    checkResult(tvgTextSetGradient(text, grad))
    checkResult(tvgTextSetText(text, "ThorVG is the best"))
    checkResult(tvgPaintTranslate(text, 70.0, 420.0))
    checkResult(tvgCanvasPush(canvas.handle, text))

proc progress(elapsed: uint32, durationInSec: float): float =
  ## Calculate animation progress
  let duration = uint32(durationInSec * 1000.0) # sec -> millisec
  let clamped = elapsed mod duration
  result = float(clamped) / float(duration)

proc main() =
  ## Main function - port of main() from Capi.cpp
  
  # Initialize ThorVG engine
  let engine = initThorEngine(4)
  
  echo "ThorVG Example (Software)"
  
  # Create the canvas
  canvas = newSwCanvas()
  canvas.setTarget(WIDTH, HEIGHT, TVG_COLORSPACE_ARGB8888)
  
  # Create content
  contents()
  
  # Display the first frame
  canvas.render()
  
  echo "Rendered first frame"
  
  # Simulate main loop (simplified version without SDL)
  var elapsed = 0'u32
  let maxFrames = 100 # Simulate 100 frames
  
  for frame in 0..<maxFrames:
    # Update the animation
    if animation != nil:
      var duration, totalFrame: cfloat
      checkResult(tvgAnimationGetDuration(animation, addr duration))
      checkResult(tvgAnimationGetTotalFrame(animation, addr totalFrame))
      let frameNo = totalFrame * progress(elapsed, duration)
      checkResult(tvgAnimationSetFrame(animation, frameNo))
    
    # Draw the canvas
    canvas.render()
    
    # Simulate time progression
    elapsed += 16 # ~60 FPS
    
    if frame mod 10 == 0:
      echo "Frame ", frame, " rendered"
  
  echo "Animation complete"
  
  # Get final buffer
  let buffer = canvas.getBuffer()
  echo "Final buffer size: ", buffer.len, " pixels"

when isMainModule:
  main() 