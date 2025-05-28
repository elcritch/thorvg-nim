## ThorVG Nim Wrapper Example
## 
## This example demonstrates the usage of the ThorVG Nim wrapper
import std/math

import thorvg, thorvg/[canvas, paint, shape]

proc main() =
  # Load the ThorVG library
  
  
  # Get version info
  let version = getVersion()
  echo "ThorVG Version: ", version.version
  echo "Major: ", version.major, ", Minor: ", version.minor, ", Micro: ", version.micro
  
  # Create a software canvas
  let canvas = newSwCanvas()
  canvas.setTarget(800, 600, tvgArgb8888)
  
  # Create shapes using fluent API
  let rect = newRect(50, 50, 200, 150, rx = 10)
    .fill(rgb(255, 100, 100))
    .stroke(rgb(0, 0, 0), width = 3.0)
  
  let circle = newCircle(400, 200, 80)
    .fill(rgba(100, 255, 100, 200))
    .stroke(rgb(0, 0, 255), width = 2.0)
  
  # Create a complex shape using path builder
  let star = newShape()
  var path = star.path()
  
  # Draw a 5-pointed star
  let centerX = 600.0
  let centerY = 400.0
  let outerRadius = 60.0
  let innerRadius = 25.0
  
  for i in 0..9:
    let angle = float(i) * PI / 5.0
    let radius = if i mod 2 == 0: outerRadius else: innerRadius
    let x = centerX + radius * cos(angle)
    let y = centerY + radius * sin(angle)
    
    if i == 0:
      path.moveTo(x, y)
    else:
      path.lineTo(x, y)
  
  path.close()
  star.fill(rgb(255, 255, 0)).stroke(rgb(255, 0, 0), width = 2.0)
  
  # Apply transformations
  circle.rotate(45.0)
  star.scale(1.2)
  star.translate(50, -50)
  
  # Add shapes to canvas
  canvas.push(rect.handle)
  canvas.push(circle.handle)
  canvas.push(star.handle)
  
  # Render the scene
  canvas.render()
  
  # Get the buffer (for saving to file or displaying)
  let buffer = canvas.getBuffer()
  echo "Rendered ", buffer.len, " pixels"
  
  # You could save the buffer to a file here
  # saveBufferToPNG(buffer, canvas.dimensions.width, canvas.dimensions.height, "output.png")
  
  # termEngine()
  # unloadThorVG()

when isMainModule:
  # Initialize the engine
  let engine = initThorEngine(threads = 4)
  main() 