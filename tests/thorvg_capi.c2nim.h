#pragma c2nim strict 
#pragma c2nim dynlib thorvgLibName 
#pragma c2nim skipinclude
#pragma c2nim reordercomments
#pragma c2nim stdints
#pragma c2nim mergeBlocks
#pragma c2nim mergeDuplicates
// #pragma c2nim nep1
#pragma c2nim render reindentlongcomments
#pragma c2nim render extranewlines
#pragma c2nim assumedef TVG_API
#pragma c2nim assumendef TVG_STATIC
#pragma c2nim assumendef TVG_DEPRECATED
#pragma c2nim assumendef _WIN32

#@

when defined(macosx):
  {.passC: "-I/opt/homebrew/include".}
  {.passL: "-Wl,-rpath,/opt/homebrew/lib -L/opt/homebrew/lib".}
elif defined(windows):
  {.passC: "-I/usr/local/include".}
else:
  {.passC: "-I/usr/local/include".}

when defined(windows):
  const thorvgLibName = "thorvg.dll"
elif defined(macosx):
  const thorvgLibName = "libthorvg.dylib"
else:
  const thorvgLibName = "libthorvg.so"
@#

typedef struct {} Tvg_Canvas;
typedef struct {} Tvg_Paint;
typedef struct {} Tvg_Gradient;
typedef struct {} Tvg_Saver;
typedef struct {} Tvg_Animation;
typedef struct {} Tvg_Accessor;
