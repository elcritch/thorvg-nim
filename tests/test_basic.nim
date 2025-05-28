## Basic test for ThorVG Nim wrapper

import thorvg, thorvg/[canvases, paints, shapes, gradients]

proc testBasicFunctionality() =
  echo "Testing ThorVG Nim wrapper..."
  
  # Test library loading
  # Test engine initialization
  let engine = initThorEngine(threads = 1)
  echo "✅ Engine initialized"
  
  # Test version info
  let version = getVersion()
  echo "✅ Version: ", version.version
  
  # Test canvas creation
  let canvas = newSwCanvas()
  canvas.setTarget(100, 100, TVG_COLORSPACE_ARGB8888)
  echo "✅ Canvas created and target set"
  
  # Test shape creation
  let rect = newRect(10, 10, 50, 30)
    .fill(rgb(255, 0, 0))
    .stroke(rgb(0, 0, 0), width = 2.0)
  echo "✅ Rectangle shape created"
  
  let circle = newCircle(50, 50, 20)
    .fill(rgba(0, 255, 0, 128))
  echo "✅ Circle shape created"
  
  # Test gradient
  let grad = newLinearGradient(0, 0, 100, 100)
    .stops(
      colorStop(0.0, rgb(255, 0, 0)),
      colorStop(1.0, rgb(0, 0, 255))
    )
  
  let gradShape = newRect(20, 20, 40, 40)
    .fill(grad)
  echo "✅ Gradient shape created"
  
  # Test transformations
  circle.translate(10, 10)
  circle.rotate(45)
  circle.scale(1.2)
  echo "✅ Transformations applied"
  
  # Test canvas operations
  canvas.push(rect)
  canvas.push(circle)
  canvas.push(gradShape)
  echo "✅ Shapes added to canvas"
  
  canvas.render()
  echo "✅ Canvas rendered"
  
  let buffer = canvas.getBuffer()
  echo "✅ Buffer retrieved: ", buffer.len, " pixels"
  
  echo "🎉 All tests passed!"
  

when isMainModule:
  testBasicFunctionality() 