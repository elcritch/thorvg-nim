# ThorVG Nim Wrapper

A comprehensive, idiomatic Nim wrapper for the [ThorVG](https://github.com/thorvg/thorvg) C API with dynamic library loading support.

## Features

- **Dynamic Library Loading**: No need to link against ThorVG at compile time
- **Idiomatic Nim API**: Object-oriented design with method chaining and fluent interfaces
- **Memory Safe**: Automatic resource management with destructors
- **Type Safe**: Strong typing with proper enum mappings
- **Cross Platform**: Works on Windows, macOS, and Linux
- **Comprehensive**: Covers most ThorVG functionality including shapes, gradients, transformations, and more

## Installation

### Prerequisites

You need to have the ThorVG library installed on your system. You can:

1. Build ThorVG from source: https://github.com/thorvg/thorvg
2. Install from package manager (if available)
3. Download pre-built binaries

### Install the Nim wrapper

```bash
nimble install thorvg
```

Or add to your `.nimble` file:

```nim
requires "thorvg"
```

## Quick Start

```nim
import thorvg, thorvg/[canvases, shape, gradient]

# Load the ThorVG library
let engine = initThorEngine(threads = 4)

block:
  # Initialize the engine
  initEngine(threads = 4)
  
  # Create a software canvas
  let canvas = newSwCanvas()
  canvas.setTarget(800, 600, tvgArgb8888)
  
  # Create shapes with fluent API
  let rect = newRect(50, 50, 200, 150)
    .fill(rgb(255, 100, 100))
    .stroke(rgb(0, 0, 0), width = 3.0)
  
  let circle = newCircle(400, 200, 80)
    .fill(rgba(100, 255, 100, 200))
  
  # Create gradient
  let grad = newLinearGradient(0, 0, 200, 200)
    .stops(
      colorStop(0.0, rgb(255, 0, 0)),
      colorStop(0.5, rgb(0, 255, 0)),
      colorStop(1.0, rgb(0, 0, 255))
    )
  
  let gradientShape = newRect(300, 300, 150, 100)
    .fill(grad)
  
  # Add to canvas and render
  canvas.push(rect.handle)
  canvas.push(circle.handle)
  canvas.push(gradientShape.handle)
  canvas.render()
  
  # Get the rendered buffer
  let buffer = canvas.getBuffer()
  echo "Rendered ", buffer.len, " pixels"
  
```

## API Overview

### Core Modules

- **`thorvg`**: Main module with library loading and engine management
- **`thorvg/canvases`**: Canvas creation and rendering
- **`thorvg/paint`**: Base paint functionality and transformations
- **`thorvg/shape`**: Shape creation and path building
- **`thorvg/gradient`**: Linear and radial gradients

### Canvas

```nim
# Create software canvas
let canvas = newSwCanvas()
canvas.setTarget(width, height, colorspace)

# Render pipeline
canvas.push(paint.handle)  # Add paint objects
canvas.render()            # Update, draw, and sync
```

### Shapes

```nim
# Basic shapes
let rect = newRect(x, y, width, height, rx, ry)
let circle = newCircle(cx, cy, radius)
let ellipse = newEllipse(cx, cy, rx, ry)

# Custom paths
let shape = newShape()
var path = shape.path()
path.moveTo(x, y)
    .lineTo(x2, y2)
    .cubicTo(cx1, cy1, cx2, cy2, x3, y3)
    .close()
```

### Styling

```nim
# Solid colors
shape.fill(rgb(255, 0, 0))
shape.stroke(rgba(0, 0, 255, 128), width = 2.0)

# Gradients
let grad = newLinearGradient(x1, y1, x2, y2)
  .stops(
    colorStop(0.0, rgb(255, 0, 0)),
    colorStop(1.0, rgb(0, 0, 255))
  )
shape.fill(grad)
```

### Transformations

```nim
# Simple transformations
shape.translate(x, y)
shape.rotate(degrees)
shape.scale(factor)

# Custom matrix
let transform = newTransform(rotationMatrix(45.0))
shape.setTransform(transform)
```

### Colors

```nim
# Color constructors
let red = rgb(255, 0, 0)
let semiTransparent = rgba(255, 0, 0, 128)
let gray = gray(128)

# Color stops for gradients
let stop = colorStop(0.5, rgb(255, 255, 0))
```

## Advanced Features

### Path Builder Pattern

```nim
let star = newShape()
var path = star.path()

# Build complex paths with method chaining
path.moveTo(100, 50)
    .lineTo(120, 90)
    .lineTo(160, 90)
    .lineTo(130, 110)
    .lineTo(140, 150)
    .lineTo(100, 130)
    .close()
```

### Fluent API

```nim
# Method chaining for concise code
let styledShape = newRect(0, 0, 100, 100)
  .fill(rgb(255, 0, 0))
  .stroke(rgb(0, 0, 0), width = 2.0)
  .translate(50, 50)
  .rotate(45)
  .scale(1.5)
```

### Gradient Types

```nim
# Linear gradient
let linear = newLinearGradient(0, 0, 100, 100)
  .stops(colorStop(0.0, rgb(255, 0, 0)), colorStop(1.0, rgb(0, 0, 255)))
  .spread(tvgStrokeFillRepeat)

# Radial gradient with focal point
let radial = newRadialGradient(cx = 50, cy = 50, r = 40, fx = 60, fy = 40)
  .stops(colorStop(0.0, rgb(255, 255, 255)), colorStop(1.0, rgb(0, 0, 0)))
```

## Error Handling

The wrapper uses exceptions for error handling:

```nim
try:
  let shape = newShape()
  shape.fill(rgb(255, 0, 0))
  # ... operations
except ThorVGError as e:
  echo "ThorVG Error: ", e.msg
except Exception as e:
  echo "General Error: ", e.msg
```

## Memory Management

The wrapper handles memory management automatically:

- Objects are automatically destroyed when they go out of scope
- No manual memory management required
- Safe to use in multi-threaded environments (with proper ThorVG initialization)

## Platform-Specific Notes

### Library Loading

The wrapper automatically detects the platform and loads the appropriate library:

- **Windows**: `thorvg.dll`
- **macOS**: `libthorvg.dylib`
- **Linux**: `libthorvg.so`

You can also specify a custom path:

```nim
if not loadThorVG("/custom/path/to/thorvg.so"):
  echo "Failed to load custom ThorVG library"
```

### Thread Safety

ThorVG supports multi-threading. Initialize with the desired number of threads:

```nim
initEngine(threads = 4)  # Use 4 worker threads
```

## Examples

See the `example.nim` file for a comprehensive example showing:

- Basic shape creation
- Gradient usage
- Path building
- Transformations
- Canvas rendering

## File Structure

```
thorvg.nim              # Main module with library loading
thorvg/
  ├── canvases.nim        # Canvas functionality
  ├── paint.nim         # Base paint and transformations
  ├── shape.nim         # Shape creation and path building
  └── gradient.nim      # Gradient support
example.nim             # Comprehensive usage example
```

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This wrapper is provided under the same license as ThorVG. See the LICENSE file for details.

## Links

- [ThorVG Official Repository](https://github.com/thorvg/thorvg)
- [ThorVG Documentation](https://thorvg.org/)
- [Nim Language](https://nim-lang.org/) 