version: "0.1.0"
author: "ElCritch"
description: "ThorVG Nim Wrapper"
license: "Unlicense"

requires: "nim >= 2.0"

task test, "Run tests":
  exec "nim c -r tests/test_thorvg.nim"