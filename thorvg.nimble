version = "0.1.0"
author = "ElCritch"
description = "ThorVG Nim Wrapper"
license = "Unlicense"

requires "chroma"

task test, "Run tests":
  exec "nim c -r tests/test_thorvg.nim"