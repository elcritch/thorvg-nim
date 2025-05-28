## Basic test for ThorVG Nim wrapper

import thorvg, thorvg/[canvas, shape, gradient]

proc testBasicFunctionality() =
  echo "Testing ThorVG Nim wrapper..."
  
  # Test library loading
  if not loadThorVG():
    echo "❌ Failed to load ThorVG library"
    echo "Make sure ThorVG is installed and accessible"
    return
  
  echo "✅ ThorVG library loaded successfully"
  
  try:
    # Test engine initialization
    initEngine(threads = 1)
    echo "✅ Engine initialized"
    
    # Test version info
    let version = getVersion()
    echo "✅ Version: ", version.version
    
    # Test canvas creation
    let canvas = newSwCanvas()
    canvas.setTarget(100, 100, tvgArgb8888)
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
    canvas.push(rect.handle)
    canvas.push(circle.handle)
    canvas.push(gradShape.handle)
    echo "✅ Shapes added to canvas"
    
    canvas.render()
    echo "✅ Canvas rendered"
    
    let buffer = canvas.getBuffer()
    echo "✅ Buffer retrieved: ", buffer.len, " pixels"
    
    echo "🎉 All tests passed!"
    
  except ThorVGError as e:
    echo "❌ ThorVG Error: ", e.msg
  except Exception as e:
    echo "❌ Error: ", e.msg
  finally:
    termEngine()
    unloadThorVG()
    echo "✅ Cleanup completed"

when isMainModule:
  testBasicFunctionality() 