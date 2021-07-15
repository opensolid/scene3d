module Scene3d.ColorConversions exposing
    ( linearRgbToColor, colorToLinearRgb
    , cieXyzToColor, colorToCieXyz
    , cieXyzToLinearRgb, linearRgbToCieXyz
    , chromaticityToCieXyz, chromaticityToLinearRgb
    )

{-|

@docs linearRgbToColor, colorToLinearRgb

@docs cieXyzToColor, colorToCieXyz

@docs cieXyzToLinearRgb, linearRgbToCieXyz

@docs chromaticityToCieXyz, chromaticityToLinearRgb

-}

import Color exposing (Color)
import Math.Vector3 as Vector3 exposing (vec3)
import Math.Vector4 as Vector4 exposing (vec4)
import Quantity exposing (Quantity(..), Unitless)
import Scene3d.Types as Types exposing (Chromaticity(..), CieXyz(..), LinearRgb(..))


colorToLinearRgb : Color -> LinearRgb Unitless
colorToLinearRgb color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    LinearRgb <|
        vec4
            (inverseGamma red)
            (inverseGamma green)
            (inverseGamma blue)
            alpha


linearRgbToColor : LinearRgb Unitless -> Color
linearRgbToColor (LinearRgb linearRgb) =
    Color.rgba
        (gammaCorrect (Vector4.getX linearRgb))
        (gammaCorrect (Vector4.getY linearRgb))
        (gammaCorrect (Vector4.getZ linearRgb))
        (Vector4.getW linearRgb)


colorToCieXyz : Color -> CieXyz Unitless
colorToCieXyz color =
    color |> colorToLinearRgb |> linearRgbToCieXyz


cieXyzToColor : CieXyz Unitless -> Color
cieXyzToColor xyz =
    xyz |> cieXyzToLinearRgb |> linearRgbToColor


cieXyzToLinearRgb : CieXyz units -> LinearRgb units
cieXyzToLinearRgb (CieXyz bigX bigY bigZ a) =
    LinearRgb <|
        vec4
            (3.2406 * bigX - 1.5372 * bigY - 0.4986 * bigZ)
            (-0.9689 * bigX + 1.8758 * bigY + 0.0415 * bigZ)
            (0.0557 * bigX - 0.204 * bigY + 1.057 * bigZ)
            a


linearRgbToCieXyz : LinearRgb units -> CieXyz units
linearRgbToCieXyz (LinearRgb linearRgb) =
    let
        linearR =
            Vector4.getX linearRgb

        linearG =
            Vector4.getY linearRgb

        linearB =
            Vector4.getZ linearRgb
    in
    CieXyz
        (0.4124 * linearR + 0.3576 * linearG + 0.1805 * linearB)
        (0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB)
        (0.0193 * linearR + 0.1192 * linearG + 0.9505 * linearB)
        (Vector4.getW linearRgb)


gammaCorrect : Float -> Float
gammaCorrect u =
    clamp 0 1 <|
        if u <= 0.0031308 then
            12.92 * u

        else
            1.055 * (u ^ (1 / 2.4)) - 0.055


inverseGamma : Float -> Float
inverseGamma u =
    clamp 0 1 <|
        if u <= 0.04045 then
            u / 12.92

        else
            ((u + 0.055) / 1.055) ^ 2.4


chromaticityToCieXyz : Quantity Float units -> Chromaticity -> CieXyz units
chromaticityToCieXyz (Quantity intensity) (Types.Chromaticity { x, y }) =
    CieXyz (intensity * x / y) intensity (intensity * (1 - x - y) / y) 1


chromaticityToLinearRgb : Quantity Float units -> Chromaticity -> LinearRgb units
chromaticityToLinearRgb intensity chromaticity =
    cieXyzToLinearRgb (chromaticityToCieXyz intensity chromaticity)
