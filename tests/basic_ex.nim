import std/math, std/times, std/monotimes
import sdl2
import opengl
import opengl/glu
import thorvg, thorvg/[canvases, paints, shapes, gradients, scenes]
import chroma

var cnt = 0

var
  rect: Shape
  circle: Shape
  gradShape: Shape
  grad: Gradient
  scene: Scene
  bck: Shape

proc testBasicFunctionality*(canvas: Canvas) =
  cnt.inc()

  # Test shape creation
  rect.init(canvas)

  rect.appendRect(450 + 100 * sin(cnt.float * 0.01), 150 + 100 * cos(cnt.float * 0.01), 40, 40)
  rect.setFillColor(rgb(255, 0, 0))
  rect.setStrokeColor(rgb(255, 162, 0).asColor().spin(toFloat(cnt mod 100)))
  rect.setStrokeWidth(2.0)

  circle.init(canvas)

  circle.appendCircle(50, 50, 20)
  circle.setFillColor(rgba(0, 255, 0, 128))
  
  # Test gradient
  if grad.isNil:
    grad = newLinearGradient(0, 0, 200, 200)
      .stops(
        colorStop(0.0, rgb(255, 0, 0)),
        colorStop(1.0, rgb(0, 0, 255))
      )

  gradShape.init(canvas)

  gradShape.appendRect(100, 20, 200 + 50 * sin(cnt.float * 0.01), 200 + 50 * cos(cnt.float * 0.01))
  gradShape.setGradient(grad)
  
  # Test transformations
  circle.translate(200, 100)
  circle.rotate(45)
  circle.scale(4.2)
  
  # # Test canvas operations
  # canvas.push(rect)
  # canvas.push(circle)
  # canvas.push(gradShape)
  canvas.update()


proc testScene*(canvas: Canvas) =
  cnt.inc()

  bck.init(canvas)
  bck.appendRect(0, 0, canvas.width().float, canvas.height().float)
  bck.setFillColor(rgb(255, 255, 255))
  bck.setStrokeColor(rgb(0, 0, 0))
  bck.setStrokeWidth(1.0)

  scene.init(canvas)

  # Test shape creation
  rect.init(canvas)

  rect.appendRect(450 + 100 * sin(cnt.float * 0.01), 150 + 100 * cos(cnt.float * 0.01), 40, 40)
  rect.setFillColor(rgb(255, 0, 0))
  rect.setStrokeColor(rgb(255, 162, 0).asColor().spin(toFloat(cnt mod 100)))
  rect.setStrokeWidth(2.0)

  if circle.isNil:
    circle = newShape()
    scene.push(circle)
  else:
    circle.reset()

  circle.appendCircle(50, 50, 20)
  circle.setFillColor(rgba(0, 255, 0, 128))
  
  # Test gradient
  if grad.isNil:
    grad = newLinearGradient(0, 0, 200, 200)
      .stops(
        colorStop(0.0, rgb(255, 0, 0)),
        colorStop(1.0, rgb(0, 0, 255))
      )

  if gradShape.isNil:
    gradShape = newShape()
    scene.push(gradShape)
  else:
    gradShape.reset()

  gradShape.appendRect(100, 20, 200 + 50 * sin(cnt.float * 0.01), 200 + 50 * cos(cnt.float * 0.01))
  gradShape.setGradient(grad)
  
  # Test transformations
  circle.translate(200, 100)
  circle.rotate(45)
  circle.scale(4.2)
  
  # # Test canvas operations
  # canvas.push(rect)
  # canvas.push(circle)
  # canvas.push(gradShape)
  canvas.update()
