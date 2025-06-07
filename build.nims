
task test, "Run tests":
  exec "nim c -r tests/test_thorvg.nim"

task c2nim, "Run c2nim":
  exec "c2nim --concat:all tests/thorvg_capi.c2nim.h tests/thorvg_capi.h -o:tests/thorvg_capi.nim"
  exec "mv tests/thorvg_capi.nim thorvg/thorvg_capi.nim"
