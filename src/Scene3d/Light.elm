module Scene3d.Light exposing
    ( Light, CastsShadows
    , castsShadows, neverCastsShadows
    , directional, point, soft, overhead, ambient, disabled
    , Chromaticity
    , color, daylight, sunlight, skylight, incandescent, fluorescent, colorTemperature, chromaticity
    )

{-|

@docs Light, CastsShadows

@docs castsShadows, neverCastsShadows

@docs directional, point, soft, overhead, ambient, disabled


## Chromaticity

@docs Chromaticity

@docs color, daylight, sunlight, skylight, incandescent, fluorescent, colorTemperature, chromaticity

-}

import Color exposing (Color)
import Direction3d exposing (Direction3d)
import Illuminance exposing (Illuminance)
import Length exposing (Meters)
import LuminousFlux exposing (LuminousFlux)
import Math.Vector3 exposing (Vec3)
import Math.Vector4
import Point3d exposing (Point3d)
import Quantity
import Scene3d.ColorConversions as ColorConversions
import Scene3d.Types as Types exposing (LightMatrices, LinearRgb(..))
import Temperature exposing (Temperature)



----- LIGHT SOURCES -----
--
-- type:
--   0 : disabled
--   1 : directional (XYZ is direction to light, i.e. reversed light direction)
--   2 : point (XYZ is light position)
--   3 : soft lighting (XYZ is up direction, parameter is ratio of below luminance to above)
--
-- [ x_i     r_i          x_j     r_j         ]
-- [ y_i     g_i          y_j     g_j         ]
-- [ z_i     b_i          z_j     b_j         ]
-- [ type_i  parameter_i  type_j  parameter_j ]


{-| A `Light` represents a single source of light in the scene, such as the sun
or a light bulb. Lights are not rendered themselves; they can only be seen by
how they interact with objects in the scene.
-}
type alias Light coordinates castsShadows =
    Types.Light coordinates castsShadows


{-| A 'light' that does not actually do anything. Can be useful if you have
some conditional logic that decides whether a particular light is on or off:

    lamp =
        if model.lampIsOn then
            Light.point (Light.castsShadows True)
                { position = model.lampPosition
                , chromaticity = Light.incandescent
                , intensity = LuminousFlux.lumens 400
                }

        else
            Light.disabled

-}
disabled : Light coordinates castsShadows
disabled =
    Types.Light
        { type_ = 0
        , castsShadows = False
        , x = 0
        , y = 0
        , z = 0
        , r = 0
        , g = 0
        , b = 0
        , parameter = 0
        }


{-| The `CastsShadows` type is used to indicate either whether a given light
casts shadows. Lights can usually be constructed using `Light.castsShadows True`
or `Light.castsShadows False`, but if you want to use more than four lights in a
scene then the extra lights must be constructed with the special
`Light.neverCastsShadows` value. This system allows the first four lights to
have shadows dynamically enabled/disabled at runtime, while using the type
system to guarantee that no more than four lights ever cast shadows.
-}
type CastsShadows a
    = CastsShadows Bool


{-| Construct a `CastsShadows Bool` value used to indicate whether a given
light casts shadows.
-}
castsShadows : Bool -> CastsShadows Bool
castsShadows flag =
    CastsShadows flag


{-| Construct a special `CastsShadows Never` value used to indicate that a given
light never casts shadows.
-}
neverCastsShadows : CastsShadows Never
neverCastsShadows =
    CastsShadows False


{-| Create a directional light given its chromaticity, intensity, direction, and
whether or not it casts shadows:

    sunlightAtNoon =
        Light.directional (Light.castsShadows True)
            { chromaticity = Light.sunlight
            , intensity = Illuminance.lux 80000
            , direction = Direction3d.negativeZ
            }

Note that the `direction` is the direction the light is traveling (the direction
_of_ the light, not the direction _to_ the light source from the scene).

Directional lights cast uniform light across the entire scene and result in
relatively simple shadows:

![Scene illuminated by a directional light](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/directional-light.png)

(Note that this scene also includes some [soft lighting](#soft) in addition to
the directional light.)

-}
directional :
    CastsShadows castsShadows
    ->
        { chromaticity : Chromaticity
        , intensity : Illuminance
        , direction : Direction3d coordinates
        }
    -> Light coordinates castsShadows
directional (CastsShadows shadowFlag) light =
    let
        { x, y, z } =
            Direction3d.unwrap light.direction

        (LinearRgb rgb) =
            ColorConversions.chromaticityToLinearRgb light.intensity light.chromaticity
    in
    Types.Light
        { type_ = 1
        , castsShadows = shadowFlag
        , x = -x
        , y = -y
        , z = -z
        , r = Math.Vector4.getX rgb
        , g = Math.Vector4.getY rgb
        , b = Math.Vector4.getZ rgb
        , parameter = 0
        }


{-| Create a point light given its chromaticity, intensity, position, and
whether or not it casts shadows:

    tableLamp =
        Light.point (Light.castsShadows True)
            { chromaticity = Light.incandescent
            , intensity = LuminousFlux.lumens 500
            , position = Point3d.centimeters 40 50 30
            }

Compared to a directional light, the illumination from a point light varies more
over the scene (brighter close to the light, less bright further away) and
results in more interesting shadows:

![Scene illuminated by a point light](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/point-light.png)

(Note that this scene also includes some [soft lighting](#soft) in addition to
the point light.)

-}
point :
    CastsShadows castsShadows
    ->
        { chromaticity : Chromaticity
        , intensity : LuminousFlux
        , position : Point3d Meters coordinates
        }
    -> Light coordinates castsShadows
point (CastsShadows shadowFlag) light =
    let
        (LinearRgb rgb) =
            ColorConversions.chromaticityToLinearRgb light.intensity light.chromaticity

        { x, y, z } =
            Point3d.unwrap light.position
    in
    Types.Light
        { type_ = 2
        , castsShadows = shadowFlag
        , x = x
        , y = y
        , z = z
        , r = Math.Vector4.getX rgb
        , g = Math.Vector4.getY rgb
        , b = Math.Vector4.getZ rgb
        , parameter = 0
        }


{-| Add some 'soft' indirect/environmental lighting to a scene: this is a rough
approximation for light coming from all different directions, such as light
coming from the sky (as opposed to direct sunlight) or indirect lighting
reflected from surrounding surfaces. The intensity of the light will vary
smoothly from a given intensity 'above' to 'below', based on given 'up'
direction and with a given chromaticity.

For example, a decent approximation to indoors office lighting might be:

    Light.soft
        { upDirection = Direction3d.positiveZ
        , chromaticity = Light.fluorescent
        , intensityAbove = Illuminance.lux 400
        , intensityBelow = Illuminance.lux 100
        }

Note that soft lighting does not cast shadows. Soft lighting is a great way to
make sure the entire scene has some reasonable illumination; the [point](#point)
and [directional](#directional) light examples both include a small amount of
soft lighting to 'fill in' otherwise unlit areas. For example, here's the point
light example _without_ any additional lighting:

![Scene illuminated by a point light only](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/point-light-only.png)

Conversely, soft lighting by itself can be a bit boring, so in many cases you'll
want to add one or more point and/or directional lights to add interest:

![Scene illuminated by soft lighting only](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/soft-lighting.png)

-}
soft :
    { upDirection : Direction3d coordinates
    , chromaticity : Chromaticity
    , intensityAbove : Illuminance
    , intensityBelow : Illuminance
    }
    -> Light coordinates Never
soft light =
    if light.intensityAbove == Quantity.zero && light.intensityBelow == Quantity.zero then
        disabled

    else if
        Quantity.abs light.intensityBelow
            |> Quantity.greaterThan (Quantity.abs light.intensityAbove)
    then
        soft
            { upDirection = Direction3d.reverse light.upDirection
            , chromaticity = light.chromaticity
            , intensityAbove = light.intensityBelow
            , intensityBelow = light.intensityAbove
            }

    else
        let
            (LinearRgb rgb) =
                ColorConversions.chromaticityToLinearRgb (Quantity.float 1) light.chromaticity

            nitsAbove =
                abs (Illuminance.inLux light.intensityAbove / pi)

            nitsBelow =
                abs (Illuminance.inLux light.intensityBelow / pi)

            { x, y, z } =
                Direction3d.unwrap light.upDirection
        in
        Types.Light
            { type_ = 3
            , castsShadows = False
            , x = x
            , y = y
            , z = z
            , r = nitsAbove * Math.Vector4.getX rgb
            , g = nitsAbove * Math.Vector4.getY rgb
            , b = nitsAbove * Math.Vector4.getZ rgb
            , parameter = nitsBelow / nitsAbove
            }


{-| A slightly simplified version of `Light.soft` with the given intensity
above and zero intensity below. This can be useful if you want _color_
(chromaticity) to also vary from above to below; for example, for and outdoors
scene you might use two 'overhead' lights with different chromaticities and
opposite 'up' directions to represent light from the blue sky plus some more
neutral-colored light reflected from the surrounding environment:

    sky =
        Light.overhead
            { upDirection = Direction3d.positiveZ
            , chromaticity = Light.skylight
            , intensity = Illuminance.lux 20000
            }

    environment =
        Light.overhead
            { upDirection = Direction3d.negativeZ
            , chromaticity = Light.daylight
            , intensity = Illuminance.lux 15000
            }

Note that the `environment` light has the 'up' direction set to _negative_ Z
since that light mostly comes from below (reflected from the ground) than above.

-}
overhead :
    { upDirection : Direction3d coordinates
    , chromaticity : Chromaticity
    , intensity : Illuminance
    }
    -> Light coordinates Never
overhead arguments =
    soft
        { upDirection = arguments.upDirection
        , chromaticity = arguments.chromaticity
        , intensityAbove = arguments.intensity
        , intensityBelow = Quantity.zero
        }


{-| A simple version of `Light.soft` with constant intensity light in every
direction. Provided for completeness, but you generally won't want to use this
as it tends to result in very flat, unrealistic-looking scenes:

![Scene illuminated by ambient lighting](https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/ambient-lighting.png)

-}
ambient :
    { chromaticity : Chromaticity
    , intensity : Illuminance
    }
    -> Light coordinates Never
ambient arguments =
    soft
        { upDirection = Direction3d.z
        , chromaticity = arguments.chromaticity
        , intensityAbove = arguments.intensity
        , intensityBelow = arguments.intensity
        }



----- CHROMATICITY -----


{-| [Chromaticity](https://en.wikipedia.org/wiki/Chromaticity) is a precise way
of describing color independent of brightness. You can think of it as roughly
hue and saturation without value or lightness.

Chromaticity is used for specifying the color of individual lights as well as
the white balance to use for the overall scene.

-}
type alias Chromaticity =
    Types.Chromaticity


{-| The approximate chromaticity of noon daylight; this is a combination of
direct sunlight and blue sky, so is slightly cooler than pure [sunlight](#sunlight).
As a result, this is a good default choice for white balance and indirect
lighting, but for direct lighting you'll likely want to use [`sunlight`](#sunlight),
[`skylight`](#skylight), [`incandescent`](#incandescent) or [`fluorescent`](#fluorescent) instead.

This is standardized as [Illuminant D65, "Noon Daylight"](https://en.wikipedia.org/wiki/Standard_illuminant),
and is the 'white' color of a properly-calibrated [sRGB](https://en.wikipedia.org/wiki/SRGB)
monitor.

-}
daylight : Chromaticity
daylight =
    chromaticity { x = 0.31271, y = 0.32902 }


{-| An approximate chromaticity value for direct daytime sunlight. This doesn't
seem to have an offically standardized value, but 'sunlight' film is apparently
calibrated to a color temperature of 5600 K so that is what is used here. (This
falls at low end of ['vertical daylight'](https://en.wikipedia.org/wiki/Color_temperature)
and above 'horizon daylight', so should be a decent representative value.)
-}
sunlight : Chromaticity
sunlight =
    colorTemperature (Temperature.kelvins 5600)


{-| An approximate chromaticity value for clear blue sky. There seems to be even
less agreement on a representative value to use here, but a color temperature of
12000 K seems fairly reasonable (see e.g. [here](https://www.researchgate.net/figure/CIE-1931-chromaticities-of-our-1567-Granada-clear-skylight-spectra-open-circles_fig2_12125220)).
-}
skylight : Chromaticity
skylight =
    colorTemperature (Temperature.kelvins 12000)


{-| The chromaticity of typical incandescent/tungsten lighting. This is
standardized as [Illuminant A, "Incandescent/Tungsten"](https://en.wikipedia.org/wiki/Standard_illuminant).
-}
incandescent : Chromaticity
incandescent =
    chromaticity { x = 0.44757, y = 0.40745 }


{-| The chromaticity of typical fluorescent lighting. This is standardized as
[Illuminant F2, "Cool White Fluorescent"](https://en.wikipedia.org/wiki/Standard_illuminant).
-}
fluorescent : Chromaticity
fluorescent =
    chromaticity { x = 0.37208, y = 0.37529 }


{-| Specify chromaticity by its _xy_ coordinates in the [CIE xyY color space](https://en.wikipedia.org/wiki/CIE_1931_color_space#CIE_xy_chromaticity_diagram_and_the_CIE_xyY_color_space).
-}
chromaticity : { x : Float, y : Float } -> Chromaticity
chromaticity xy =
    Types.Chromaticity xy


{-| Specify chromaticity by providing a [color temperature](https://en.wikipedia.org/wiki/Color_temperature).
For example, `Light.daylight` is equivalent to

    Light.colorTemperature (Temperature.kelvins 5600)

See [here](https://en.wikipedia.org/wiki/Standard_illuminant#White_points_of_standard_illuminants)
for the color temperatures of many common sources of light.

-}
colorTemperature : Temperature -> Chromaticity
colorTemperature temperature =
    let
        t =
            clamp 1667 25000 (Temperature.inKelvins temperature)

        x =
            if t <= 4000 then
                (-0.2661239 * 1.0e9 / (t * t * t))
                    - (0.2343589 * 1.0e6 / (t * t))
                    + (0.8776956 * 1.0e3 / t)
                    + 0.17991

            else
                (-3.0258469 * 1.0e9 / (t * t * t))
                    + (2.1070379 * 1.0e6 / (t * t))
                    + (0.2226347 * 1.0e3 / t)
                    + 0.24039

        y =
            if t <= 2222 then
                (-1.1063814 * (x * x * x))
                    - (1.3481102 * (x * x))
                    + (2.18555832 * x)
                    - 0.20219683

            else if t <= 4000 then
                (-0.9549476 * (x * x * x))
                    - (1.37418593 * (x * x))
                    + (2.09137015 * x)
                    - 0.16748867

            else
                (3.081758 * (x * x * x))
                    - (5.8733867 * (x * x))
                    + (3.75112997 * x)
                    - 0.37001483
    in
    chromaticity { x = x, y = y }


{-| Extract the chromaticity of a given color. Note that this is a lossy
conversion since it throws away any lightness/brightness information. For
example, any greyscale color value will have chromaticity equal to
`Light.daylight` (since that is the standard 'white' chromaticity for the
sRGB color space).
-}
color : Color -> Chromaticity
color givenColor =
    let
        (Types.CieXyz bigX bigY bigZ _) =
            ColorConversions.colorToCieXyz givenColor

        sum =
            bigX + bigY + bigZ
    in
    chromaticity { x = bigX / sum, y = bigY / sum }
