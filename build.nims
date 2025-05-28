
task test, "Run tests":
  exec "nim c -r tests/test_thorvg.nim"

task c2nim, "Run c2nim":
  exec "c2nim --concat:all tests/thorvg_capi.c2nim.h tests/thorvg_capi.h"