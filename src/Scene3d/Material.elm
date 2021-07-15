module Scene3d.Material exposing
    ( Material
    , color, emissive, matte
    , nonmetal, metal, pbr
    , Texture, constant, load
    , texturedColor, texturedEmissive, texturedMatte, texturedNonmetal, texturedMetal, texturedPbr
    , loadWith, nearestNeighborFiltering, bilinearFiltering, trilinearFiltering
    , NormalMap, loadNormalMap, noNormalMap, loadNormalMapWith, NormalMapFormat, openglFormat, directxFormat
    , bumpyMatte, bumpyNonmetal, bumpyMetal, bumpyPbr
    , Plain, Unlit, Uniform, Textured, Bumpy
    , plain, unlit, uniform, textured
    )

{-|

@docs Material


# Simple materials

@docs color, emissive, matte


# Physically-based materials

[Physically based rendering](https://learnopengl.com/PBR/Theory) (PBR) is a
modern rendering technique that attempts to realistically render real-world
materials such as metals and plastics. `elm-3d-scene` uses a fairly simple,
common variant of PBR where materials have three main parameters:

  - Base color
  - Roughness, with 0 meaning perfectly smooth (shiny) and 1 meaning very rough
    (matte)
  - 'Metallicness', usually either 0 or 1, with 0 meaning non-metal and 1
    meaning metal

@docs nonmetal, metal, pbr


# Textured materials

[Textured](https://en.wikipedia.org/wiki/Texture_mapping) materials behave just
like their non-textured versions above, but require a mesh that has [UV](https://learnopengl.com/Getting-started/Textures)
(texture) coordinates. Color, roughness and metallicness can then be controlled
by a texture image instead of being restricted to constant values.

Note that images used as textures should generally have dimensions that are
powers of 2: 2048x2048, 1024x512, etc. Images you get from sites like [CC0
Textures](https://cc0textures.com/) will almost always have appropriate
dimensions, but if you want to use your own images some cropping/resizing may be
needed.

@docs Texture, constant, load

@docs texturedColor, texturedEmissive, texturedMatte, texturedNonmetal, texturedMetal, texturedPbr


## Customized textures

@docs loadWith, nearestNeighborFiltering, bilinearFiltering, trilinearFiltering


## Bumpy materials

@docs NormalMap, loadNormalMap, noNormalMap, loadNormalMapWith, NormalMapFormat, openglFormat, directxFormat

@docs bumpyMatte, bumpyNonmetal, bumpyMetal, bumpyPbr


# Type annotations

The functions in this module all return values with a 'free' type parameter -
for example, the return type of `Material.matte` is

    Material coordinates { a | normals : () }

This makes most code simpler (it means that such a material can work with _any_
kind of mesh that has normal vectors, even if for example that mesh also has
texture coordinates) but makes it tricky to store a `Material` value in your own
data structures without those data structures _also_ needing a type parameter.
The `coordinates` type parameter can usually be set to just `WorldCoordinates`
(a type you will need to define yourself), but the `a` is a bit trickier.

The type aliases and functions below help deal with this problem in a convenient
way. To store a material in a data structure, you can use one of the type
aliases. For example, the material above might be stored as a

    Material.Uniform WorldCoordinates

Then, if you need to turn this value _back_ into a

    Material coordinates { a | normals : () }

(so that you could apply it to a textured mesh, for example) you can use
`Material.uniform` to do so. You can think of `Material.uniform material` as
saying "yes, I know this is a uniform material, but I still want to apply it to
this textured mesh".

@docs Plain, Unlit, Uniform, Textured, Bumpy

@docs plain, unlit, uniform, textured

-}

import Color exposing (Color)
import Luminance exposing (Luminance)
import Math.Vector4 exposing (Vec4)
import Quantity
import Scene3d.ColorConversions as ColorConversions
import Scene3d.Types as Types exposing (Chromaticity, LinearRgb(..), NormalMapFormat)
import Task exposing (Task)
import WebGL.Texture


{-| A `Material` controls the color, reflectivity etc. of a given object. It may
be constant across the object or be textured.

The `attributes` type parameter of a material is used to restrict what objects
it can be used with. For example, `Material.matte` returns a value with an
`attributes` type of `{ a | normals : () }`; you can read this as "this material
can be applied to any mesh that has normals".

The `coordinates` type parameter is currently unused but will be used in the
future for things like [procedural textures](https://en.wikipedia.org/wiki/Procedural_texture)
defined in a particular coordinate system; those textures will then only be able
to be applied to objects defined in the same coordinate system.

-}
type alias Material coordinates attributes =
    Types.Material coordinates attributes


{-| A simple constant color material. This material can be applied to any
object and ignores lighting entirely - the entire object will have exactly the
given color regardless of lights or scene exposure/white balance settings.
Here's a rubber duck model with a constant blue color:

![Duckling with constant color](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/constant-color.png)

Note that transparency is not currently supported, so any alpha value in the
given color will be ignored.

-}
color : Color -> Material coordinates attributes
color givenColor =
    Types.UnlitMaterial Types.UseMeshUvs (Types.Constant (toVec4 givenColor))


{-| A perfectly matte ([Lambertian](https://en.wikipedia.org/wiki/Lambertian_reflectance))
material which reflects light equally in all directions. Lambertian materials
are faster to render than physically-based materials like `Material.metal` or
`Material.nonmetal`, so consider using them for large surfaces like floors that
don't need to be shiny:

![Matte duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/matte.png)

(Note that this doesn't appear to be quite the same blue as before, since the
lights themselves are colored.)

-}
matte : Color -> Material coordinates { a | normals : () }
matte materialColor =
    Types.LambertianMaterial Types.UseMeshUvs
        (Types.Constant (ColorConversions.colorToLinearRgb materialColor))
        (constant 1)
        Types.NoNormalMap


{-| An emissive or 'glowing' material, where you specify the [chromaticity](Scene3d#Chromaticity)
and intensity of the emitted light. The result will be a constant color, but one
that (unlike [`Material.color`](#color)) will depend on the exposure and white
balance settings used when rendering the scene.
-}
emissive : Chromaticity -> Luminance -> Material coordinates attributes
emissive givenChromaticity brightness =
    let
        baseColor =
            ColorConversions.chromaticityToLinearRgb (Quantity.float 1) givenChromaticity
    in
    Types.EmissiveMaterial Types.UseMeshUvs (Types.Constant baseColor) brightness


{-| A metal material such as steel, aluminum, gold etc. See [here](https://docs.unrealengine.com/en-US/Engine/Rendering/Materials/PhysicallyBased/index.html)
and [here](https://www.chaosgroup.com/blog/understanding-metalness) for base
colors of different metals. Here's what 'blue metal' might look like:

![Rough metal duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/rough-metal.png)

As with nonmetals, roughness can be decreased to get a shinier surface:

![Shiny metal duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/shiny-metal.png)

Note that metals are generally more sensitive to light direction than nonmetals,
so if you only have directional and/or point lights in your scene then metallic
objects will often have a couple bright highlights but otherwise be very dark.
This can usually be addressed by using at least a small amount of [soft lighting](Scene3d-Light#soft)
so that there is at least a small amount of light coming from _every_ direction.

-}
metal : { baseColor : Color, roughness : Float } -> Material coordinates { a | normals : () }
metal { baseColor, roughness } =
    pbr { baseColor = baseColor, roughness = roughness, metallic = 1 }


{-| A non-metal material such as plastic, wood, paper etc. This allows for some
nice lighting highlights compared to `matte`:

![Rough plastic duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/rough-plastic.png)

An even shinier version (lower roughness):

![Shiny plastic duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/shiny-plastic.png)

-}
nonmetal : { baseColor : Color, roughness : Float } -> Material coordinates { a | normals : () }
nonmetal { baseColor, roughness } =
    pbr { baseColor = baseColor, roughness = roughness, metallic = 0 }


{-| A custom PBR material with a `metallic` parameter that can be anywhere
between 0 and 1. Values in between 0 and 1 can be used to approximate things
like dusty metal, where a surface can be thought of as partially metal and
partially non-metal:

![Partially metallic duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/partially-metallic.png)

-}
pbr :
    { baseColor : Color, roughness : Float, metallic : Float }
    -> Material coordinates { a | normals : () }
pbr { baseColor, roughness, metallic } =
    Types.PbrMaterial Types.UseMeshUvs
        (Types.Constant (ColorConversions.colorToLinearRgb baseColor))
        (Types.Constant (clamp 0 1 roughness))
        (Types.Constant (clamp 0 1 metallic))
        (Types.Constant 1)
        Types.NoNormalMap


{-| A `Texture` value represents an image that is mapped over the surface of an
object. Textures can be used to control the color at different points on an
object (`Texture Color`) but can also be used to control roughness or
metallicness when using a physically-based material (`Texture Float`).
-}
type alias Texture value =
    Types.Texture value


{-| A special texture that has the same value everywhere. This can be useful
with materials like [`texturedPbr`](#texturedPbr) which take multiple `Texture`
arguments; sometimes you might want to use an actual texture for color but a
constant value for roughness (or vice versa). For example, you might use

    Material.constant blue

instead of loading a `Texture Color` from an image, or

    Material.constant 0.5

to use a constant roughness value instead of a `Texture Float` loaded from an
image.

-}
constant : value -> Texture value
constant givenValue =
    Types.Constant givenValue


{-| Load a texture from a given URL. Note that the resulting value can be used
as either a `Texture Color` _or_ a `Texture Float` - if used as a
`Texture Float` then it will be the greyscale value of each pixel that is used
(more precisely, its [luminance](https://en.wikipedia.org/wiki/Relative_luminance)).

The loaded texture will use [bilinear texture filtering](#bilinearFiltering). To
use nearest-neighbor filtering, trilinear filtering or to customize other
texture options, use [`loadWith`](#loadWith) instead.

-}
load : String -> Task WebGL.Texture.Error (Texture value)
load url =
    loadWith bilinearFiltering url


{-| Load a texture with particular [options](https://package.elm-lang.org/packages/elm-explorations/webgl/latest/WebGL-Texture#Options),
which control things like what form of [texture filtering](https://en.wikipedia.org/wiki/Texture_filtering)
is used and how out-of-range texture coordinates are interpreted (clamped,
wrapped around, etc.).

This module contains a few reasonable defaults ([`nearestNeighborFiltering`](#nearestNeighborFiltering),
[`bilinearFiltering`](#bilinearFiltering), and [`trilinearFiltering`](#trilinearFiltering))
but you can directly construct your own custom options record if desired.
Unfortunately there's no one set of texture options that works well in all
cases, so you may need to experiment to see what works best in your particular
scene.

-}
loadWith : WebGL.Texture.Options -> String -> Task WebGL.Texture.Error (Texture value)
loadWith options url =
    WebGL.Texture.loadWith options url
        |> Task.map
            (\data ->
                Types.Texture
                    { url = url
                    , options = options
                    , data = data
                    }
            )


loadNormalMapWith : { format : NormalMapFormat, options : WebGL.Texture.Options } -> String -> Task WebGL.Texture.Error NormalMap
loadNormalMapWith { format, options } url =
    WebGL.Texture.loadWith options url
        |> Task.map
            (\data ->
                Types.NormalMap
                    { url = url
                    , options = options
                    , format = format
                    , data = data
                    }
            )


openglFormat : NormalMapFormat
openglFormat =
    Types.OpenglFormat


directxFormat : NormalMapFormat
directxFormat =
    Types.DirectxFormat


{-| Don't interpolate between texture pixels at all when rendering; each
on-screen pixel will simply get the color of the _nearest_ texture pixel. This
can be useful if you're deliberately going for a 'pixelated' look and want
texture pixels to show up exactly on screen without any blurring. In most cases,
though, using nearest-neighbor filtering will lead to unpleasant jagged edges
(this is a zoomed-in portion of the Elm logo applied as a texture to a simple
[quad](Scene3d#quad)):

![Nearest neighbor texture filtering](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/nearest-neighbor-filtering.png)

Note that the upper-right edge is smooth because that's actually the edge of the
textured quad, instead of an edge between two different colors _within_ the
texture.

Nearest-neighbor filtering is implemented as:

    nearestNeighborFiltering =
        { minify = WebGL.Texture.nearest
        , magnify = WebGL.Texture.nearest
        , horizontalWrap = WebGL.Texture.repeat
        , verticalWrap = WebGL.Texture.repeat
        , flipY = True
        }

-}
nearestNeighborFiltering : WebGL.Texture.Options
nearestNeighborFiltering =
    { minify = WebGL.Texture.nearest
    , magnify = WebGL.Texture.nearest
    , horizontalWrap = WebGL.Texture.repeat
    , verticalWrap = WebGL.Texture.repeat
    , flipY = True
    }


{-| Apply some simple texture smoothing; each on-screen pixel will be a weighted
average of the four closest texture pixels. This will generally lead to
slightly smoother edges than nearest-neighbor filtering, at least for cases
where one texture pixel is approximately the same size as one screen pixel:

![Bilinear texture filtering](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/bilinear-filtering.png)

No [mipmapping](https://en.wikipedia.org/wiki/Mipmap) is used, so
pixelation/aliasing may still occur especially for far-away objects where one
texture pixel is much smaller than one screen pixel.

Bilinear filtering is implemented as:

    bilinearFiltering =
        { minify = WebGL.Texture.linear
        , magnify = WebGL.Texture.linear
        , horizontalWrap = WebGL.Texture.repeat
        , verticalWrap = WebGL.Texture.repeat
        , flipY = True
        }

-}
bilinearFiltering : WebGL.Texture.Options
bilinearFiltering =
    { minify = WebGL.Texture.linear
    , magnify = WebGL.Texture.linear
    , horizontalWrap = WebGL.Texture.repeat
    , verticalWrap = WebGL.Texture.repeat
    , flipY = True
    }


{-| Interpolate between nearby texture pixels as with bilinear filtering, but
_also_ interpolate between the two nearest [mipmap](https://en.wikipedia.org/wiki/Mipmap)
levels. This will generally give the smoothest possible appearance, but may also
lead to excessive blurriness:

![Trilinear texture filtering](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/trilinear-filtering.png)

Trilinear filtering is implemented as:

    trilinearFiltering =
        { minify = WebGL.Texture.linearMipmapLinear
        , magnify = WebGL.Texture.linear
        , horizontalWrap = WebGL.Texture.repeat
        , verticalWrap = WebGL.Texture.repeat
        , flipY = True
        }

-}
trilinearFiltering : WebGL.Texture.Options
trilinearFiltering =
    { minify = WebGL.Texture.linearMipmapLinear
    , magnify = WebGL.Texture.linear
    , horizontalWrap = WebGL.Texture.repeat
    , verticalWrap = WebGL.Texture.repeat
    , flipY = True
    }


map : (a -> b) -> Texture a -> Texture b
map function texture =
    case texture of
        Types.Constant value ->
            Types.Constant (function value)

        Types.Texture properties ->
            Types.Texture properties


toVec4 : Color -> Vec4
toVec4 givenColor =
    let
        { red, green, blue, alpha } =
            Color.toRgba givenColor
    in
    Math.Vector4.vec4 red green blue alpha


{-| A textured plain-color material, unaffected by lighting.

![Textured color duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/textured-color.png)

-}
texturedColor : Texture Color -> Material coordinates { a | uvs : () }
texturedColor colorTexture =
    Types.UnlitMaterial Types.UseMeshUvs (map toVec4 colorTexture)


{-| A textured matte material.

![Textured matte duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/textured-matte.png)

-}
texturedMatte : Texture Color -> Material coordinates { a | normals : (), uvs : () }
texturedMatte colorTexture =
    Types.LambertianMaterial Types.UseMeshUvs
        (map ColorConversions.colorToLinearRgb colorTexture)
        (constant 1)
        Types.NoNormalMap


{-| A textured emissive material. The color from the texture will be multiplied
by the given luminance to obtain the final emissive color.
-}
texturedEmissive : Texture Color -> Luminance -> Material coordinates { a | uvs : () }
texturedEmissive colorTexture brightness =
    Types.EmissiveMaterial Types.UseMeshUvs
        (map ColorConversions.colorToLinearRgb colorTexture)
        brightness


{-| A textured metal material.

![Textured metal duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/textured-metal.png)

-}
texturedMetal :
    { baseColor : Texture Color
    , roughness : Texture Float
    }
    -> Material coordinates { a | normals : (), uvs : () }
texturedMetal { baseColor, roughness } =
    texturedPbr
        { baseColor = baseColor
        , roughness = roughness
        , metallic = constant 1
        }


{-| A textured non-metal material. If you only have a texture for one of the two
parameters (base color and roughness), you can use [`Material.constant`](#constant)
for the other. Here's a model with a textured base color but constant roughness:

![Rough textured nonmetal duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/textured-nonmetal-rough.png)

The same model but with roughness decreased for a shinier appearance:

![Shiny textured nonmetal duckling](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/textured-nonmetal-shiny.png)

-}
texturedNonmetal :
    { baseColor : Texture Color
    , roughness : Texture Float
    }
    -> Material coordinates { a | normals : (), uvs : () }
texturedNonmetal { baseColor, roughness } =
    texturedPbr
        { baseColor = baseColor
        , roughness = roughness
        , metallic = constant 0
        }


{-| A fully custom textured PBR material, where textures can be used to control
all three parameters. As before, you can freely mix and match 'actual' textures
with [`constant`](#constant) values for any of the three parameters. For
example, here's a sphere with textured base color and textured metallicness but
constant roughness:

![Sphere with constant roughness](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/constant-roughness.png)

(You can see the effect of the textured metallicness in the small reddish rusty
areas on the lower right-hand side.) Here's the same sphere but with a texture
also used to control roughness - note how the rough scratches catch light that
would otherwise be reflected away from the camera:

![Sphere with textured roughness](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/textured-roughness.png)

-}
texturedPbr :
    { baseColor : Texture Color
    , roughness : Texture Float
    , metallic : Texture Float
    }
    -> Material coordinates { a | normals : (), uvs : () }
texturedPbr { baseColor, roughness, metallic } =
    Types.PbrMaterial Types.UseMeshUvs
        (map ColorConversions.colorToLinearRgb baseColor)
        (map (clamp 0 1) roughness)
        (map (clamp 0 1) metallic)
        (constant 1)
        Types.NoNormalMap


type alias NormalMap =
    Types.NormalMap


type alias NormalMapFormat =
    Types.NormalMapFormat


noNormalMap : NormalMap
noNormalMap =
    Types.NoNormalMap


loadNormalMap : String -> Task WebGL.Texture.Error NormalMap
loadNormalMap url =
    loadNormalMapWith { format = openglFormat, options = trilinearFiltering } url


bumpyMatte : Texture Color -> Texture Float -> NormalMap -> Bumpy coordinates
bumpyMatte colorTexture ambientOcclusionTexture normalMapTexture =
    Types.LambertianMaterial Types.UseMeshUvs
        (map ColorConversions.colorToLinearRgb colorTexture)
        ambientOcclusionTexture
        normalMapTexture


bumpyMetal :
    { baseColor : Texture Color
    , roughness : Texture Float
    , ambientOcclusion : Texture Float
    , normalMap : NormalMap
    }
    -> Bumpy coordinates
bumpyMetal { baseColor, roughness, ambientOcclusion, normalMap } =
    bumpyPbr
        { baseColor = baseColor
        , roughness = roughness
        , metallic = constant 1
        , ambientOcclusion = ambientOcclusion
        , normalMap = normalMap
        }


bumpyNonmetal :
    { baseColor : Texture Color
    , roughness : Texture Float
    , ambientOcclusion : Texture Float
    , normalMap : NormalMap
    }
    -> Bumpy coordinates
bumpyNonmetal { baseColor, roughness, ambientOcclusion, normalMap } =
    bumpyPbr
        { baseColor = baseColor
        , roughness = roughness
        , metallic = constant 0
        , ambientOcclusion = ambientOcclusion
        , normalMap = normalMap
        }


bumpyPbr :
    { baseColor : Texture Color
    , roughness : Texture Float
    , metallic : Texture Float
    , ambientOcclusion : Texture Float
    , normalMap : NormalMap
    }
    -> Bumpy coordinates
bumpyPbr { baseColor, roughness, metallic, ambientOcclusion, normalMap } =
    Types.PbrMaterial Types.UseMeshUvs
        (map ColorConversions.colorToLinearRgb baseColor)
        (map (clamp 0 1) roughness)
        (map (clamp 0 1) metallic)
        (map (clamp 0 1) ambientOcclusion)
        normalMap


{-| A material that doesn't require any particular vertex attributes. The only
possibilities here are [`color`](#color) and [`emissive`](#emissive).
-}
type alias Plain coordinates =
    Material coordinates {}


{-| A material that requires normal vectors but not UV coordinates: [`matte`](#matte),
[`metal`](#metal), [`nonmetal`](#nonmetal) or [`pbr`](#pbr).
-}
type alias Uniform coordinates =
    Material coordinates { normals : () }


{-| A material that requires UV (texture) coordinates but not normal vectors:
[`texturedColor`](#texturedColor) or [`texturedEmissive`](#texturedEmissive).
-}
type alias Unlit coordinates =
    Material coordinates { uvs : () }


{-| A material that requires both normal vectors and UV coordinates:
[`texturedMatte`](#texturedMatte), [`texturedMetal`](#texturedMetal),
[`texturedNonmetal`](#texturedNonmetal) or [`texturedPbr`](#texturedPbr).
-}
type alias Textured coordinates =
    Material coordinates { normals : (), uvs : () }


type alias Anisotropic coordinates =
    Material coordinates { normals : (), tangents : () }


type alias Bumpy coordinates =
    Material coordinates { normals : (), uvs : (), tangents : () }


{-| Convert a `Plain` material (that can only be applied to a [`Plain`](Scene3d-Mesh#Plain)
mesh) back into one that can be applied to _any_ mesh.
-}
plain : Plain coordinates -> Material coordinates attributes
plain =
    coerce


{-| Convert a `Uniform` material (one that can only be applied to a [`Uniform`](Scene3d-Mesh#Uniform)
mesh) back into one that can be applied to _any_ mesh that has normal vectors.
-}
uniform : Uniform coordinates -> Material coordinates { a | normals : () }
uniform =
    coerce


{-| Convert an `Unlit` material (one that can only be applied to an [`Unlit`](Scene3d-Mesh#Unlit)
mesh) back into one that can be applied to _any_ mesh that has texture
coordinates.
-}
unlit : Unlit coordinates -> Material coordinates { a | uvs : () }
unlit =
    coerce


{-| Convert a `Textured` material (one that can only be applied to a
[`Textured`](Scene3d-Mesh#Textured) mesh) back into one that can be applied to
_any_ mesh that has normal vectors and texture coordinates.
-}
textured : Textured coordinates -> Material coordinates { a | normals : (), uvs : () }
textured =
    coerce


anisotropic : Anisotropic coordinates -> Material coordinates { a | normals : (), tangents : () }
anisotropic =
    coerce


coerce : Material coordinates a -> Material coordinates b
coerce material =
    case material of
        Types.UnlitMaterial textureMap colorTexture ->
            Types.UnlitMaterial textureMap colorTexture

        Types.EmissiveMaterial textureMap colorTexture brightness ->
            Types.EmissiveMaterial textureMap colorTexture brightness

        Types.LambertianMaterial textureMap colorTexture ambientOcclusionTexture normalMapTexture ->
            Types.LambertianMaterial textureMap colorTexture ambientOcclusionTexture normalMapTexture

        Types.PbrMaterial textureMap colorTexture roughnessTexture metallicTexture ambientOcclusionTexture normalMapTexture ->
            Types.PbrMaterial textureMap colorTexture roughnessTexture metallicTexture ambientOcclusionTexture normalMapTexture
