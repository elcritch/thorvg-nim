import std/math, std/times, std/monotimes
import thorvg, thorvg/[canvases, paints, shapes, gradients, scenes]
import chroma
import std/with

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

  rect.addRect(450 + 100 * sin(cnt.float * 0.01), 150 + 100 * cos(cnt.float * 0.01), 40, 40)
  rect.setFillColor(rgb(255, 0, 0))
  rect.setStrokeColor(rgb(255, 162, 0).asColor().spin(toFloat(cnt mod 100)))
  rect.setStrokeWidth(2.0)

  circle.init(canvas)

  circle.addCircle(vec2(50, 50), 20)
  circle.setFillColor(rgba(0, 255, 0, 128))
  
  # Test gradient
  if grad.isNil:
    grad = newLinearGradient(0, 0, 200, 200)
      .stops(
        colorStop(0.0, rgb(255, 0, 0)),
        colorStop(1.0, rgb(0, 0, 255))
      )

  gradShape.init(canvas)

  gradShape.addRect(100, 20, 200 + 50 * sin(cnt.float * 0.01), 200 + 50 * cos(cnt.float * 0.01))
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

  bck.onInit(canvas):
    bck.addRect(0, 0, canvas.width().float, canvas.height().float)
    bck.setFillColor(rgb(255, 255, 255))

  scene.init(canvas)

  # Test shape creation
  rect.init(canvas)

  var r: Rect
  r.x = 450 + 100 * sin(cnt.float * 0.01)
  r.y = 150 + 100 * cos(cnt.float * 0.01)
  r.w = 40
  r.h = 40

  with rect.add(r):
    fill(rgb(255, 0, 0))
    stroke(rgb(255, 162, 0).asColor().spin(toFloat(cnt mod 100)))
    strokeWidth(2.0)

  circle.init(canvas)
  circle.addCircle(vec2(50, 50), 20)
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

  gradShape.addRect(100, 20, 200 + 50 * sin(cnt.float * 0.01), 200 + 50 * cos(cnt.float * 0.01))
  gradShape.setGradient(grad)
  
  # Test transformations
  circle.translate(200, 100)
  circle.rotate(45)
  circle.scale(4.2)
  
  # # Test canvas operations
  canvas.update()
