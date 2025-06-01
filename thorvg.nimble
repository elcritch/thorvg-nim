version = "0.1.0"
author = "ElCritch"
description = "ThorVG Nim Wrapper"
license = "Unlicense"

requires "chroma"
requires "sdl2"
requires "opengl"

feature "wgpu_native":
  requires "https://github.com/gfx-rs/wgpu-native#fad19f59"

feature "test":
  requires "https://github.com/elcritch/windex"

includes "build.nims"