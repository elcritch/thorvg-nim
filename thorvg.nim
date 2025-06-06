## ThorVG Nim Wrapper
## 
## A comprehensive Nim wrapper for the ThorVG C API with idiomatic Nim conventions
## and dynamic library loading support.

import thorvg/engine
import thorvg/canvases
import thorvg/paints
import thorvg/shapes
import thorvg/gradients
import thorvg/scenes

export engine, canvases, paints, shapes, gradients, scenes

template onInit*[T](shape: var T, canvas: Canvas, blk: untyped) =
  if init(shape, canvas, false):
    blk
