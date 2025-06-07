##  #pragma c2nim nep1


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
type

  Tvg_Canvas* {.bycopy.} = object


  Tvg_Paint* {.bycopy.} = object


  Tvg_Gradient* {.bycopy.} = object


  Tvg_Saver* {.bycopy.} = object


  Tvg_Animation* {.bycopy.} = object


  Tvg_Accessor* {.bycopy.} = object


## !
##  @file thorvg_capi.h
##
##  @brief The module provides C bindings for the ThorVG library.
##  Please refer to src/examples/Capi.cpp to find the thorvg_capi usage examples.
##
##  The thorvg_capi module allows to implement the ThorVG client and provides
##  the following functionalities:
##  - drawing shapes: line, curve, polygon, circle, user-defined, ...
##  - filling: solid, linear and radial gradient
##  - scene graph & affine transformation (translation, rotation, scale, ...)
##  - stroking: width, join, cap, dash
##  - composition: blending, masking, path clipping
##  - pictures: SVG, PNG, JPG, bitmap
##
##

type

  Tvg_Result* {.size: sizeof(cint).} = enum ##
                                             ##  @brief Enumeration specifying the result from the APIs.
                                             ##
                                             ##  All ThorVG APIs could potentially return one of the values in the list.
                                             ##  Please note that some APIs may additionally specify the reasons that trigger their return values.
                                             ##
                                             ##
    TVG_RESULT_SUCCESS = 0, ## < The value returned in case of a correct request execution.
    TVG_RESULT_INVALID_ARGUMENT, ## < The value returned in the event of a problem with the arguments given to the API - e.g. empty paths or null pointers.
    TVG_RESULT_INSUFFICIENT_CONDITION, ## < The value returned in case the request cannot be processed - e.g. asking for properties of an object, which does not exist.
    TVG_RESULT_FAILED_ALLOCATION, ## < The value returned in case of unsuccessful memory allocation.
    TVG_RESULT_MEMORY_CORRUPTION, ## < The value returned in the event of bad memory handling - e.g. failing in pointer releasing or casting
    TVG_RESULT_NOT_SUPPORTED, ## < The value returned in case of choosing unsupported engine features(options).
    TVG_RESULT_UNKNOWN = 255 ## < The value returned in all other cases.


type

  Tvg_Colorspace* {.size: sizeof(cint).} = enum ##
                                                 ##  @brief Enumeration specifying the methods of combining the 8-bit color channels into 32-bit color.
                                                 ##
    TVG_COLORSPACE_ABGR8888 = 0, ## < The channels are joined in the order: alpha, blue, green, red. Colors are alpha-premultiplied.
    TVG_COLORSPACE_ARGB8888, ## < The channels are joined in the order: alpha, red, green, blue. Colors are alpha-premultiplied.
    TVG_COLORSPACE_ABGR8888S, ## < The channels are joined in the order: alpha, blue, green, red. Colors are un-alpha-premultiplied. (since 0.13)
    TVG_COLORSPACE_ARGB8888S, ## < The channels are joined in the order: alpha, red, green, blue. Colors are un-alpha-premultiplied. (since 0.13)
    TVG_COLORSPACE_UNKNOWN = 255 ## < Unknown channel data. This is reserved for an initial ColorSpace value. (since 1.0)


type

  Tvg_Mask_Method* {.size: sizeof(cint).} = enum ##
                                                  ##  @brief Enumeration indicating the method used in the masking of two objects - the target and the source.
                                                  ##
                                                  ##  @ingroup ThorVGCapi_Paint
                                                  ##
    TVG_MASK_METHOD_NONE = 0, ## < No masking is applied.
    TVG_MASK_METHOD_ALPHA,  ## < The pixels of the source and the target are alpha blended. As a result, only the part of the source, which intersects with the target is visible.
    TVG_MASK_METHOD_INVERSE_ALPHA, ## < The pixels of the source and the complement to the target's pixels are alpha blended. As a result, only the part of the source which is not covered by the target is visible.
    TVG_MASK_METHOD_LUMA,   ## < The source pixels are converted to grayscale (luma value) and alpha blended with the target. As a result, only the part of the source which intersects with the target is visible. @since 0.9
    TVG_MASK_METHOD_INVERSE_LUMA, ## < The source pixels are converted to grayscale (luma value) and complement to the target's pixels are alpha blended. As a result, only the part of the source which is not covered by the target is visible. @since 0.14
    TVG_MASK_METHOD_ADD,    ## < Combines the target and source objects pixels using target alpha. (T * TA) + (S * (255 - TA)) (Experimental API)
    TVG_MASK_METHOD_SUBTRACT, ## < Subtracts the source color from the target color while considering their respective target alpha. (T * TA) - (S * (255 - TA)) (Experimental API)
    TVG_MASK_METHOD_INTERSECT, ## < Computes the result by taking the minimum value between the target alpha and the source alpha and multiplies it with the target color. (T * min(TA, SA)) (Experimental API)
    TVG_MASK_METHOD_DIFFERENCE, ## < Calculates the absolute difference between the target color and the source color multiplied by the complement of the target alpha. abs(T - S * (255 - TA)) (Experimental API)
    TVG_MASK_METHOD_LIGHTEN, ## < Where multiple masks intersect, the highest transparency value is used. (Experimental API)
    TVG_MASK_METHOD_DARKEN   ## < Where multiple masks intersect, the lowest transparency value is used. (Experimental API)


type

  Tvg_Blend_Method* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Enumeration indicates the method used for blending paint. Please refer to the respective formulas for each method.
                              ##
                              ##  @ingroup ThorVGCapi_Paint
                              ##
                              ##  @since 0.15
                              ##
    TVG_BLEND_METHOD_NORMAL = 0, ## < Perform the alpha blending(default). S if (Sa == 255), otherwise (Sa * S) + (255 - Sa) * D
    TVG_BLEND_METHOD_MULTIPLY, ## < Takes the RGB channel values from 0 to 255 of each pixel in the top layer and multiples them with the values for the corresponding pixel from the bottom layer. (S * D)
    TVG_BLEND_METHOD_SCREEN, ## < The values of the pixels in the two layers are inverted, multiplied, and then inverted again. (S + D) - (S * D)
    TVG_BLEND_METHOD_OVERLAY, ## < Combines Multiply and Screen blend modes. (2 * S * D) if (2 * D < Da), otherwise (Sa * Da) - 2 * (Da - S) * (Sa - D)
    TVG_BLEND_METHOD_DARKEN, ## < Creates a pixel that retains the smallest components of the top and bottom layer pixels. min(S, D)
    TVG_BLEND_METHOD_LIGHTEN, ## < Only has the opposite action of Darken Only. max(S, D)
    TVG_BLEND_METHOD_COLORDODGE, ## < Divides the bottom layer by the inverted top layer. D / (255 - S)
    TVG_BLEND_METHOD_COLORBURN, ## < Divides the inverted bottom layer by the top layer, and then inverts the result. 255 - (255 - D) / S
    TVG_BLEND_METHOD_HARDLIGHT, ## < The same as Overlay but with the color roles reversed. (2 * S * D) if (S < Sa), otherwise (Sa * Da) - 2 * (Da - S) * (Sa - D)
    TVG_BLEND_METHOD_SOFTLIGHT, ## < The same as Overlay but with applying pure black or white does not result in pure black or white. (1 - 2 * S) * (D ^ 2) + (2 * S * D)
    TVG_BLEND_METHOD_DIFFERENCE, ## < Subtracts the bottom layer from the top layer or the other way around, to always get a non-negative value. (S - D) if (S > D), otherwise (D - S)
    TVG_BLEND_METHOD_EXCLUSION, ## < The result is twice the product of the top and bottom layers, subtracted from their sum. s + d - (2 * s * d)
    TVG_BLEND_METHOD_HUE,   ## < Reserved. Not supported.
    TVG_BLEND_METHOD_SATURATION, ## < Reserved. Not supported.
    TVG_BLEND_METHOD_COLOR, ## < Reserved. Not supported.
    TVG_BLEND_METHOD_LUMINOSITY, ## < Reserved. Not supported.
    TVG_BLEND_METHOD_ADD,   ## < Simply adds pixel values of one layer with the other. (S + D)
    TVG_BLEND_METHOD_HARDMIX ## < Reserved. Not supported.


type

  Tvg_Scene_Effect* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Enumeration that defines methods used for Scene Effects.
                              ##
                              ##  This enum provides options to apply various post-processing effects to a scene.
                              ##  Scene effects are typically applied to modify the final appearance of a rendered scene, such as blurring.
                              ##
                              ##  @ingroup ThorVGCapi_Scene
                              ##
                              ##  @since 1.0
                              ##
    TVG_SCENE_EFFECT_CLEAR_ALL = 0, ## < Reset all previously applied scene effects, restoring the scene to its original state.
    TVG_SCENE_EFFECT_GAUSSIAN_BLUR, ## < Apply a blur effect with a Gaussian filter. Param(3) = {sigma(float)[> 0], direction(int)[both: 0 / horizontal: 1 / vertical: 2], border(int)[duplicate: 0 / wrap: 1], quality(int)[0 - 100]}
    TVG_SCENE_EFFECT_DROP_SHADOW, ## < Apply a drop shadow effect with a Gaussian Blur filter. Param(8) = {color_R(int)[0 - 255], color_G(int)[0 - 255], color_B(int)[0 - 255], opacity(int)[0 - 255], angle(double)[0 - 360], distance(double), blur_sigma(double)[> 0], quality(int)[0 - 100]}
    TVG_SCENE_EFFECT_FILL,  ## < Override the scene content color with a given fill information (Experimental API). Param(5) = {color_R(int)[0 - 255], color_G(int)[0 - 255], color_B(int)[0 - 255], opacity(int)[0 - 255]}
    TVG_SCENE_EFFECT_TINT,  ## < Tinting the current scene color with a given black, white color paramters (Experimental API). Param(7) = {black_R(int)[0 - 255], black_G(int)[0 - 255], black_B(int)[0 - 255], white_R(int)[0 - 255], white_G(int)[0 - 255], white_B(int)[0 - 255], intensity(float)[0 - 100]}
    TVG_SCENE_EFFECT_TRITONE ## < Apply a tritone color effect to the scene using three color parameters for shadows, midtones, and highlights (Experimental API). Param(9) = {Shadow_R(int)[0 - 255], Shadow_G(int)[0 - 255], Shadow_B(int)[0 - 255], Midtone_R(int)[0 - 255], Midtone_G(int)[0 - 255], Midtone_B(int)[0 - 255], Highlight_R(int)[0 - 255], Highlight_G(int)[0 - 255], Highlight_B(int)[0 - 255]}


type

  Tvg_Identifier* {.size: sizeof(cint).} = enum ##
                                                 ##  @see Tvg_Type
                                                 ##  @deprecated
                                                 ##
    TVG_IDENTIFIER_UNDEF = 0, ## < Undefined type.
    TVG_IDENTIFIER_SHAPE,   ## < A shape type paint.
    TVG_IDENTIFIER_SCENE,   ## < A scene type paint.
    TVG_IDENTIFIER_PICTURE, ## < A picture type paint.
    TVG_IDENTIFIER_LINEAR_GRAD, ## < A linear gradient type.
    TVG_IDENTIFIER_RADIAL_GRAD, ## < A radial gradient type.
    TVG_IDENTIFIER_TEXT      ## < A text type paint.


type

  Tvg_Type* {.size: sizeof(cint).} = enum ##
                                           ##  @brief Enumeration indicating the ThorVG object type value.
                                           ##
                                           ##  ThorVG's drawing objects can return object type values, allowing you to identify the specific type of each object.
                                           ##
                                           ##  @ingroup ThorVGCapi_Paint
                                           ##
                                           ##  @see tvg_paint_get_type()
                                           ##  @see tvg_gradient_get_type()
                                           ##
                                           ##  @since 1.0
                                           ##
    TVG_TYPE_UNDEF = 0,     ## < Undefined type.
    TVG_TYPE_SHAPE,         ## < A shape type paint.
    TVG_TYPE_SCENE,         ## < A scene type paint.
    TVG_TYPE_PICTURE,       ## < A picture type paint.
    TVG_TYPE_TEXT,          ## < A text type paint.
    TVG_TYPE_LINEAR_GRAD = 10, ## < A linear gradient type.
    TVG_TYPE_RADIAL_GRAD     ## < A radial gradient type.


type

  Tvg_Path_Command* = uint8 ##
                            ##  @addtogroup ThorVGCapi_Shape
                            ##  \{
                            ##
                            ##
                            ##  @brief Enumeration specifying the values of the path commands accepted by ThorVG.
                            ##

const
  TVG_PATH_COMMAND_CLOSE* = 0 ## < Ends the current sub-path and connects it with its initial point - corresponds to Z command in the svg path commands.
  TVG_PATH_COMMAND_MOVE_TO* = 1 ## < Sets a new initial point of the sub-path and a new current point - corresponds to M command in the svg path commands.
  TVG_PATH_COMMAND_LINE_TO* = 2 ## < Draws a line from the current point to the given point and sets a new value of the current point - corresponds to L command in the svg path commands.
  TVG_PATH_COMMAND_CUBIC_TO* = 3 ## < Draws a cubic Bezier curve from the current point to the given point using two given control points and sets a new value of the current point - corresponds to C command in the svg path commands.

type

  Tvg_Stroke_Cap* {.size: sizeof(cint).} = enum ##
                                                 ##  @brief Enumeration determining the ending type of a stroke in the open sub-paths.
                                                 ##
    TVG_STROKE_CAP_BUTT = 0, ## < The stroke ends exactly at each of the two endpoints of a sub-path. For zero length sub-paths no stroke is rendered.
    TVG_STROKE_CAP_ROUND,   ## < The stroke is extended in both endpoints of a sub-path by a half circle, with a radius equal to the half of a stroke width. For zero length sub-paths a full circle is rendered.
    TVG_STROKE_CAP_SQUARE    ## < The stroke is extended in both endpoints of a sub-path by a rectangle, with the width equal to the stroke width and the length equal to the half of the stroke width. For zero length sub-paths the square is rendered with the size of the stroke width.


type

  Tvg_Stroke_Join* {.size: sizeof(cint).} = enum ##
                                                  ##  @brief Enumeration specifying how to fill the area outside the gradient bounds.
                                                  ##
    TVG_STROKE_JOIN_MITER = 0, ## < The outer corner of the joined path segments is spiked. The spike is created by extension beyond the join point of the outer edges of the stroke until they intersect. In case the extension goes beyond the limit, the join style is converted to the Bevel style.
    TVG_STROKE_JOIN_ROUND,  ## < The outer corner of the joined path segments is rounded. The circular region is centered at the join point.
    TVG_STROKE_JOIN_BEVEL    ## < The outer corner of the joined path segments is bevelled at the join point. The triangular region of the corner is enclosed by a straight line between the outer corners of each stroke.


type

  Tvg_Stroke_Fill* {.size: sizeof(cint).} = enum ##
                                                  ##  @brief Enumeration specifying how to fill the area outside the gradient bounds.
                                                  ##
    TVG_STROKE_FILL_PAD = 0, ## < The remaining area is filled with the closest stop color.
    TVG_STROKE_FILL_REFLECT, ## < The gradient pattern is reflected outside the gradient area until the expected region is filled.
    TVG_STROKE_FILL_REPEAT   ## < The gradient pattern is repeated continuously beyond the gradient area until the expected region is filled.


type

  Tvg_Fill_Rule* {.size: sizeof(cint).} = enum ##
                                                ##  @brief Enumeration specifying the algorithm used to establish which parts of the shape are treated as the inside of the shape.
                                                ##
    TVG_FILL_RULE_NON_ZERO = 0, ## < A line from the point to a location outside the shape is drawn. The intersections of the line with the path segment of the shape are counted. Starting from zero, if the path segment of the shape crosses the line clockwise, one is added, otherwise one is subtracted. If the resulting sum is non zero, the point is inside the shape.
    TVG_FILL_RULE_EVEN_ODD   ## < A line from the point to a location outside the shape is drawn and its intersections with the path segments of the shape are counted. If the number of intersections is an odd number, the point is inside the shape.


type

  Tvg_Color_Stop* {.bycopy.} = object ##  \}
                                       ##  end addtogroup ThorVGCapi_Shape
                                       ## !
                                       ##  @addtogroup ThorVGCapi_Gradient
                                       ##  \{
                                       ##
                                       ## !
                                       ##  @brief A data structure storing the information about the color and its relative position inside the gradient bounds.
                                       ##
    offset*: cfloat          ## < The relative position of the color.
    r*: uint8                ## < The red color channel value in the range [0 ~ 255].
    g*: uint8                ## < The green color channel value in the range [0 ~ 255].
    b*: uint8                ## < The blue color channel value in the range [0 ~ 255].
    a*: uint8
    ## < The alpha channel value in the range [0 ~ 255], where 0 is completely transparent and 255 is opaque.


  Tvg_Point* {.bycopy.} = object ##  \}
                                  ##  end addtogroup ThorVGCapi_Gradient
                                  ##
                                  ##  @brief A data structure representing a point in two-dimensional space.
                                  ##
    x*: cfloat
    y*: cfloat


  Tvg_Matrix* {.bycopy.} = object ##
                                   ##  @brief A data structure representing a three-dimensional matrix.
                                   ##
                                   ##  The elements e11, e12, e21 and e22 represent the rotation matrix, including the scaling factor.
                                   ##  The elements e13 and e23 determine the translation of the object along the x and y-axis, respectively.
                                   ##  The elements e31 and e32 are set to 0, e33 is set to 1.
                                   ##
    e11*: cfloat
    e12*: cfloat
    e13*: cfloat
    e21*: cfloat
    e22*: cfloat
    e23*: cfloat
    e31*: cfloat
    e32*: cfloat
    e33*: cfloat



proc tvg_engine_init*(threads: cuint): Tvg_Result {.importc: "tvg_engine_init",
    dynlib: thorvgLibName.}
  ##
                           ##  @defgroup ThorVGCapi_Initializer Initializer
                           ##  @brief A module enabling initialization and termination of the TVG engines.
                           ##
                           ##  \{
                           ##
                           ## *********************************************************************
                           ##  Engine API
                           ## *********************************************************************
                           ## !
                           ##  @brief Initializes the ThorVG engine.
                           ##
                           ##  ThorVG requires an active runtime environment to operate.
                           ##  Internally, it utilizes a task scheduler to efficiently parallelize rendering operations.
                           ##  You can specify the number of worker threads using the @p threads parameter.
                           ##  During initialization, ThorVG will spawn the specified number of threads.
                           ##
                           ##  @param[in] threads The number of worker threads to create. A value of zero indicates that only the main thread will be used.
                           ##
                           ##  @return Tvg_Result enumeration.
                           ##
                           ##  @note The initializer uses internal reference counting to track multiple calls.
                           ##        The number of threads is fixed on the first call to tvg_engine_init() and cannot be changed in subsequent calls.
                           ##  @see tvg_engine_term()
                           ##

proc tvg_engine_term*(): Tvg_Result {.importc: "tvg_engine_term",
                                      dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Terminates the ThorVG engine.
                              ##
                              ##  Cleans up resources and stops any internal threads initialized by tvg_engine_init().
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION Returned if there is nothing to terminate (e.g., tvg_engine_init() was not called).
                              ##
                              ##  @note The initializer maintains a reference count for safe repeated use. Only the final call to tvg_engine_term() will fully shut down the engine.
                              ##  @see tvg_engine_init()
                              ##

proc tvg_engine_version*(major: ptr uint32; minor: ptr uint32;
                         micro: ptr uint32; version: cstringArray): Tvg_Result {.
    importc: "tvg_engine_version", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Retrieves the version of the TVG engine.
                              ##
                              ##  @param[out] major A major version number.
                              ##  @param[out] minor A minor version number.
                              ##  @param[out] micro A micro version number.
                              ##  @param[out] version The version of the engine in the format major.minor.micro, or a @p nullptr in case of an internal error.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_SUCCESS.
                              ##
                              ##  @since 0.15
                              ##

proc tvg_swcanvas_create*(): ptr Tvg_Canvas {.importc: "tvg_swcanvas_create",
    dynlib: thorvgLibName.}
  ##  \}
                           ##  end defgroup ThorVGCapi_Initializer
                           ##
                           ##  @defgroup ThorVGCapi_Canvas Canvas
                           ##  @brief A module for managing and drawing graphical elements.
                           ##
                           ##  A canvas is an entity responsible for drawing the target. It sets up the drawing engine and the buffer, which can be drawn on the screen. It also manages given Paint objects.
                           ##
                           ##  @note A Canvas behavior depends on the raster engine though the final content of the buffer is expected to be identical.
                           ##  @warning The Paint objects belonging to one Canvas can't be shared among multiple Canvases.
                           ## \{
                           ##
                           ##
                           ##  @defgroup ThorVGCapi_SwCanvas SwCanvas
                           ##  @ingroup ThorVGCapi_Canvas
                           ##
                           ##  @brief A module for rendering the graphical elements using the software engine.
                           ##
                           ##  \{
                           ##
                           ## *********************************************************************
                           ##  SwCanvas API
                           ## *********************************************************************
                           ## !
                           ##  @brief Creates a Canvas object.
                           ##
                           ##  @return A new Tvg_Canvas object.
                           ##

proc tvg_swcanvas_set_target*(canvas: ptr Tvg_Canvas; buffer: ptr uint32;
                              stride: uint32; w: uint32; h: uint32;
                              cs: Tvg_Colorspace): Tvg_Result {.
    importc: "tvg_swcanvas_set_target", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the buffer used in the rasterization process and defines the used colorspace.
                              ##
                              ##  For optimisation reasons TVG does not allocate memory for the output buffer on its own.
                              ##  The buffer of a desirable size should be allocated and owned by the caller.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object managing the @p buffer.
                              ##  @param[in] buffer A pointer to the allocated memory block of the size @p stride x @p h.
                              ##  @param[in] stride The stride of the raster image - in most cases same value as @p w.
                              ##  @param[in] w The width of the raster image.
                              ##  @param[in] h The height of the raster image.
                              ##  @param[in] cs The colorspace value defining the way the 32-bits colors should be read/written.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENTS An invalid canvas or buffer pointer passed or one of the @p stride, @p w or @p h being zero.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION if the canvas is performing rendering. Please ensure the canvas is synced.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED The software engine is not supported.
                              ##
                              ##  @warning Do not access @p buffer during tvg_canvas_draw() - tvg_canvas_sync(). It should not be accessed while the engine is writing on it.
                              ##
                              ##  @see Tvg_Colorspace
                              ##

proc tvg_glcanvas_create*(): ptr Tvg_Canvas {.importc: "tvg_glcanvas_create",
    dynlib: thorvgLibName.}
  ##  \}
                           ##  end defgroup ThorVGCapi_SwCanvas
                           ##
                           ##  @defgroup ThorVGCapi_GlCanvas SwCanvas
                           ##  @ingroup ThorVGCapi_Canvas
                           ##
                           ##  @brief A module for rendering the graphical elements using the opengl engine.
                           ##
                           ##  \{
                           ##
                           ## *********************************************************************
                           ##  GlCanvas API
                           ## *********************************************************************
                           ## !
                           ##  @brief Creates a OpenGL rasterizer Canvas object.
                           ##
                           ##  @return A new Tvg_Canvas object.
                           ##
                           ##  @since 1.0.0
                           ##

proc tvg_glcanvas_set_target*(canvas: ptr Tvg_Canvas; context: pointer;
                              id: int32; w: uint32; h: uint32;
                              cs: Tvg_Colorspace): Tvg_Result {.
    importc: "tvg_glcanvas_set_target", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the drawing target for rasterization.
                              ##
                              ##  This function specifies the drawing target where the rasterization will occur. It can target
                              ##  a specific framebuffer object (FBO) or the main surface.
                              ##
                              ##  @param[in] context The GL context assigning to the current canvas rendering.
                              ##  @param[in] id The GL target ID, usually indicating the FBO ID. A value of @c 0 specifies the main surface.
                              ##  @param[in] w The width (in pixels) of the raster image.
                              ##  @param[in] h The height (in pixels) of the raster image.
                              ##  @param[in] cs Specifies how the pixel values should be interpreted. Currently, it only allows @c TVG_COLORSPACE_ABGR8888S as @c GL_RGBA8.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION if the canvas is performing rendering. Please ensure the canvas is synced.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED In case the gl engine is not supported.
                              ##
                              ##  @note Experimental API
                              ##

proc tvg_wgcanvas_create*(): ptr Tvg_Canvas {.importc: "tvg_wgcanvas_create",
    dynlib: thorvgLibName.}
  ##  \}
                           ##  end defgroup ThorVGCapi_GlCanvas
                           ##
                           ##  @defgroup ThorVGCapi_WgCanvas WGCanvas
                           ##  @ingroup ThorVGCapi_Canvas
                           ##
                           ##  @brief A module for rendering the graphical elements using the webgpu engine.
                           ##
                           ##  \{
                           ##
                           ## *********************************************************************
                           ##  WgCanvas API
                           ## *********************************************************************
                           ## !
                           ##  @brief Creates a WebGPU rasterizer Canvas object.
                           ##
                           ##  @return A new Tvg_Canvas object.
                           ##
                           ##  @since 1.0.0
                           ##

proc tvg_wgcanvas_set_target*(canvas: ptr Tvg_Canvas; device: pointer;
                              instance: pointer; target: pointer; w: uint32;
                              h: uint32; cs: Tvg_Colorspace; `type`: cint): Tvg_Result {.
    importc: "tvg_wgcanvas_set_target", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the drawing target for the rasterization.
                              ##
                              ##  @param[in] device WGPUDevice, a desired handle for the wgpu device. If it is @c nullptr, ThorVG will assign an appropriate device internally.
                              ##  @param[in] instance WGPUInstance, context for all other wgpu objects.
                              ##  @param[in] target Either WGPUSurface or WGPUTexture, serving as handles to a presentable surface or texture.
                              ##  @param[in] w The width of the target.
                              ##  @param[in] h The height of the target.
                              ##  @param[in] cs Specifies how the pixel values should be interpreted. Currently, it only allows @c TVG_COLORSPACE_ABGR8888S as @c WGPUTextureFormat_RGBA8Unorm.
                              ##  @param[in] type @c 0: surface, @c 1: texture are used as pesentable target.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION if the canvas is performing rendering. Please ensure the canvas is synced.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED In case the wg engine is not supported.
                              ##
                              ##  @note Experimental API
                              ##

proc tvg_canvas_destroy*(canvas: ptr Tvg_Canvas): Tvg_Result {.
    importc: "tvg_canvas_destroy", dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_WgCanvas
                              ## *********************************************************************
                              ##  Common Canvas API
                              ## *********************************************************************
                              ## !
                              ##  @brief Clears the canvas internal data, releases all paints stored by the canvas and destroys the canvas object itself.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object to be destroyed.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer to the Tvg_Canvas object is passed.
                              ##

proc tvg_canvas_push*(canvas: ptr Tvg_Canvas; paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_canvas_push", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Inserts a drawing element into the canvas using a Tvg_Paint object.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object managing the @p paint.
                              ##  @param[in] paint The Tvg_Paint object to be drawn.
                              ##
                              ##  Only the paints pushed into the canvas will be drawing targets.
                              ##  They are retained by the canvas until you call tvg_canvas_remove()
                              ##
                              ##  @return Tvg_Result return values:
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION An internal error.
                              ##
                              ##  @note The rendering order of the paints is the same as the order as they were pushed. Consider sorting the paints before pushing them if you intend to use layering.
                              ##  @see tvg_canvas_push_at()
                              ##  @see tvg_canvas_remove()
                              ##

proc tvg_canvas_push_at*(canvas: ptr Tvg_Canvas; target: ptr Tvg_Paint;
                         at: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_canvas_push_at", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Adds a paint object to the root scene.
                              ##
                              ##  This function appends a paint object to root scene of the canvas. If the optional @p at
                              ##  is provided, the new paint object will be inserted immediately before the specified
                              ##  paint object in the root scene. If @p at is @c nullptr, the paint object will be added
                              ##  to the end of the root scene.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object managing the @p paint.
                              ##  @param[in] target A pointer to the Paint object to be added into the root scene.
                              ##                    This parameter must not be @c nullptr.
                              ##  @param[in] at A pointer to an existing Paint object in the root scene before which
                              ##                the new paint object will be added. If @c nullptr, the new
                              ##                paint object is added to the end of the root scene. The default is @c nullptr.
                              ##
                              ##  @note The ownership of the @p paint object is transferred to the canvas upon addition.
                              ##  @note The rendering order of the paints is the same as the order as they were pushed. Consider sorting the paints before pushing them if you intend to use layering.
                              ##
                              ##  @see tvg_canvas_push()
                              ##  @see tvg_canvas_remove()
                              ##  @see tvg_canvas_remove()
                              ##  @since 1.0
                              ##

proc tvg_canvas_remove*(canvas: ptr Tvg_Canvas; paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_canvas_remove", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Removes a paint object from the root scene.
                              ##
                              ##  This function removes a specified paint object from the root scene. If no paint
                              ##  object is specified (i.e., the default @c nullptr is used), the function
                              ##  performs to clear all paints from the scene.
                              ##
                              ##  @param[in] canvas A Tvg_Canvas object to remove the @p paint.
                              ##  @param[in] paint A pointer to the Paint object to be removed from the root scene.
                              ##                   If @c nullptr, remove all the paints from the root scene.
                              ##
                              ##  @see tvg_canvas_push()
                              ##  @see tvg_canvas_push_at()
                              ##  @since 1.0
                              ##

proc tvg_canvas_update*(canvas: ptr Tvg_Canvas): Tvg_Result {.
    importc: "tvg_canvas_update", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Updates all paints in a canvas.
                              ##
                              ##  Should be called before drawing in order to prepare paints for the rendering.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object to be updated.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Canvas pointer.
                              ##
                              ##  @see tvg_canvas_update_paint()
                              ##

proc tvg_canvas_update_paint*(canvas: ptr Tvg_Canvas; paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_canvas_update_paint", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Updates the given Tvg_Paint object from the canvas before the rendering.
                              ##
                              ##  If a client application using the TVG library does not update the entire canvas with tvg_canvas_update() in the frame
                              ##  rendering process, Tvg_Paint objects previously added to the canvas should be updated manually with this function.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object to which the @p paint belongs.
                              ##  @param[in] paint The Tvg_Paint object to be updated.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##
                              ##  @see tvg_canvas_update()
                              ##

proc tvg_canvas_draw*(canvas: ptr Tvg_Canvas; clear: bool): Tvg_Result {.
    importc: "tvg_canvas_draw", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Requests the canvas to draw the Tvg_Paint objects.
                              ##
                              ##  All paints from the given canvas will be rasterized to the buffer.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object containing elements to be drawn.
                              ##  @param[in] clear If @c true, clears the target buffer to zero before drawing.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Canvas pointer.
                              ##
                              ##  @note Clearing the buffer is unnecessary if the canvas will be fully covered
                              ##        with opaque content, which can improve performance.
                              ##  @note Drawing may be asynchronous if the thread count is greater than zero.
                              ##        To ensure drawing is complete, call tvg_canvas_sync() afterwards.
                              ##  @see tvg_canvas_sync()
                              ##

proc tvg_canvas_sync*(canvas: ptr Tvg_Canvas): Tvg_Result {.
    importc: "tvg_canvas_sync", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Guarantees that the drawing process is finished.
                              ##
                              ##  Since the canvas rendering can be performed asynchronously, it should be called after the tvg_canvas_draw().
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object containing elements which were drawn.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Canvas pointer.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION @p canvas is either already in sync condition or in a damaged condition (a draw is required before syncing).
                              ##
                              ##  @see tvg_canvas_draw()
                              ##

proc tvg_canvas_set_viewport*(canvas: ptr Tvg_Canvas; x: int32; y: int32;
                              w: int32; h: int32): Tvg_Result {.
    importc: "tvg_canvas_set_viewport", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the drawing region in the canvas.
                              ##
                              ##  This function defines the rectangular area of the canvas that will be used for drawing operations.
                              ##  The specified viewport is used to clip the rendering output to the boundaries of the rectangle.
                              ##
                              ##  @param[in] canvas The Tvg_Canvas object containing elements which were drawn.
                              ##  @param[in] x The x-coordinate of the upper-left corner of the rectangle.
                              ##  @param[in] y The y-coordinate of the upper-left corner of the rectangle.
                              ##  @param[in] w The width of the rectangle.
                              ##  @param[in] h The height of the rectangle.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##
                              ##  @warning It's not allowed to change the viewport during tvg_canvas_update() - tvg_canvas_sync() or tvg_canvas_push() - tvg_canvas_sync().
                              ##
                              ##  @note When resetting the target, the viewport will also be reset to the target size.
                              ##  @see tvg_swcanvas_set_target()
                              ##  @since 0.15
                              ##

proc tvg_paint_del*(paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_paint_del", dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_Canvas
                              ##
                              ##  @defgroup ThorVGCapi_Paint Paint
                              ##  @brief A module for managing graphical elements. It enables duplication, transformation and composition.
                              ##
                              ##  \{
                              ##
                              ## *********************************************************************
                              ##  Paint API
                              ## *********************************************************************
                              ## !
                              ##  @brief Releases the given Tvg_Paint object.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to be released.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @see tvg_canvas_remove()
                              ##

proc tvg_paint_ref*(paint: ptr Tvg_Paint): uint8 {.importc: "tvg_paint_ref",
    dynlib: thorvgLibName.}
  ##
                           ##  @brief Increment the reference count for the Tvg_Paint object.
                           ##
                           ##  This method increases the reference count of Tvg_Paint object, allowing shared ownership and control over its lifetime.
                           ##
                           ##  @param[in] paint The Tvg_Paint object to increase the reference count.
                           ##
                           ##  @return The updated reference count after the increment by 1.
                           ##
                           ##  @warning Please ensure that each call to tvg_paint_ref() is paired with a corresponding call to tvg_paint_unref() to prevent a dangling instance.
                           ##
                           ##  @see tvg_paint_unref()
                           ##  @see tvg_paint_get_ref()
                           ##
                           ##  @since 1.0
                           ##

proc tvg_paint_unref*(paint: ptr Tvg_Paint; free: bool): uint8 {.
    importc: "tvg_paint_unref", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Decrement the reference count for the Tvg_Paint object.
                              ##
                              ##  This method decreases the reference count of the Tvg_Paint object by 1.
                              ##  If the reference count reaches zero and the @p free flag is set to true, the instance is automatically deleted.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to decrease the reference count.
                              ##  @param[in] free Flag indicating whether to delete the Paint instance when the reference count reaches zero.
                              ##
                              ##  @return The updated reference count after the decrement.
                              ##
                              ##  @see tvg_paint_ref()
                              ##  @see tvg_paint_get_ref()
                              ##
                              ##  @since 1.0
                              ##

proc tvg_paint_get_ref*(paint: ptr Tvg_Paint): uint8 {.
    importc: "tvg_paint_get_ref", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Retrieve the current reference count of the Tvg_Paint object.
                              ##
                              ##  This method provides the current reference count, allowing the user to check the shared ownership state of the Tvg_Paint object.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to return the reference count.
                              ##
                              ##  @return The current reference count of the Tvg_Paint object.
                              ##
                              ##  @see tvg_paint_ref()
                              ##  @see tvg_paint_unref()
                              ##
                              ##  @since 1.0
                              ##

proc tvg_paint_scale*(paint: ptr Tvg_Paint; factor: cfloat): Tvg_Result {.
    importc: "tvg_paint_scale", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Scales the given Tvg_Paint object by the given factor.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to be scaled.
                              ##  @param[in] factor The value of the scaling factor. The default value is 1.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION in case a custom transform is applied.
                              ##
                              ##  @see tvg_paint_set_transform()
                              ##

proc tvg_paint_rotate*(paint: ptr Tvg_Paint; degree: cfloat): Tvg_Result {.
    importc: "tvg_paint_rotate", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Rotates the given Tvg_Paint by the given angle.
                              ##
                              ##  The angle in measured clockwise from the horizontal axis.
                              ##  The rotational axis passes through the point on the object with zero coordinates.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to be rotated.
                              ##  @param[in] degree The value of the rotation angle in degrees.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION in case a custom transform is applied.
                              ##
                              ##  @see tvg_paint_set_transform()
                              ##

proc tvg_paint_translate*(paint: ptr Tvg_Paint; x: cfloat; y: cfloat): Tvg_Result {.
    importc: "tvg_paint_translate", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Moves the given Tvg_Paint in a two-dimensional space.
                              ##
                              ##  The origin of the coordinate system is in the upper-left corner of the canvas.
                              ##  The horizontal and vertical axes point to the right and down, respectively.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to be shifted.
                              ##  @param[in] x The value of the horizontal shift.
                              ##  @param[in] y The value of the vertical shift.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION in case a custom transform is applied.
                              ##
                              ##  @see tvg_paint_set_transform()
                              ##

proc tvg_paint_set_transform*(paint: ptr Tvg_Paint; m: ptr Tvg_Matrix): Tvg_Result {.
    importc: "tvg_paint_set_transform", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Transforms the given Tvg_Paint using the augmented transformation matrix.
                              ##
                              ##  The augmented matrix of the transformation is expected to be given.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to be transformed.
                              ##  @param[in] m The 3x3 augmented matrix.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr is passed as the argument.
                              ##

proc tvg_paint_get_transform*(paint: ptr Tvg_Paint; m: ptr Tvg_Matrix): Tvg_Result {.
    importc: "tvg_paint_get_transform", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the matrix of the affine transformation of the given Tvg_Paint object.
                              ##
                              ##  In case no transformation was applied, the identity matrix is returned.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which to get the transformation matrix.
                              ##  @param[out] m The 3x3 augmented matrix.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr is passed as the argument.
                              ##

proc tvg_paint_set_opacity*(paint: ptr Tvg_Paint; opacity: uint8): Tvg_Result {.
    importc: "tvg_paint_set_opacity", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the opacity of the given Tvg_Paint.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which the opacity value is to be set.
                              ##  @param[in] opacity The opacity value in the range [0 ~ 255], where 0 is completely transparent and 255 is opaque.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note Setting the opacity with this API may require multiple renderings using a composition. It is recommended to avoid changing the opacity if possible.
                              ##

proc tvg_paint_get_opacity*(paint: ptr Tvg_Paint; opacity: ptr uint8): Tvg_Result {.
    importc: "tvg_paint_get_opacity", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the opacity of the given Tvg_Paint.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which to get the opacity value.
                              ##  @param[out] opacity The opacity value in the range [0 ~ 255], where 0 is completely transparent and 255 is opaque.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##

proc tvg_paint_duplicate*(paint: ptr Tvg_Paint): ptr Tvg_Paint {.
    importc: "tvg_paint_duplicate", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Duplicates the given Tvg_Paint object.
                              ##
                              ##  Creates a new object and sets its all properties as in the original object.
                              ##
                              ##  @param[in] paint The Tvg_Paint object to be copied.
                              ##
                              ##  @return A copied Tvg_Paint object if succeed, @c nullptr otherwise.
                              ##

proc tvg_paint_get_aabb*(paint: ptr Tvg_Paint; x: ptr cfloat; y: ptr cfloat;
                         w: ptr cfloat; h: ptr cfloat): Tvg_Result {.
    importc: "tvg_paint_get_aabb", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Retrieves the axis-aligned bounding box (AABB) of the paint object in canvas space.
                              ##
                              ##  This function returns the bounding box of the paint, as an axis-aligned bounding box (AABB) after transformations are applied.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which to get the bounds.
                              ##  @param[out] x The x-coordinate of the upper-left corner of the bounding box.
                              ##  @param[out] y The y-coordinate of the upper-left corner of the bounding box.
                              ##  @param[out] w The width of the bounding box.
                              ##  @param[out] h The height of the bounding box.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid @p paint.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION If it failed to compute the bounding box (mostly due to invalid path information).
                              ##
                              ##  @see tvg_paint_get_obb()
                              ##  @see tvg_canvas_update_paint()
                              ##

proc tvg_paint_get_obb*(paint: ptr Tvg_Paint; pt4: ptr Tvg_Point): Tvg_Result {.
    importc: "tvg_paint_get_obb", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Retrieves the object-oriented bounding box (OBB) of the paint object in canvas space.
                              ##
                              ##  This function returns the bounding box of the paint, as an oriented bounding box (OBB) after transformations are applied.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which to get the bounds.
                              ##  @param[out] pt4 An array of four points representing the bounding box. The array size must be 4.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT @p paint or @p pt4 is invalid.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION If it failed to compute the bounding box (mostly due to invalid path information).
                              ##
                              ##  @see tvg_paint_get_aabb()
                              ##  @see tvg_canvas_update_paint()
                              ##
                              ##  @since 1.0
                              ##

proc tvg_paint_set_mask_method*(paint: ptr Tvg_Paint; target: ptr Tvg_Paint;
                                `method`: Tvg_Mask_Method): Tvg_Result {.
    importc: "tvg_paint_set_mask_method", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the masking target object and the masking method.
                              ##
                              ##  @param[in] paint The source object of the masking.
                              ##  @param[in] target The target object of the masking.
                              ##  @param[in] method The method used to mask the source object with the target.
                              ##
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION if the target has already belonged to another paint.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##
                              ##

proc tvg_paint_get_mask_method*(paint: ptr Tvg_Paint; target: ptr ptr Tvg_Paint;
                                `method`: ptr Tvg_Mask_Method): Tvg_Result {.
    importc: "tvg_paint_get_mask_method", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Gets the masking target object and the masking method.
                              ##
                              ##  @param[in] paint The source object of the masking.
                              ##  @param[out] target The target object of the masking.
                              ##  @param[out] method The method used to mask the source object with the target.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr is passed as the argument.
                              ##

proc tvg_paint_set_clip*(paint: ptr Tvg_Paint; clipper: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_paint_set_clip", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Clip the drawing region of the paint object.
                              ##
                              ##  This function restricts the drawing area of the paint object to the specified shape's paths.
                              ##
                              ##  @param[in] paint The target object of the clipping.
                              ##  @param[in] clipper The shape object as the clipper.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION if the target has already belonged to another paint.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED If the @p clipper type is not Shape.
                              ##
                              ##  @see tvg_paint_get_clip()
                              ##
                              ##  @since 1.0
                              ##

proc tvg_paint_get_clip*(paint: ptr Tvg_Paint): ptr Tvg_Paint {.
    importc: "tvg_paint_get_clip", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Get the clipper shape of the paint object.
                              ##
                              ##  This function returns the clipper that has been previously set to this paint object.
                              ##
                              ##  @return The shape object used as the clipper, or @c nullptr if no clipper is set.
                              ##
                              ##  @see tvg_paint_set_clip()
                              ##
                              ##  @since 1.0
                              ##

proc tvg_paint_get_parent*(paint: ptr Tvg_Paint): ptr Tvg_Paint {.
    importc: "tvg_paint_get_parent", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Retrieves the parent paint object.
                              ##
                              ##  This function returns a pointer to the parent object if the current paint
                              ##  belongs to one. Otherwise, it returns @c nullptr.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which to get the scene.
                              ##
                              ##  @return A pointer to the parent object if available, otherwise @c nullptr.
                              ##
                              ##  @see tvg_scene_push()
                              ##  @see tvg_canvas_push()
                              ##
                              ##  @since 1.0
                              ##

proc tvg_paint_get_type*(paint: ptr Tvg_Paint; `type`: ptr Tvg_Type): Tvg_Result {.
    importc: "tvg_paint_get_type", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Gets the unique value of the paint instance indicating the instance type.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which to get the type value.
                              ##  @param[out] type The unique type of the paint instance type.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_paint_set_blend_method*(paint: ptr Tvg_Paint;
                                 `method`: Tvg_Blend_Method): Tvg_Result {.
    importc: "tvg_paint_set_blend_method", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Sets the blending method for the paint object.
                              ##
                              ##  The blending feature allows you to combine colors to create visually appealing effects, including transparency, lighting, shading, and color mixing, among others.
                              ##  its process involves the combination of colors or images from the source paint object with the destination (the lower layer image) using blending operations.
                              ##  The blending operation is determined by the chosen @p BlendMethod, which specifies how the colors or images are combined.
                              ##
                              ##  @param[in] paint The Tvg_Paint object of which to set the blend method.
                              ##  @param[in] method The blending method to be set.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##
                              ##  @since 0.15
                              ##

proc tvg_shape_new*(): ptr Tvg_Paint {.importc: "tvg_shape_new",
                                       dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_Paint
                              ##
                              ##  @defgroup ThorVGCapi_Shape Shape
                              ##
                              ##  @brief A module for managing two-dimensional figures and their properties.
                              ##
                              ##  A shape has three major properties: shape outline, stroking, filling. The outline in the shape is retained as the path.
                              ##  Path can be composed by accumulating primitive commands such as tvg_shape_move_to(), tvg_shape_line_to(), tvg_shape_cubic_to() or complete shape interfaces such as tvg_shape_append_rect(), tvg_shape_append_circle(), etc.
                              ##  Path can consists of sub-paths. One sub-path is determined by a close command.
                              ##
                              ##  The stroke of a shape is an optional property in case the shape needs to be represented with/without the outline borders.
                              ##  It's efficient since the shape path and the stroking path can be shared with each other. It's also convenient when controlling both in one context.
                              ##
                              ##  \{
                              ##
                              ## *********************************************************************
                              ##  Shape API
                              ## *********************************************************************
                              ## !
                              ##  @brief Creates a new shape object.
                              ##
                              ##  @return A new shape object.
                              ##

proc tvg_shape_reset*(paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_shape_reset", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Resets the shape path properties.
                              ##
                              ##  The color, the fill and the stroke properties are retained.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note The memory, where the path data is stored, is not deallocated at this stage for caching effect.
                              ##

proc tvg_shape_move_to*(paint: ptr Tvg_Paint; x: cfloat; y: cfloat): Tvg_Result {.
    importc: "tvg_shape_move_to", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the initial point of the sub-path.
                              ##
                              ##  The value of the current point is set to the given point.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] x The horizontal coordinate of the initial point of the sub-path.
                              ##  @param[in] y The vertical coordinate of the initial point of the sub-path.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_shape_line_to*(paint: ptr Tvg_Paint; x: cfloat; y: cfloat): Tvg_Result {.
    importc: "tvg_shape_line_to", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Adds a new point to the sub-path, which results in drawing a line from the current point to the given end-point.
                              ##
                              ##  The value of the current point is set to the given end-point.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] x The horizontal coordinate of the end-point of the line.
                              ##  @param[in] y The vertical coordinate of the end-point of the line.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note In case this is the first command in the path, it corresponds to the tvg_shape_move_to() call.
                              ##

proc tvg_shape_cubic_to*(paint: ptr Tvg_Paint; cx1: cfloat; cy1: cfloat;
                         cx2: cfloat; cy2: cfloat; x: cfloat; y: cfloat): Tvg_Result {.
    importc: "tvg_shape_cubic_to", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Adds new points to the sub-path, which results in drawing a cubic Bezier curve.
                              ##
                              ##  The Bezier curve starts at the current point and ends at the given end-point (@p x, @p y). Two control points (@p cx1, @p cy1) and (@p cx2, @p cy2) are used to determine the shape of the curve.
                              ##  The value of the current point is set to the given end-point.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] cx1 The horizontal coordinate of the 1st control point.
                              ##  @param[in] cy1 The vertical coordinate of the 1st control point.
                              ##  @param[in] cx2 The horizontal coordinate of the 2nd control point.
                              ##  @param[in] cy2 The vertical coordinate of the 2nd control point.
                              ##  @param[in] x The horizontal coordinate of the endpoint of the curve.
                              ##  @param[in] y The vertical coordinate of the endpoint of the curve.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note In case this is the first command in the path, no data from the path are rendered.
                              ##

proc tvg_shape_close*(paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_shape_close", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Closes the current sub-path by drawing a line from the current point to the initial point of the sub-path.
                              ##
                              ##  The value of the current point is set to the initial point of the closed sub-path.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note In case the sub-path does not contain any points, this function has no effect.
                              ##

proc tvg_shape_append_rect*(paint: ptr Tvg_Paint; x: cfloat; y: cfloat;
                            w: cfloat; h: cfloat; rx: cfloat; ry: cfloat;
                            cw: bool): Tvg_Result {.
    importc: "tvg_shape_append_rect", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Appends a rectangle to the path.
                              ##
                              ##  The rectangle with rounded corners can be achieved by setting non-zero values to @p rx and @p ry arguments.
                              ##  The @p rx and @p ry values specify the radii of the ellipse defining the rounding of the corners.
                              ##
                              ##  The position of the rectangle is specified by the coordinates of its upper-left corner -  @p x and @p y arguments.
                              ##
                              ##  The rectangle is treated as a new sub-path - it is not connected with the previous sub-path.
                              ##
                              ##  The value of the current point is set to (@p x + @p rx, @p y) - in case @p rx is greater
                              ##  than @p w/2 the current point is set to (@p x + @p w/2, @p y)
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] x The horizontal coordinate of the upper-left corner of the rectangle.
                              ##  @param[in] y The vertical coordinate of the upper-left corner of the rectangle.
                              ##  @param[in] w The width of the rectangle.
                              ##  @param[in] h The height of the rectangle.
                              ##  @param[in] rx The x-axis radius of the ellipse defining the rounded corners of the rectangle.
                              ##  @param[in] ry The y-axis radius of the ellipse defining the rounded corners of the rectangle.
                              ##  @param[in] cw Specifies the path direction: @c true for clockwise, @c false for counterclockwise.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ## & @note For @p rx and @p ry greater than or equal to the half of @p w and the half of @p h, respectively, the shape become an ellipse.
                              ##

proc tvg_shape_append_circle*(paint: ptr Tvg_Paint; cx: cfloat; cy: cfloat;
                              rx: cfloat; ry: cfloat; cw: bool): Tvg_Result {.
    importc: "tvg_shape_append_circle", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Appends an ellipse to the path.
                              ##
                              ##  The position of the ellipse is specified by the coordinates of its center - @p cx and @p cy arguments.
                              ##
                              ##  The ellipse is treated as a new sub-path - it is not connected with the previous sub-path.
                              ##
                              ##  The value of the current point is set to (@p cx, @p cy - @p ry).
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] cx The horizontal coordinate of the center of the ellipse.
                              ##  @param[in] cy The vertical coordinate of the center of the ellipse.
                              ##  @param[in] rx The x-axis radius of the ellipse.
                              ##  @param[in] ry The y-axis radius of the ellipse.
                              ##  @param[in] cw Specifies the path direction: @c true for clockwise, @c false for counterclockwise.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_shape_append_path*(paint: ptr Tvg_Paint; cmds: ptr Tvg_Path_Command;
                            cmdCnt: uint32; pts: ptr Tvg_Point; ptsCnt: uint32): Tvg_Result {.
    importc: "tvg_shape_append_path", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Appends a given sub-path to the path.
                              ##
                              ##  The current point value is set to the last point from the sub-path.
                              ##  For each command from the @p cmds array, an appropriate number of points in @p pts array should be specified.
                              ##  If the number of points in the @p pts array is different than the number required by the @p cmds array, the shape with this sub-path will not be displayed on the screen.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] cmds The array of the commands in the sub-path.
                              ##  @param[in] cmdCnt The length of the @p cmds array.
                              ##  @param[in] pts The array of the two-dimensional points.
                              ##  @param[in] ptsCnt The length of the @p pts array.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the argument or @p cmdCnt or @p ptsCnt equal to zero.
                              ##

proc tvg_shape_get_path*(paint: ptr Tvg_Paint; cmds: ptr ptr Tvg_Path_Command;
                         cmdsCnt: ptr uint32; pts: ptr ptr Tvg_Point;
                         ptsCnt: ptr uint32): Tvg_Result {.
    importc: "tvg_shape_get_path", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Retrieves the current path data of the shape.
                              ##
                              ##  This function provides access to the shape's path data, including the commands
                              ##  and points that define the path.
                              ##
                              ##  @param[out] cmds Pointer to the array of commands representing the path.
                              ##                   Can be @c nullptr if this information is not needed.
                              ##  @param[out] cmdsCnt Pointer to the variable that receives the number of commands in the @p cmds array.
                              ##                      Can be @c nullptr if this information is not needed.
                              ##  @param[out] pts Pointer to the array of two-dimensional points that define the path.
                              ##                  Can be @c nullptr if this information is not needed.
                              ##  @param[out] ptsCnt Pointer to the variable that receives the number of points in the @p pts array.
                              ##                     Can be @c nullptr if this information is not needed.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note If any of the arguments are @c nullptr, that value will be ignored.
                              ##

proc tvg_shape_set_stroke_width*(paint: ptr Tvg_Paint; width: cfloat): Tvg_Result {.
    importc: "tvg_shape_set_stroke_width", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the stroke width for all of the figures from the @p paint.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] width The width of the stroke. The default value is 0.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_shape_get_stroke_width*(paint: ptr Tvg_Paint; width: ptr cfloat): Tvg_Result {.
    importc: "tvg_shape_get_stroke_width", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the shape's stroke width.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] width The stroke width.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##

proc tvg_shape_set_stroke_color*(paint: ptr Tvg_Paint; r: uint8; g: uint8;
                                 b: uint8; a: uint8): Tvg_Result {.
    importc: "tvg_shape_set_stroke_color", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the shape's stroke color.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] r The red color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] g The green color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] b The blue color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] a The alpha channel value in the range [0 ~ 255], where 0 is completely transparent and 255 is opaque.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note Either a solid color or a gradient fill is applied, depending on what was set as last.
                              ##

proc tvg_shape_get_stroke_color*(paint: ptr Tvg_Paint; r: ptr uint8;
                                 g: ptr uint8; b: ptr uint8; a: ptr uint8): Tvg_Result {.
    importc: "tvg_shape_get_stroke_color", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the shape's stroke color.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] r The red color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[out] g The green color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[out] b The blue color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[out] a The alpha channel value in the range [0 ~ 255], where 0 is completely transparent and 255 is opaque.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION No stroke was set.
                              ##

proc tvg_shape_set_stroke_gradient*(paint: ptr Tvg_Paint; grad: ptr Tvg_Gradient): Tvg_Result {.
    importc: "tvg_shape_set_stroke_gradient", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the gradient fill of the stroke for all of the figures from the path.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] grad The gradient fill.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##  @retval TVG_RESULT_MEMORY_CORRUPTION An invalid Tvg_Gradient pointer or an error with accessing it.
                              ##
                              ##  @note Either a solid color or a gradient fill is applied, depending on what was set as last.
                              ##

proc tvg_shape_get_stroke_gradient*(paint: ptr Tvg_Paint;
                                    grad: ptr ptr Tvg_Gradient): Tvg_Result {.
    importc: "tvg_shape_get_stroke_gradient", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the gradient fill of the shape's stroke.
                              ##
                              ##  The function does not allocate any memory.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] grad The gradient fill.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##

proc tvg_shape_set_stroke_dash*(paint: ptr Tvg_Paint; dashPattern: ptr cfloat;
                                cnt: uint32; offset: cfloat): Tvg_Result {.
    importc: "tvg_shape_set_stroke_dash", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the shape's stroke dash pattern.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] dashPattern The array of consecutive pair values of the dash length and the gap length.
                              ##  @param[in] cnt The size of the @p dashPattern array.
                              ##  @param[in] offset The shift of the starting point within the repeating dash pattern from which the path's dashing begins.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument and @p cnt > 0, the given length of the array is less than two or any of the @p dashPattern values is zero or less.
                              ##
                              ##  @note To reset the stroke dash pattern, pass @c nullptr to @p dashPattern and zero to @p cnt.
                              ##  @since 1.0
                              ##

proc tvg_shape_get_stroke_dash*(paint: ptr Tvg_Paint;
                                dashPattern: ptr ptr cfloat; cnt: ptr uint32;
                                offset: ptr cfloat): Tvg_Result {.
    importc: "tvg_shape_get_stroke_dash", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the dash pattern of the stroke.
                              ##
                              ##  The function does not allocate any memory.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] dashPattern The array of consecutive pair values of the dash length and the gap length.
                              ##  @param[out] cnt The size of the @p dashPattern array.
                              ##  @param[out] offset The shift of the starting point within the repeating dash pattern.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##  @since 1.0
                              ##

proc tvg_shape_set_stroke_cap*(paint: ptr Tvg_Paint; cap: Tvg_Stroke_Cap): Tvg_Result {.
    importc: "tvg_shape_set_stroke_cap", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the cap style used for stroking the path.
                              ##
                              ##  The cap style specifies the shape to be used at the end of the open stroked sub-paths.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] cap The cap style value. The default value is @c TVG_STROKE_CAP_SQUARE.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_shape_get_stroke_cap*(paint: ptr Tvg_Paint; cap: ptr Tvg_Stroke_Cap): Tvg_Result {.
    importc: "tvg_shape_get_stroke_cap", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the stroke cap style used for stroking the path.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] cap The cap style value.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##

proc tvg_shape_set_stroke_join*(paint: ptr Tvg_Paint; join: Tvg_Stroke_Join): Tvg_Result {.
    importc: "tvg_shape_set_stroke_join", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the join style for stroked path segments.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] join The join style value. The default value is @c TVG_STROKE_JOIN_BEVEL.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_shape_get_stroke_join*(paint: ptr Tvg_Paint; join: ptr Tvg_Stroke_Join): Tvg_Result {.
    importc: "tvg_shape_get_stroke_join", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief The function gets the stroke join method
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] join The join style value.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##

proc tvg_shape_set_stroke_miterlimit*(paint: ptr Tvg_Paint; miterlimit: cfloat): Tvg_Result {.
    importc: "tvg_shape_set_stroke_miterlimit", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the stroke miterlimit.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] miterlimit The miterlimit imposes a limit on the extent of the stroke join when the @c TVG_STROKE_JOIN_MITER join style is set. The default value is 4.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer or Unsupported @p miterlimit values (less than zero).
                              ##
                              ##  @since 0.11
                              ##

proc tvg_shape_get_stroke_miterlimit*(paint: ptr Tvg_Paint;
                                      miterlimit: ptr cfloat): Tvg_Result {.
    importc: "tvg_shape_get_stroke_miterlimit", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief The function gets the stroke miterlimit.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] miterlimit The stroke miterlimit.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##
                              ##  @since 0.11
                              ##

proc tvg_shape_set_trimpath*(paint: ptr Tvg_Paint; begin: cfloat; `end`: cfloat;
                             simultaneous: bool): Tvg_Result {.
    importc: "tvg_shape_set_trimpath", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the trim of the shape along the defined path segment, allowing control over which part of the shape is visible.
                              ##
                              ##  If the values of the arguments @p begin and @p end exceed the 0-1 range, they are wrapped around in a manner similar to angle wrapping, effectively treating the range as circular.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] begin Specifies the start of the segment to display along the path.
                              ##  @param[in] end Specifies the end of the segment to display along the path.
                              ##  @param[in] simultaneous Determines how to trim multiple paths within a single shape. If set to @c true (default), trimming is applied simultaneously to all paths;
                              ##  Otherwise, all paths are treated as a single entity with a combined length equal to the sum of their individual lengths and are trimmed as such.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_shape_set_fill_color*(paint: ptr Tvg_Paint; r: uint8; g: uint8;
                               b: uint8; a: uint8): Tvg_Result {.
    importc: "tvg_shape_set_fill_color", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the shape's solid color.
                              ##
                              ##  The parts of the shape defined as inner are colored.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] r The red color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] g The green color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] b The blue color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] a The alpha channel value in the range [0 ~ 255], where 0 is completely transparent and 255 is opaque. The default value is 0.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @note Either a solid color or a gradient fill is applied, depending on what was set as last.
                              ##  @see tvg_shape_set_fill_rule()
                              ##

proc tvg_shape_get_fill_color*(paint: ptr Tvg_Paint; r: ptr uint8; g: ptr uint8;
                               b: ptr uint8; a: ptr uint8): Tvg_Result {.
    importc: "tvg_shape_get_fill_color", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the shape's solid color.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] r The red color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[out] g The green color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[out] b The blue color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[out] a The alpha channel value in the range [0 ~ 255], where 0 is completely transparent and 255 is opaque. The default value is 0.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_shape_set_fill_rule*(paint: ptr Tvg_Paint; rule: Tvg_Fill_Rule): Tvg_Result {.
    importc: "tvg_shape_set_fill_rule", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the shape's fill rule.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] rule The fill rule value. The default value is @c TVG_FILL_RULE_NON_ZERO.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_shape_get_fill_rule*(paint: ptr Tvg_Paint; rule: ptr Tvg_Fill_Rule): Tvg_Result {.
    importc: "tvg_shape_get_fill_rule", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the shape's fill rule.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] rule shape's fill rule
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##

proc tvg_shape_set_paint_order*(paint: ptr Tvg_Paint; strokeFirst: bool): Tvg_Result {.
    importc: "tvg_shape_set_paint_order", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the rendering order of the stroke and the fill.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] strokeFirst If @c true the stroke is rendered before the fill, otherwise the stroke is rendered as the second one (the default option).
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##
                              ##  @since 0.10
                              ##

proc tvg_shape_set_gradient*(paint: ptr Tvg_Paint; grad: ptr Tvg_Gradient): Tvg_Result {.
    importc: "tvg_shape_set_gradient", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the gradient fill for all of the figures from the path.
                              ##
                              ##  The parts of the shape defined as inner are filled.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[in] grad The gradient fill.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##  @retval TVG_RESULT_MEMORY_CORRUPTION An invalid Tvg_Gradient pointer.
                              ##
                              ##  @note Either a solid color or a gradient fill is applied, depending on what was set as last.
                              ##  @see tvg_shape_set_fill_rule()
                              ##

proc tvg_shape_get_gradient*(paint: ptr Tvg_Paint; grad: ptr ptr Tvg_Gradient): Tvg_Result {.
    importc: "tvg_shape_get_gradient", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the gradient fill of the shape.
                              ##
                              ##  The function does not allocate any data.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the shape object.
                              ##  @param[out] grad The gradient fill.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid pointer passed as an argument.
                              ##

proc tvg_linear_gradient_new*(): ptr Tvg_Gradient {.
    importc: "tvg_linear_gradient_new", dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_Shape
                              ##
                              ##  @defgroup ThorVGCapi_Gradient Gradient
                              ##  @brief A module managing the gradient fill of objects.
                              ##
                              ##  The module enables to set and to get the gradient colors and their arrangement inside the gradient bounds,
                              ##  to specify the gradient bounds and the gradient behavior in case the area defined by the gradient bounds
                              ##  is smaller than the area to be filled.
                              ##
                              ##  \{
                              ##
                              ## *********************************************************************
                              ##  Gradient API
                              ## *********************************************************************
                              ## !
                              ##  @brief Creates a new linear gradient object.
                              ##
                              ##  @return A new linear gradient object.
                              ##

proc tvg_radial_gradient_new*(): ptr Tvg_Gradient {.
    importc: "tvg_radial_gradient_new", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Creates a new radial gradient object.
                              ##
                              ##  @return A new radial gradient object.
                              ##

proc tvg_linear_gradient_set*(grad: ptr Tvg_Gradient; x1: cfloat; y1: cfloat;
                              x2: cfloat; y2: cfloat): Tvg_Result {.
    importc: "tvg_linear_gradient_set", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the linear gradient bounds.
                              ##
                              ##  The bounds of the linear gradient are defined as a surface constrained by two parallel lines crossing
                              ##  the given points (@p x1, @p y1) and (@p x2, @p y2), respectively. Both lines are perpendicular to the line linking
                              ##  (@p x1, @p y1) and (@p x2, @p y2).
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which bounds are to be set.
                              ##  @param[in] x1 The horizontal coordinate of the first point used to determine the gradient bounds.
                              ##  @param[in] y1 The vertical coordinate of the first point used to determine the gradient bounds.
                              ##  @param[in] x2 The horizontal coordinate of the second point used to determine the gradient bounds.
                              ##  @param[in] y2 The vertical coordinate of the second point used to determine the gradient bounds.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Gradient pointer.
                              ##
                              ##  @note In case the first and the second points are equal, an object is filled with a single color using the last color specified in the tvg_gradient_set_color_stops().
                              ##  @see tvg_gradient_set_color_stops()
                              ##

proc tvg_linear_gradient_get*(grad: ptr Tvg_Gradient; x1: ptr cfloat;
                              y1: ptr cfloat; x2: ptr cfloat; y2: ptr cfloat): Tvg_Result {.
    importc: "tvg_linear_gradient_get", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the linear gradient bounds.
                              ##
                              ##  The bounds of the linear gradient are defined as a surface constrained by two parallel lines crossing
                              ##  the given points (@p x1, @p y1) and (@p x2, @p y2), respectively. Both lines are perpendicular to the line linking
                              ##  (@p x1, @p y1) and (@p x2, @p y2).
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which to get the bounds.
                              ##  @param[out] x1 The horizontal coordinate of the first point used to determine the gradient bounds.
                              ##  @param[out] y1 The vertical coordinate of the first point used to determine the gradient bounds.
                              ##  @param[out] x2 The horizontal coordinate of the second point used to determine the gradient bounds.
                              ##  @param[out] y2 The vertical coordinate of the second point used to determine the gradient bounds.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Gradient pointer.
                              ##

proc tvg_radial_gradient_set*(grad: ptr Tvg_Gradient; cx: cfloat; cy: cfloat;
                              r: cfloat; fx: cfloat; fy: cfloat; fr: cfloat): Tvg_Result {.
    importc: "tvg_radial_gradient_set", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the radial gradient attributes.
                              ##
                              ##  The radial gradient is defined by the end circle with a center (@p cx, @p cy) and a radius @p r and
                              ##  the start circle with a center/focal point (@p fx, @p fy) and a radius @p fr.
                              ##  The gradient will be rendered such that the gradient stop at an offset of 100% aligns with the edge of the end circle
                              ##  and the stop at an offset of 0% aligns with the edge of the start circle.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which bounds are to be set.
                              ##  @param[in] cx The horizontal coordinate of the center of the end circle.
                              ##  @param[in] cy The vertical coordinate of the center of the end circle.
                              ##  @param[in] r The radius of the end circle.
                              ##  @param[in] fx The horizontal coordinate of the center of the start circle.
                              ##  @param[in] fy The vertical coordinate of the center of the start circle.
                              ##  @param[in] fr The radius of the start circle.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Gradient pointer or the radius @p r or @p fr value is negative.
                              ##
                              ##  @note In case the radius @p r is zero, an object is filled with a single color using the last color specified in the specified in the tvg_gradient_set_color_stops().
                              ##  @note By manipulating the position and size of the focal point, a wide range of visual effects can be achieved, such as directing
                              ##  the gradient focus towards a specific edge or enhancing the depth and complexity of shading patterns.
                              ##  If a focal effect is not desired, simply align the focal point (@p fx and @p fy) with the center of the end circle (@p cx and @p cy)
                              ##  and set the radius (@p fr) to zero. This will result in a uniform gradient without any focal variations.
                              ##
                              ##  @see tvg_gradient_set_color_stops()
                              ##

proc tvg_radial_gradient_get*(grad: ptr Tvg_Gradient; cx: ptr cfloat;
                              cy: ptr cfloat; r: ptr cfloat; fx: ptr cfloat;
                              fy: ptr cfloat; fr: ptr cfloat): Tvg_Result {.
    importc: "tvg_radial_gradient_get", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief The function gets radial gradient attributes.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which to get the gradient attributes.
                              ##  @param[out] cx The horizontal coordinate of the center of the end circle.
                              ##  @param[out] cy The vertical coordinate of the center of the end circle.
                              ##  @param[out] r The radius of the end circle.
                              ##  @param[out] fx The horizontal coordinate of the center of the start circle.
                              ##  @param[out] fy The vertical coordinate of the center of the start circle.
                              ##  @param[out] fr The radius of the start circle.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Gradient pointer.
                              ##
                              ##  @see tvg_radial_gradient_set()
                              ##

proc tvg_gradient_set_color_stops*(grad: ptr Tvg_Gradient;
                                   color_stop: ptr Tvg_Color_Stop; cnt: uint32): Tvg_Result {.
    importc: "tvg_gradient_set_color_stops", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the parameters of the colors of the gradient and their position.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which the color information is to be set.
                              ##  @param[in] color_stop An array of Tvg_Color_Stop data structure.
                              ##  @param[in] cnt The size of the @p color_stop array equal to the colors number used in the gradient.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Gradient pointer.
                              ##

proc tvg_gradient_get_color_stops*(grad: ptr Tvg_Gradient;
                                   color_stop: ptr ptr Tvg_Color_Stop;
                                   cnt: ptr uint32): Tvg_Result {.
    importc: "tvg_gradient_get_color_stops", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the parameters of the colors of the gradient, their position and number
                              ##
                              ##  The function does not allocate any memory.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which to get the color information.
                              ##  @param[out] color_stop An array of Tvg_Color_Stop data structure.
                              ##  @param[out] cnt The size of the @p color_stop array equal to the colors number used in the gradient.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the argument.
                              ##

proc tvg_gradient_set_spread*(grad: ptr Tvg_Gradient; spread: Tvg_Stroke_Fill): Tvg_Result {.
    importc: "tvg_gradient_set_spread", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the Tvg_Stroke_Fill value, which specifies how to fill the area outside the gradient bounds.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object.
                              ##  @param[in] spread The FillSpread value.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Gradient pointer.
                              ##

proc tvg_gradient_get_spread*(grad: ptr Tvg_Gradient;
                              spread: ptr Tvg_Stroke_Fill): Tvg_Result {.
    importc: "tvg_gradient_get_spread", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the FillSpread value of the gradient object.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object.
                              ##  @param[out] spread The FillSpread value.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the argument.
                              ##

proc tvg_gradient_set_transform*(grad: ptr Tvg_Gradient; m: ptr Tvg_Matrix): Tvg_Result {.
    importc: "tvg_gradient_set_transform", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the matrix of the affine transformation for the gradient object.
                              ##
                              ##  The augmented matrix of the transformation is expected to be given.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object to be transformed.
                              ##  @param[in] m The 3x3 augmented matrix.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr is passed as the argument.
                              ##

proc tvg_gradient_get_transform*(grad: ptr Tvg_Gradient; m: ptr Tvg_Matrix): Tvg_Result {.
    importc: "tvg_gradient_get_transform", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the matrix of the affine transformation of the gradient object.
                              ##
                              ##  In case no transformation was applied, the identity matrix is set.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which to get the transformation matrix.
                              ##  @param[out] m The 3x3 augmented matrix.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr is passed as the argument.
                              ##

proc tvg_gradient_get_type*(grad: ptr Tvg_Gradient; `type`: ptr Tvg_Type): Tvg_Result {.
    importc: "tvg_gradient_get_type", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Gets the unique value of the gradient instance indicating the instance type.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object of which to get the type value.
                              ##  @param[out] type The unique type of the gradient instance type.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_gradient_duplicate*(grad: ptr Tvg_Gradient): ptr Tvg_Gradient {.
    importc: "tvg_gradient_duplicate", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Duplicates the given Tvg_Gradient object.
                              ##
                              ##  Creates a new object and sets its all properties as in the original object.
                              ##
                              ##  @param[in] grad The Tvg_Gradient object to be copied.
                              ##
                              ##  @return A copied Tvg_Gradient object if succeed, @c nullptr otherwise.
                              ##

proc tvg_gradient_del*(grad: ptr Tvg_Gradient): Tvg_Result {.
    importc: "tvg_gradient_del", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Deletes the given gradient object.
                              ##
                              ##  @param[in] grad The gradient object to be deleted.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Gradient pointer.
                              ##

proc tvg_picture_new*(): ptr Tvg_Paint {.importc: "tvg_picture_new",
    dynlib: thorvgLibName.}
  ##  \}
                           ##  end defgroup ThorVGCapi_Gradient
                           ##
                           ##  @defgroup ThorVGCapi_Picture Picture
                           ##
                           ##  @brief A module enabling to create and to load an image in one of the supported formats: svg, png, jpg, lottie and raw.
                           ##
                           ##
                           ##  \{
                           ##
                           ## *********************************************************************
                           ##  Picture API
                           ## *********************************************************************
                           ## !
                           ##  @brief Creates a new picture object.
                           ##
                           ##  @return A new picture object.
                           ##

proc tvg_picture_load*(paint: ptr Tvg_Paint; path: cstring): Tvg_Result {.
    importc: "tvg_picture_load", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Loads a picture data directly from a file.
                              ##
                              ##  ThorVG efficiently caches the loaded data using the specified @p path as a key.
                              ##  This means that loading the same file again will not result in duplicate operations;
                              ##  instead, ThorVG will reuse the previously loaded picture data.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the picture object.
                              ##  @param[in] path The absolute path to the image file.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer or an empty @p path.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED A file with an unknown extension.
                              ##

proc tvg_picture_load_raw*(paint: ptr Tvg_Paint; data: ptr uint32; w: uint32;
                           h: uint32; cs: Tvg_Colorspace; copy: bool): Tvg_Result {.
    importc: "tvg_picture_load_raw", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Loads raw image data in a specific format from a memory block of the given size.
                              ##
                              ##  ThorVG efficiently caches the loaded data, using the provided @p data address as a key
                              ##  when @p copy is set to @c false. This allows ThorVG to avoid redundant operations
                              ##  by reusing the previously loaded picture data for the same sharable @p data,
                              ##  rather than duplicating the load process.
                              ##
                              ##  @param[in] data A pointer to the memory block where the raw image data is stored.
                              ##  @param[in] w The width of the image in pixels.
                              ##  @param[in] h The height of the image in pixels.
                              ##  @param[in] cs Specifies how the 32-bit color values should be interpreted (read/write).
                              ##  @param[in] copy If @c true, the data is copied into the engine's local buffer. If @c false, the data is not copied.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer or no data are provided or the @p w or @p h value is zero or less.
                              ##
                              ##  @since 0.9
                              ##

proc tvg_picture_load_data*(paint: ptr Tvg_Paint; data: cstring; size: uint32;
                            mimetype: cstring; rpath: cstring; copy: bool): Tvg_Result {.
    importc: "tvg_picture_load_data", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Loads a picture data from a memory block of a given size.
                              ##
                              ##  ThorVG efficiently caches the loaded data using the specified @p data address as a key
                              ##  when the @p copy has @c false. This means that loading the same data again will not result in duplicate operations
                              ##  for the sharable @p data. Instead, ThorVG will reuse the previously loaded picture data.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the picture object.
                              ##  @param[in] data A pointer to a memory location where the content of the picture file is stored. A null-terminated string is expected for non-binary data if @p copy is @c false
                              ##  @param[in] size The size in bytes of the memory occupied by the @p data.
                              ##  @param[in] mimetype Mimetype or extension of data such as "jpg", "jpeg", "svg", "svg+xml", "lot", "lottie+json", "png", etc. In case an empty string or an unknown type is provided, the loaders will be tried one by one.
                              ##  @param[in] rpath A resource directory path, if the @p data needs to access any external resources.
                              ##  @param[in] copy If @c true the data are copied into the engine local buffer, otherwise they are not.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument or the @p size is zero or less.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED A file with an unknown extension.
                              ##
                              ##  @warning: It's the user responsibility to release the @p data memory if the @p copy is @c true.
                              ##

proc tvg_picture_set_size*(paint: ptr Tvg_Paint; w: cfloat; h: cfloat): Tvg_Result {.
    importc: "tvg_picture_set_size", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Resizes the picture content to the given width and height.
                              ##
                              ##  The picture content is resized while keeping the default size aspect ratio.
                              ##  The scaling factor is established for each of dimensions and the smaller value is applied to both of them.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the picture object.
                              ##  @param[in] w A new width of the image in pixels.
                              ##  @param[in] h A new height of the image in pixels.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_picture_get_size*(paint: ptr Tvg_Paint; w: ptr cfloat; h: ptr cfloat): Tvg_Result {.
    importc: "tvg_picture_get_size", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the size of the loaded picture.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the picture object.
                              ##  @param[out] w A width of the image in pixels.
                              ##  @param[out] h A height of the image in pixels.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Paint pointer.
                              ##

proc tvg_picture_get_paint*(paint: ptr Tvg_Paint; id: uint32): ptr Tvg_Paint {.
    importc: "tvg_picture_get_paint", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Retrieve a paint object from the Picture scene by its Unique ID.
                              ##
                              ##  This function searches for a paint object within the Picture scene that matches the provided @p id.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the picture object.
                              ##  @param[in] id The Unique ID of the paint object.
                              ##
                              ##  @return A pointer to the paint object that matches the given identifier, or @c nullptr if no matching paint object is found.
                              ##
                              ##  @see tvg_accessor_generate_id()
                              ##  @note Experimental API
                              ##

proc tvg_scene_new*(): ptr Tvg_Paint {.importc: "tvg_scene_new",
                                       dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_Picture
                              ##
                              ##  @defgroup ThorVGCapi_Scene Scene
                              ##  @brief A module managing the multiple paints as one group paint.
                              ##
                              ##  As a group, scene can be transformed, translucent, composited with other target paints,
                              ##  its children will be affected by the scene world.
                              ##
                              ##  \{
                              ##
                              ## *********************************************************************
                              ##  Scene API
                              ## *********************************************************************
                              ## !
                              ##  @brief Creates a new scene object.
                              ##
                              ##  A scene object is used to group many paints into one object, which can be manipulated using TVG APIs.
                              ##
                              ##  @return A new scene object.
                              ##

proc tvg_scene_push*(scene: ptr Tvg_Paint; paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_scene_push", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Adds a paint object to the scene.
                              ##
                              ##  This function appends a paint object to the scene.
                              ##
                              ##  @param[in] scene A Tvg_Paint pointer to the scene object.
                              ##  @param[in] paint A pointer to the Paint object to be added into the scene.
                              ##
                              ##  @note The ownership of the @p paint object is transferred to the scene upon addition.
                              ##
                              ##  @see tvg_scene_remove()
                              ##  @see tvg_scene_push_at()
                              ##

proc tvg_scene_push_at*(scene: ptr Tvg_Paint; target: ptr Tvg_Paint;
                        at: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_scene_push_at", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Adds a paint object to the scene.
                              ##
                              ##  This function appends a paint object to the scene. The new paint object @p target will
                              ##  be inserted immediately before the specified paint object @p at in the scene.
                              ##
                              ##  @param[in] scene A Tvg_Paint pointer to the scene object.
                              ##  @param[in] target A pointer to the Paint object to be added into the scene.
                              ##  @param[in] at A pointer to an existing Paint object in the scene before which
                              ##                the new paint object will be added. This parameter must not be @c nullptr.
                              ##
                              ##  @note The ownership of the @p paint object is transferred to the scene upon addition.
                              ##
                              ##  @see tvg_scene_remove()
                              ##  @see tvg_scene_push()
                              ##  @since 1.0
                              ##

proc tvg_scene_remove*(scene: ptr Tvg_Paint; paint: ptr Tvg_Paint): Tvg_Result {.
    importc: "tvg_scene_remove", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Removes a paint object from the scene.
                              ##
                              ##  This function removes a specified paint object from the scene. If no paint
                              ##  object is specified (i.e., the default @c nullptr is used), the function
                              ##  performs to clear all paints from the scene.
                              ##
                              ##  @param[in] scene A Tvg_Paint pointer to the scene object.
                              ##  @param[in] paint A pointer to the Paint object to be removed from the scene.
                              ##                   If @c nullptr, remove all the paints from the scene.
                              ##
                              ##  @see tvg_scene_push()
                              ##  @since 1.0
                              ##

proc tvg_scene_push_effect*(scene: ptr Tvg_Paint; effect: Tvg_Scene_Effect): Tvg_Result {.
    varargs, importc: "tvg_scene_push_effect", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Apply a post-processing effect to the scene.
                              ##
                              ##  This function adds a specified scene effect, such as clearing all effects or applying a Gaussian blur,
                              ##  to the scene after it has been rendered. Multiple effects can be applied in sequence.
                              ##
                              ##  @param[in] scene A Tvg_Paint pointer to the scene object.
                              ##  @param[in] effect The scene effect to apply. Options are defined in the Tvg_Scene_Effect enum.
                              ##                    For example, use TVG_SCENE_EFFECT_GAUSSIAN_BLUR to apply a blur with specific parameters.
                              ##  @param[in] ... Additional variadic parameters required for certain effects (e.g., sigma and direction for GaussianBlur).
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the @p scene argument.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_text_new*(): ptr Tvg_Paint {.importc: "tvg_text_new",
                                      dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_Scene
                              ##
                              ##  @defgroup ThorVGCapi_Text Text
                              ##  @brief A class to represent text objects in a graphical context, allowing for rendering and manipulation of unicode text.
                              ##
                              ##  @since 0.15
                              ##
                              ##  \{
                              ##
                              ## *********************************************************************
                              ##  Text API
                              ## *********************************************************************
                              ## !
                              ##  @brief Creates a new text object.
                              ##
                              ##  @return A new text object.
                              ##
                              ##  @since 0.15
                              ##

proc tvg_text_set_font*(paint: ptr Tvg_Paint; name: cstring; size: cfloat;
                        style: cstring): Tvg_Result {.
    importc: "tvg_text_set_font", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Sets the font properties for the text.
                              ##
                              ##  This function allows you to define the font characteristics used for text rendering.
                              ##  It sets the font name, size and optionally the style.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the text object.
                              ##  @param[in] name The name of the font. This should correspond to a font available in the canvas.
                              ##  @param[in] size The size of the font in points.
                              ##  @param[in] style The style of the font. If empty, the default style is used. Currently only 'italic' style is supported.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the @p paint argument.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION  The specified @p name cannot be found.
                              ##
                              ##  @note If the @p name is not specified, ThorVG will select any available font candidate.
                              ##  @since 1.0
                              ##

proc tvg_text_set_text*(paint: ptr Tvg_Paint; text: cstring): Tvg_Result {.
    importc: "tvg_text_set_text", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Assigns the given unicode text to be rendered.
                              ##
                              ##  This function sets the unicode text that will be displayed by the rendering system.
                              ##  The text is set according to the specified UTF encoding method, which defaults to UTF-8.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the text object.
                              ##  @param[in] text The multi-byte text encoded with utf8 string to be rendered.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the @p paint argument.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_text_set_fill_color*(paint: ptr Tvg_Paint; r: uint8; g: uint8; b: uint8): Tvg_Result {.
    importc: "tvg_text_set_fill_color", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Sets the text solid color.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the text object.
                              ##  @param[in] r The red color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] g The green color channel value in the range [0 ~ 255]. The default value is 0.
                              ##  @param[in] b The blue color channel value in the range [0 ~ 255]. The default value is 0.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the @p paint argument.
                              ##
                              ##  @note Either a solid color or a gradient fill is applied, depending on what was set as last.
                              ##  @see tvg_text_set_font()
                              ##
                              ##  @since 0.15
                              ##

proc tvg_text_set_gradient*(paint: ptr Tvg_Paint; gradient: ptr Tvg_Gradient): Tvg_Result {.
    importc: "tvg_text_set_gradient", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Sets the gradient fill for the text.
                              ##
                              ##  @param[in] paint A Tvg_Paint pointer to the text object.
                              ##  @param[in] grad The linear or radial gradient fill
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the @p paint argument.
                              ##  @retval TVG_RESULT_MEMORY_CORRUPTION An invalid Tvg_Gradient pointer.
                              ##
                              ##  @note Either a solid color or a gradient fill is applied, depending on what was set as last.
                              ##  @see tvg_text_set_font()
                              ##
                              ##  @since 0.15
                              ##

proc tvg_font_load*(path: cstring): Tvg_Result {.importc: "tvg_font_load",
    dynlib: thorvgLibName.}
  ##
                           ##  @brief Loads a scalable font data from a file.
                           ##
                           ##  ThorVG efficiently caches the loaded data using the specified @p path as a key.
                           ##  This means that loading the same file again will not result in duplicate operations;
                           ##  instead, ThorVG will reuse the previously loaded font data.
                           ##
                           ##  @param[in] path The path to the font file.
                           ##
                           ##  @return Tvg_Result enumeration.
                           ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid @p path passed as an argument.
                           ##  @retval TVG_RESULT_NOT_SUPPORTED When trying to load a file with an unknown extension.
                           ##
                           ##  @see tvg_font_unload()
                           ##
                           ##  @since 0.15
                           ##

proc tvg_font_load_data*(name: cstring; data: cstring; size: uint32;
                         mimetype: cstring; copy: bool): Tvg_Result {.
    importc: "tvg_font_load_data", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Loads a scalable font data from a memory block of a given size.
                              ##
                              ##  ThorVG efficiently caches the loaded font data using the specified @p name as a key.
                              ##  This means that loading the same fonts again will not result in duplicate operations.
                              ##  Instead, ThorVG will reuse the previously loaded font data.
                              ##
                              ##  @param[in] name The name under which the font will be stored and accessible (e.x. in a @p tvg_text_set_font API).
                              ##  @param[in] data A pointer to a memory location where the content of the font data is stored.
                              ##  @param[in] size The size in bytes of the memory occupied by the @p data.
                              ##  @param[in] mimetype Mimetype or extension of font data. In case a @c nullptr or an empty "" value is provided the loader will be determined automatically.
                              ##  @param[in] copy If @c true the data are copied into the engine local buffer, otherwise they are not (default).
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT If no name is provided or if @p size is zero while @p data points to a valid memory location.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED When trying to load a file with an unknown extension.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION When trying to unload the font data that has not been previously loaded.
                              ##
                              ##  @warning: It's the user responsibility to release the @p data memory.
                              ##
                              ##  @note To unload the font data loaded using this API, pass the proper @p name and @c nullptr as @p data.
                              ##
                              ##  @since 0.15
                              ##

proc tvg_font_unload*(path: cstring): Tvg_Result {.importc: "tvg_font_unload",
    dynlib: thorvgLibName.}
  ##
                           ##  @brief Unloads the specified scalable font data that was previously loaded.
                           ##
                           ##  This function is used to release resources associated with a font file that has been loaded into memory.
                           ##
                           ##  @param[in] path The path to the loaded font file.
                           ##
                           ##  @return Tvg_Result enumeration.
                           ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION The loader is not initialized.
                           ##
                           ##  @note If the font data is currently in use, it will not be immediately unloaded.
                           ##  @see tvg_font_load()
                           ##
                           ##  @since 0.15
                           ##

proc tvg_saver_new*(): ptr Tvg_Saver {.importc: "tvg_saver_new",
                                       dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_Text
                              ##
                              ##  @defgroup ThorVGCapi_Saver Saver
                              ##  @brief A module for exporting a paint object into a specified file.
                              ##
                              ##  The module enables to save the composed scene and/or image from a paint object.
                              ##  Once it's successfully exported to a file, it can be recreated using the Picture module.
                              ##
                              ##  \{
                              ##
                              ## *********************************************************************
                              ##  Saver API
                              ## *********************************************************************
                              ## !
                              ##  @brief Creates a new Tvg_Saver object.
                              ##
                              ##  @return A new Tvg_Saver object.
                              ##

proc tvg_saver_save*(saver: ptr Tvg_Saver; paint: ptr Tvg_Paint; path: cstring;
                     quality: uint32): Tvg_Result {.importc: "tvg_saver_save",
    dynlib: thorvgLibName.}
  ## !
                           ##  @brief Exports the given @p paint data to the given @p path
                           ##
                           ##  If the saver module supports any compression mechanism, it will optimize the data size.
                           ##  This might affect the encoding/decoding time in some cases. You can turn off the compression
                           ##  if you wish to optimize for speed.
                           ##
                           ##  @param[in] saver The Tvg_Saver object connected with the saving task.
                           ##  @param[in] paint The paint to be saved with all its associated properties.
                           ##  @param[in] path A path to the file, in which the paint data is to be saved.
                           ##  @param[in] quality The encoded quality level. @c 0 is the minimum, @c 100 is the maximum value(recommended).
                           ##
                           ##  @return Tvg_Result enumeration.
                           ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the argument.
                           ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION Currently saving other resources.
                           ##  @retval TVG_RESULT_NOT_SUPPORTED Trying to save a file with an unknown extension or in an unsupported format.
                           ##  @retval TVG_RESULT_UNKNOWN An empty paint is to be saved.
                           ##
                           ##  @note Saving can be asynchronous if the assigned thread number is greater than zero. To guarantee the saving is done, call tvg_saver_sync() afterwards.
                           ##  @see tvg_saver_sync()
                           ##

proc tvg_saver_sync*(saver: ptr Tvg_Saver): Tvg_Result {.
    importc: "tvg_saver_sync", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Guarantees that the saving task is finished.
                              ##
                              ##  The behavior of the Saver module works on a sync/async basis, depending on the threading setting of the Initializer.
                              ##  Thus, if you wish to have a benefit of it, you must call tvg_saver_sync() after the tvg_saver_save() in the proper delayed time.
                              ##  Otherwise, you can call tvg_saver_sync() immediately.
                              ##
                              ##  @param[in] saver The Tvg_Saver object connected with the saving task.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT A @c nullptr passed as the argument.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION No saving task is running.
                              ##
                              ##  @note The asynchronous tasking is dependent on the Saver module implementation.
                              ##  @see tvg_saver_save()
                              ##

proc tvg_saver_del*(saver: ptr Tvg_Saver): Tvg_Result {.
    importc: "tvg_saver_del", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Deletes the given Tvg_Saver object.
                              ##
                              ##  @param[in] saver The Tvg_Saver object to be deleted.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Saver pointer.
                              ##

proc tvg_animation_new*(): ptr Tvg_Animation {.importc: "tvg_animation_new",
    dynlib: thorvgLibName.}
  ##  \}
                           ##  end defgroup ThorVGCapi_Saver
                           ##
                           ##  @defgroup ThorVGCapi_Animation Animation
                           ##  @brief A module for manipulation of animatable images.
                           ##
                           ##  The module supports the display and control of animation frames.
                           ##
                           ##  \{
                           ##
                           ## *********************************************************************
                           ##  Animation API
                           ## *********************************************************************
                           ## !
                           ##  @brief Creates a new Animation object.
                           ##
                           ##  @return Tvg_Animation A new Tvg_Animation object.
                           ##
                           ##  @since 0.13
                           ##

proc tvg_animation_set_frame*(animation: ptr Tvg_Animation; no: cfloat): Tvg_Result {.
    importc: "tvg_animation_set_frame", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Specifies the current frame in the animation.
                              ##
                              ##  @param[in] animation A Tvg_Animation pointer to the animation object.
                              ##  @param[in] no The index of the animation frame to be displayed. The index should be less than the tvg_animation_get_total_frame().
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Animation pointer.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION if the given @p no is the same as the current frame value.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED The picture data does not support animations.
                              ##
                              ##  @note For efficiency, ThorVG ignores updates to the new frame value if the difference from the current frame value
                              ##        is less than 0.001. In such cases, it returns @c Result::InsufficientCondition.
                              ##        Values less than 0.001 may be disregarded and may not be accurately retained by the Animation.
                              ##  @see tvg_animation_get_total_frame()
                              ##
                              ##  @since 0.13
                              ##

proc tvg_animation_get_picture*(animation: ptr Tvg_Animation): ptr Tvg_Paint {.
    importc: "tvg_animation_get_picture", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Retrieves a picture instance associated with this animation instance.
                              ##
                              ##  This function provides access to the picture instance that can be used to load animation formats, such as lot.
                              ##  After setting up the picture, it can be pushed to the designated canvas, enabling control over animation frames
                              ##  with this Animation instance.
                              ##
                              ##  @param[in] animation A Tvg_Animation pointer to the animation object.
                              ##
                              ##  @return A picture instance that is tied to this animation.
                              ##
                              ##  @warning The picture instance is owned by Animation. It should not be deleted manually.
                              ##
                              ##  @since 0.13
                              ##

proc tvg_animation_get_frame*(animation: ptr Tvg_Animation; no: ptr cfloat): Tvg_Result {.
    importc: "tvg_animation_get_frame", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Retrieves the current frame number of the animation.
                              ##
                              ##  @param[in] animation A Tvg_Animation pointer to the animation object.
                              ##  @param[in] no The current frame number of the animation, between 0 and totalFrame() - 1.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Animation pointer or @p no
                              ##
                              ##  @see tvg_animation_get_total_frame()
                              ##  @see tvg_animation_set_frame()
                              ##
                              ##  @since 0.13
                              ##

proc tvg_animation_get_total_frame*(animation: ptr Tvg_Animation;
                                    cnt: ptr cfloat): Tvg_Result {.
    importc: "tvg_animation_get_total_frame", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Retrieves the total number of frames in the animation.
                              ##
                              ##  @param[in] animation A Tvg_Animation pointer to the animation object.
                              ##  @param[in] cnt The total number of frames in the animation.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Animation pointer or @p cnt.
                              ##
                              ##  @note Frame numbering starts from 0.
                              ##  @note If the Picture is not properly configured, this function will return 0.
                              ##
                              ##  @since 0.13
                              ##

proc tvg_animation_get_duration*(animation: ptr Tvg_Animation;
                                 duration: ptr cfloat): Tvg_Result {.
    importc: "tvg_animation_get_duration", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Retrieves the duration of the animation in seconds.
                              ##
                              ##  @param[in] animation A Tvg_Animation pointer to the animation object.
                              ##  @param[in] duration The duration of the animation in seconds.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Animation pointer or @p duration.
                              ##
                              ##  @note If the Picture is not properly configured, this function will return 0.
                              ##
                              ##  @since 0.13
                              ##

proc tvg_animation_set_segment*(animation: ptr Tvg_Animation; begin: cfloat;
                                `end`: cfloat): Tvg_Result {.
    importc: "tvg_animation_set_segment", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Specifies the playback segment of the animation.
                              ##
                              ##  The set segment is designated as the play area of the animation.
                              ##  This is useful for playing a specific segment within the entire animation.
                              ##  After setting, the number of animation frames and the playback time are calculated
                              ##  by mapping the playback segment as the entire range.
                              ##
                              ##  @param[in] animation The Tvg_Animation pointer to the animation object.
                              ##  @param[in] begin segment begin frame.
                              ##  @param[in] end segment end frame.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION In case the animation is not loaded.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT If the @p begin is higher than @p end.
                              ##
                              ##  @note Animation allows a range from 0.0 to the total frame. @p end should not be higher than @p begin.
                              ##  @note If a marker has been specified, its range will be disregarded.
                              ##
                              ##  @see tvg_lottie_animation_set_marker()
                              ##  @see tvg_animation_get_total_frame()
                              ##
                              ##  @since 1.0
                              ##

proc tvg_animation_get_segment*(animation: ptr Tvg_Animation; begin: ptr cfloat;
                                `end`: ptr cfloat): Tvg_Result {.
    importc: "tvg_animation_get_segment", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the current segment range information.
                              ##
                              ##  @param[in] animation The Tvg_Animation pointer to the animation object.
                              ##  @param[out] begin segment begin frame.
                              ##  @param[out] end segment end frame.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION In case the animation is not loaded.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Animation pointer.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_animation_del*(animation: ptr Tvg_Animation): Tvg_Result {.
    importc: "tvg_animation_del", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Deletes the given Tvg_Animation object.
                              ##
                              ##  @param[in] animation The Tvg_Animation object to be deleted.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Animation pointer.
                              ##
                              ##  @since 0.13
                              ##

proc tvg_accessor_new*(): ptr Tvg_Accessor {.importc: "tvg_accessor_new",
    dynlib: thorvgLibName.}
  ##  \}
                           ##  end defgroup ThorVGCapi_Animation
                           ##
                           ##  @defgroup ThorVGCapi_Accesssor Accessor
                           ##  @brief A module for manipulation of the scene tree
                           ##
                           ##  This module helps to control the scene tree.
                           ##  \{
                           ##
                           ## *********************************************************************
                           ##  Accessor API
                           ## *********************************************************************
                           ## !
                           ##  @brief Creates a new accessor object.
                           ##
                           ##  @return A new accessor object.
                           ##
                           ##  @note Experimental API
                           ##

proc tvg_accessor_del*(accessor: ptr Tvg_Accessor): Tvg_Result {.
    importc: "tvg_accessor_del", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Deletes the given accessor object.
                              ##
                              ##  @param[in] accessor The accessor object to be deleted.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Accessor pointer.
                              ##
                              ##  @note Experimental API
                              ##

proc tvg_accessor_set*(accessor: ptr Tvg_Accessor; paint: ptr Tvg_Paint; `func`: proc (
    paint: ptr Tvg_Paint; data: pointer): bool; data: pointer): Tvg_Result {.
    importc: "tvg_accessor_set", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Sets the paint of the accessor then iterates through its descendents.
                              ##
                              ##  Iterates through all descendents of the scene passed through the paint argument
                              ##  while calling func on each and passing the data pointer to this function. When
                              ##  func returns false iteration stops and the function returns.
                              ##
                              ##  @param[in] accessor A Tvg_Accessor pointer to the accessor object.
                              ##  @param[in] paint A Tvg_Paint pointer to the scene object.
                              ##  @param[in] func A function pointer to the function that will be execute for each child.
                              ##  @param[in] data A void pointer to data that will be passed to the func.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT An invalid Tvg_Accessor, Tvg_Paint, or function pointer.
                              ##
                              ##  @note Experimental API
                              ##

proc tvg_accessor_generate_id*(name: cstring): uint32 {.
    importc: "tvg_accessor_generate_id", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Generate a unique ID (hash key) from a given name.
                              ##
                              ##  This function computes a unique identifier value based on the provided string.
                              ##  You can use this to assign a unique ID to the Paint object.
                              ##
                              ##  @param[in] name The input string to generate the unique identifier from.
                              ##
                              ##  @return The generated unique identifier value.
                              ##
                              ##  @note Experimental API
                              ##

proc tvg_lottie_animation_new*(): ptr Tvg_Animation {.
    importc: "tvg_lottie_animation_new", dynlib: thorvgLibName.}
  ##
                              ##  \}
                              ##  end defgroup ThorVGCapi_Accessor
                              ##
                              ##  @defgroup ThorVGCapi_LottieAnimation LottieAnimation
                              ##  @brief A module for manipulation of lottie extension features.
                              ##
                              ##  The module enables control of advanced Lottie features.
                              ##  \{
                              ##
                              ## *********************************************************************
                              ##  LottieAnimation Extension API
                              ## *********************************************************************
                              ## !
                              ##  @brief Creates a new LottieAnimation object.
                              ##
                              ##  @return Tvg_Animation A new Tvg_LottieAnimation object.
                              ##
                              ##  @since 0.15
                              ##

proc tvg_lottie_animation_override*(animation: ptr Tvg_Animation; slot: cstring): Tvg_Result {.
    importc: "tvg_lottie_animation_override", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Override the lottie properties through the slot data.
                              ##
                              ##  @param[in] animation The Tvg_Animation object to override the property with the slot.
                              ##  @param[in] slot The Lottie slot data in json, or @c nullptr to reset.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION In case the animation is not loaded.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT When the given @p slot is invalid
                              ##  @retval TVG_RESULT_NOT_SUPPORTED The Lottie Animation is not supported.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_lottie_animation_set_marker*(animation: ptr Tvg_Animation;
                                      marker: cstring): Tvg_Result {.
    importc: "tvg_lottie_animation_set_marker", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Specifies a segment by marker.
                              ##
                              ##  @param[in] animation The Tvg_Animation pointer to the Lottie animation object.
                              ##  @param[in] marker The name of the segment marker.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION In case the animation is not loaded.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT When the given @p marker is invalid.
                              ##  @retval TVG_RESULT_NOT_SUPPORTED The Lottie Animation is not supported.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_lottie_animation_get_markers_cnt*(animation: ptr Tvg_Animation;
    cnt: ptr uint32): Tvg_Result {.importc: "tvg_lottie_animation_get_markers_cnt",
                                   dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the marker count of the animation.
                              ##
                              ##  @param[in] animation The Tvg_Animation pointer to the Lottie animation object.
                              ##  @param[out] cnt The count value of the markers.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case a @c nullptr is passed as the argument.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_lottie_animation_get_marker*(animation: ptr Tvg_Animation; idx: uint32;
                                      name: cstringArray): Tvg_Result {.
    importc: "tvg_lottie_animation_get_marker", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  @brief Gets the marker name by a given index.
                              ##
                              ##  @param[in] animation The Tvg_Animation pointer to the Lottie animation object.
                              ##  @param[in] idx The index of the animation marker, starts from 0.
                              ##  @param[out] name The name of marker when succeed.
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INVALID_ARGUMENT In case @c nullptr is passed as the argument or @c idx is out of range.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_lottie_animation_tween*(animation: ptr Tvg_Animation; `from`: cfloat;
                                 to: cfloat; progress: cfloat): Tvg_Result {.
    importc: "tvg_lottie_animation_tween", dynlib: thorvgLibName.}
  ##
                              ##
                              ##  @brief Interpolates between two frames over a specified duration.
                              ##
                              ##  This method performs tweening, a process of generating intermediate frame
                              ##  between @p from and @p to based on the given @p progress.
                              ##
                              ##  @param[in] animation The Tvg_Animation pointer to the Lottie animation object.
                              ##  @param[in] from The start frame number of the interpolation.
                              ##  @param[in] to The end frame number of the interpolation.
                              ##  @param[in] progress The current progress of the interpolation (range: 0.0 to 1.0).
                              ##
                              ##  @return Tvg_Result enumeration.
                              ##  @retval TVG_RESULT_INSUFFICIENT_CONDITION In case the animation is not loaded.
                              ##
                              ##  @since 1.0
                              ##

proc tvg_lottie_animation_assign*(animation: ptr Tvg_Animation; layer: cstring;
                                  ix: uint32; `var`: cstring; val: cfloat): Tvg_Result {.
    importc: "tvg_lottie_animation_assign", dynlib: thorvgLibName.}
  ##
                              ## !
                              ##  \brief Updates the value of an expression variable for a specific layer.
                              ##
                              ##  \param[in] animation The Tvg_Animation pointer to the Lottie animation object.
                              ##  \param[in] layer The name of the layer containing the variable to be updated.
                              ##  \param[in] ix The property index of the variable within the layer.
                              ##  \param[in] var The name of the variable to be updated.
                              ##  \param[in] val The new value to assign to the variable.
                              ##
                              ##  \return Tvg_Result enumeration.
                              ##  \retval TVG_RESULT_INSUFFICIENT_CONDITION If the animation is not loaded.
                              ##  \retval TVG_RESULT_INVALID_ARGUMENT When the given parameter is invalid.
                              ##  \retval TVG_RESULT_NOT_SUPPORTED When neither the layer nor the property is found in the current animation.
                              ##
                              ##  \note Experimental API
                              ##
##  \}
##  end addtogroup ThorVGCapi_LottieAnimation
##  \}
##  end defgroup ThorVGCapi
