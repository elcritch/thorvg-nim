#pragma c2nim strict 
#pragma c2nim cdecl 
#pragma c2nim skipinclude
#pragma c2nim header "thorvg_capi.h"
#pragma c2nim reordercomments
#pragma c2nim stdints
#pragma c2nim mergeBlocks
#pragma c2nim mergeDuplicates
#pragma c2nim dynlib thorvg
#pragma c2nim nep1
#pragma c2nim render nopragmas
#pragma c2nim render reindentlongcomments
#pragma c2nim render extranewlines
#pragma c2nim assumedef TVG_API
#pragma c2nim assumendef TVG_STATIC
#pragma c2nim assumendef TVG_DEPRECATED
#pragma c2nim assumendef _WIN32

typedef struct {} Tvg_Canvas;
typedef struct {} Tvg_Paint;
typedef struct {} Tvg_Gradient;
typedef struct {} Tvg_Saver;
typedef struct {} Tvg_Animation;
typedef struct {} Tvg_Accessor;