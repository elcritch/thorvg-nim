import std/math, std/times, std/monotimes
import sdl2
import opengl
import opengl/glu
import thorvg, thorvg/[canvases, paints, shapes, gradients]
import chroma

var cnt = 0

proc testBasicFunctionality*(canvas: Canvas) =
  cnt.inc()

  # Test shape creation
  let rect = newRect(450 + 100 * sin(cnt.float * 0.01), 150 + 100 * cos(cnt.float * 0.01), 40, 40)
    .fill(rgb(255, 0, 0))
    .stroke(rgb(255, 162, 0).asColor().spin(toFloat(cnt mod 100)), width = 2.0)

  let circle = newCircle(50, 50, 20)
    .fill(rgba(0, 255, 0, 128))
  
  # Test gradient
  let grad = newLinearGradient(0, 0, 200, 200)
    .stops(
      colorStop(0.0, rgb(255, 0, 0)),
      colorStop(1.0, rgb(0, 0, 255))
    )
  
  let gradShape = newRect(100, 20, 200 + 50 * sin(cnt.float * 0.01), 200 + 50 * cos(cnt.float * 0.01))
    .fill(grad)
  
  # Test transformations
  circle.translate(200, 100)
  circle.rotate(45)
  circle.scale(4.2)
  
  # Test canvas operations
  canvas.push(rect)
  canvas.push(circle)
  canvas.push(gradShape)