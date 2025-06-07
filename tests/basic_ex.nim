import std/math, std/times, std/monotimes
import thorvg, thorvg/[canvases, paints, shapes, gradients, scenes]
import chroma
import std/with
import vmath
import bumpy


type
  BasicEx* = object
    cnt: int
    scene: Scene
    rect: Shape
    circle: Shape
    gradShape: Shape
    grad: Gradient
    bck: Shape
    start*: Vec2
    stride*: int = 1

proc testBasicFunctionality*(canvas: Canvas, self: var BasicEx) =
  self.cnt.inc(self.stride)

  # Test shape creation
  self.rect.init(canvas)

  self.rect.addRect(450 + 100 * sin(self.cnt.float * 0.01), 150 + 100 * cos(self.cnt.float * 0.01), 40, 40)
  self.rect.setFillColor(rgb(255, 0, 0))
  self.rect.setStrokeColor(rgb(255, 162, 0).asColor().spin(toFloat(self.cnt mod 100)))
  self.rect.setStrokeWidth(2.0)

  self.circle.init(canvas)

  self.circle.addCircle(vec2(50, 50), 20)
  self.circle.setFillColor(rgba(0, 255, 0, 128))
  
  # Test gradient
  if self.grad.isNil:
    self.grad = newLinearGradient(0, 0, 200, 200)
    self.grad.stops(
      colorStop(0.0, rgb(255, 0, 0)),
      colorStop(1.0, rgb(0, 0, 255))
    )

  self.gradShape.init(canvas)

  self.gradShape.addRect(100, 20, 200 + 50 * sin(self.cnt.float * 0.01), 200 + 50 * cos(self.cnt.float * 0.01))
  self.gradShape.setGradient(self.grad)
  
  # Test transformations
  let circleWave = vec2(100 * sin(self.cnt.float * 0.01), 100 * cos(self.cnt.float * 0.01))
  self.circle.translate(self.start + circleWave + vec2(200, 100))
  self.circle.rotate(45)
  self.circle.scale(4.2)
  
  # # Test canvas operations

  canvas.update()


proc testScene*(canvas: Canvas, self: var BasicEx) =
  self.cnt.inc(self.stride)
  let start = self.start

  self.bck.onInit(canvas):
    self.bck.addRect(start.x, start.y, canvas.width().float, canvas.height().float)
    self.bck.setFillColor(rgb(255, 255, 255))

  self.scene.init(canvas)
  doAssert self.scene.handle != nil

  # Test shape creation
  self.rect.init(self.scene)
  self.circle.init(self.scene)
  self.gradShape.init(self.scene)

  var rect = rect(250 + 100 * sin(self.cnt.float * 0.01) + start.x,
                        150 + 100 * cos(self.cnt.float * 0.01) + start.y,
                        40, 40)

  with self.rect:
    add(rect)
    fill(rgb(255, 0, 0))
    stroke(rgb(255, 162, 0).asColor().spin(toFloat(self.cnt mod 100)).asColor())
    strokeWidth(2.0)

  let circleWave = vec2(100 * sin(self.cnt.float * 0.01), 100 * cos(self.cnt.float * 0.01))
  self.circle.add(circle(circleWave + start, 20))
    .fill(rgba(0, 255, 0, 128))
  
  # Test gradient
  if self.grad.isNil:
    self.grad = newLinearGradient(start.x, start.y, 200 + start.x, 200 + start.y)
    self.grad.stops(
      colorStop(0.0, rgb(255, 0, 0)),
      colorStop(1.0, rgb(0, 0, 255))
    )

  with self.gradShape:
    add(rect(100 + start.x, 20 + start.y, 200 + 50 * sin(self.cnt.float * 0.01), 200 + 50 * cos(self.cnt.float * 0.01)))
    setGradient(self.grad)
  
  # Test transformations
  self.circle.translate(vec2(200, 300))
  # self.circle.scale(4.2)
  
  self.scene.resetEffects()
  self.scene.dropShadow(0, 0, 0, 125, 120.0, 20.0 * 3 * cos((self.cnt.float * 0.01).float), 3.0, 100)

  # # Test canvas operations
  canvas.update()
