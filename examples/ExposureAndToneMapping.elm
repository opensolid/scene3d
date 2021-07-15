module ExposureAndToneMapping exposing (main)

{-| This example lets you play around with different exposure values and tone
mapping methods, to see the relationships between them.
-}

import Angle exposing (Angle)
import Array
import Block3d
import Browser
import Browser.Events
import Camera3d exposing (Camera3d)
import Color
import Direction3d exposing (Direction3d)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Illuminance
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Meters)
import LuminousFlux
import Pixels exposing (Pixels)
import Point3d
import Quantity exposing (Quantity)
import Scene3d
import Scene3d.Light as Light exposing (Light)
import Scene3d.Material as Material exposing (Material)
import Sphere3d
import Viewpoint3d


type WorldCoordinates
    = WorldCoordinates



----- MATERIALS -----


gold : Material.Uniform WorldCoordinates
gold =
    Material.metal
        { baseColor = Color.rgba (255 / 255) (195 / 255) (86 / 255) 0.5
        , roughness = 0.4
        }


aluminum : Material.Uniform WorldCoordinates
aluminum =
    Material.metal
        { baseColor = Color.rgb255 233 235 236
        , roughness = 0.6
        }


blackPlastic : Material.Uniform WorldCoordinates
blackPlastic =
    Material.nonmetal
        { baseColor = Color.rgb255 0 0 0
        , roughness = 0.5
        }


whitePlastic : Material.Uniform WorldCoordinates
whitePlastic =
    Material.nonmetal
        { baseColor = Color.rgb255 255 255 255
        , roughness = 0.25
        }



----- ENTITIES -----


goldSphere : Scene3d.Entity WorldCoordinates
goldSphere =
    -- Note that since we gave the 'gold' material a concrete type, we need to
    -- use 'Material.uniform' here to apply that material to a sphere (which
    -- accepts textured materials); we're effectively saying "yes, I know this
    -- mesh supports textured materials but I actually do want to apply this
    -- uniform, non-textured material to it"
    Scene3d.sphereWithShadow (Material.uniform gold) <|
        Sphere3d.withRadius (Length.centimeters 10) (Point3d.centimeters 20 20 0)


aluminumSphere : Scene3d.Entity WorldCoordinates
aluminumSphere =
    Scene3d.sphereWithShadow (Material.uniform aluminum) <|
        Sphere3d.withRadius (Length.centimeters 10) (Point3d.centimeters 20 -20 0)


blackPlasticSphere : Scene3d.Entity WorldCoordinates
blackPlasticSphere =
    Scene3d.sphereWithShadow (Material.uniform blackPlastic) <|
        Sphere3d.withRadius (Length.centimeters 10) (Point3d.centimeters -20 -20 0)


whitePlasticSphere : Scene3d.Entity WorldCoordinates
whitePlasticSphere =
    Scene3d.sphereWithShadow (Material.uniform whitePlastic) <|
        Sphere3d.withRadius (Length.centimeters 10) (Point3d.centimeters -20 20 0)


quad : Scene3d.Entity WorldCoordinates
quad =
    -- Create an angled quad shape
    Scene3d.quadWithShadow (Material.uniform aluminum)
        (Point3d.centimeters 10 10 -5)
        (Point3d.centimeters -10 10 0)
        (Point3d.centimeters -10 -10 5)
        (Point3d.centimeters 10 -10 0)


floor : Scene3d.Entity WorldCoordinates
floor =
    -- Create a thin block to act as a 'floor' that shadows will be cast on;
    -- no need to use Material.uniform here since blocks _only_ support uniform
    -- materials
    Scene3d.block aluminum <|
        Block3d.from
            (Point3d.centimeters -35 -35 -22)
            (Point3d.centimeters 35 35 -20)



----- RENDERING -----


camera : Model -> Camera3d Meters WorldCoordinates
camera model =
    -- Create a perspective camera based on the current azimuth/elevation from
    -- the model
    Camera3d.perspective
        { viewpoint =
            Viewpoint3d.orbitZ
                { focalPoint = Point3d.centimeters 0 0 -20
                , azimuth = model.azimuth
                , elevation = model.elevation
                , distance = Length.meters 2
                }
        , verticalFieldOfView = Angle.degrees 30
        }


lightBulb : Light WorldCoordinates Bool
lightBulb =
    -- Define a light bulb similar to a 30 watt incandescent light bulb
    Light.point (Light.castsShadows True)
        { chromaticity = Light.incandescent
        , intensity = LuminousFlux.lumens 300
        , position = Point3d.centimeters 0 0 30
        }


overheadLighting : Light WorldCoordinates Never
overheadLighting =
    -- Add some soft overhead lighting
    Light.overhead
        { upDirection = Direction3d.positiveZ
        , chromaticity = Light.fluorescent
        , intensity = Illuminance.lux 100
        }


{-| Define a custom type that we will use to let the tone mapping type be chosen
dynamically
-}
type ToneMapping
    = NoToneMapping
    | Reinhard
    | ReinhardPerChannel
    | HableFilmic


{-| Keep track of the currently-chosen tone mapping type and exposure value,
as well as the orbiting state (see the OrbitingCamera example for details)
-}
type alias Model =
    { exposureValue : Float
    , toneMapping : ToneMapping
    , azimuth : Angle
    , elevation : Angle
    , orbiting : Bool
    }


type Msg
    = SetExposureValue Float
    | SetToneMapping ToneMapping
    | MouseDown
    | MouseUp
    | MouseMove (Quantity Float Pixels) (Quantity Float Pixels)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SetExposureValue value ->
            ( { model | exposureValue = value }, Cmd.none )

        SetToneMapping value ->
            ( { model | toneMapping = value }, Cmd.none )

        MouseDown ->
            ( { model | orbiting = True }, Cmd.none )

        MouseUp ->
            ( { model | orbiting = False }, Cmd.none )

        MouseMove dx dy ->
            -- Handle orbiting just like in the OrbitingCamera example
            if model.orbiting then
                let
                    rotationRate =
                        Angle.degrees 0.25 |> Quantity.per Pixels.pixel

                    rotation numPixels =
                        numPixels |> Quantity.at rotationRate

                    newAzimuth =
                        model.azimuth |> Quantity.minus (rotation dx)

                    newElevation =
                        model.elevation
                            |> Quantity.plus (rotation dy)
                            |> Quantity.clamp (Angle.degrees -90) (Angle.degrees 90)
                in
                ( { model | azimuth = newAzimuth, elevation = newElevation }
                , Cmd.none
                )

            else
                ( model, Cmd.none )


toneMappingDescription : ToneMapping -> String
toneMappingDescription toneMapping =
    case toneMapping of
        NoToneMapping ->
            "No tone mapping"

        Reinhard ->
            "Reinhard"

        ReinhardPerChannel ->
            "Reinhard per channel"

        HableFilmic ->
            "Hable filmic"


toneMappingOptions : List ToneMapping
toneMappingOptions =
    [ NoToneMapping
    , Reinhard
    , ReinhardPerChannel
    , HableFilmic
    ]


init : () -> ( Model, Cmd Msg )
init () =
    ( { exposureValue = 6
      , toneMapping = NoToneMapping
      , azimuth = Angle.degrees 45
      , elevation = Angle.degrees 40
      , orbiting = False
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    let
        -- 'Tone mapping' refers to various methods used to map high dynamic
        -- range colors (colors with a wider range of brightnesses than could
        -- be displayed on a standard monitor) into a narrower range of colors
        -- that *can* be displayed, without making most colors very dark;
        -- different kinds of tone mapping apply different kinds of color
        -- transformations
        toneMapping =
            case model.toneMapping of
                NoToneMapping ->
                    Scene3d.noToneMapping

                Reinhard ->
                    Scene3d.reinhardToneMapping 5

                ReinhardPerChannel ->
                    Scene3d.reinhardPerChannelToneMapping 5

                HableFilmic ->
                    Scene3d.hableFilmicToneMapping
    in
    Html.div []
        -- Start orbiting when the mouse is pressed on the scene
        [ Html.div [ Html.Events.onMouseDown MouseDown ]
            [ Scene3d.custom
                { lights = Scene3d.twoLights lightBulb overheadLighting
                , camera = camera model
                , clipDepth = Length.meters 0.1
                , dimensions = ( Pixels.int 640, Pixels.int 480 )
                , antialiasing = Scene3d.multisampling
                , exposure = Scene3d.exposureValue model.exposureValue
                , toneMapping = toneMapping
                , whiteBalance = Light.fluorescent
                , background = Scene3d.transparentBackground
                , entities =
                    [ goldSphere
                    , aluminumSphere
                    , blackPlasticSphere
                    , whitePlasticSphere
                    , quad
                    , floor
                    ]
                }
            ]

        -- Allow exposure value and tone mapping type to be adjusted at runtime; try
        -- playing around with different combinations of values! See below for
        -- 'slider' and 'comboBox' implementations if you're curious
        , Html.div []
            [ Html.text "Exposure value:"
            , slider [] { min = 3, max = 9 } model.exposureValue
                |> Html.map SetExposureValue
            ]
        , Html.div []
            [ Html.text "Tone mapping:"
            , comboBox [] toneMappingDescription toneMappingOptions model.toneMapping
                |> Html.map SetToneMapping
            ]
        ]


{-| Decode mouse movement just like in OrbitingCamera example
-}
decodeMouseMove : Decoder Msg
decodeMouseMove =
    Decode.map2 MouseMove
        (Decode.field "movementX" (Decode.map Pixels.float Decode.float))
        (Decode.field "movementY" (Decode.map Pixels.float Decode.float))


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.orbiting then
        Sub.batch
            [ Browser.Events.onMouseMove decodeMouseMove
            , Browser.Events.onMouseUp (Decode.succeed MouseUp)
            ]

    else
        -- Unlike OrbitingCamera example, don't listen for mouse-down events
        -- anywhere since then things like dragging the slider will also cause
        -- orbiting (a mouse down handler is added to the scene itself instead)
        Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



----- HTML UTILITIES (not specific to elm-3d-scene) -----


slider :
    List (Html.Attribute Float)
    -> { min : Float, max : Float }
    -> Float
    -> Html Float
slider attributes { min, max } =
    let
        targetValueDecoder currentValue =
            Decode.map (String.toFloat >> Maybe.withDefault currentValue)
                Html.Events.targetValue

        newValueDecoder currentValue =
            targetValueDecoder currentValue
                |> Decode.andThen
                    (\newValue ->
                        if newValue /= currentValue then
                            Decode.succeed newValue

                        else
                            Decode.fail "value did not change"
                    )

        commonAttributes =
            Html.Attributes.property "min" (Encode.float min)
                :: Html.Attributes.property "max" (Encode.float max)
                :: Html.Attributes.property "step" (Encode.string "any")
                :: attributes
    in
    \currentValue ->
        Html.input
            (Html.Attributes.type_ "range"
                :: Html.Attributes.property "value" (Encode.float currentValue)
                :: Html.Events.on "input" (newValueDecoder currentValue)
                :: Html.Events.on "change" (newValueDecoder currentValue)
                :: commonAttributes
            )
            []


comboBox : List (Html.Attribute a) -> (a -> String) -> List a -> a -> Html a
comboBox attributes toStr allItems =
    let
        itemsArray =
            Array.fromList allItems

        selectedIndexDecoder =
            Decode.at [ "target", "selectedIndex" ] Decode.int

        newSelectionDecoder currentItem =
            selectedIndexDecoder
                |> Decode.andThen
                    (\selectedIndex ->
                        case Array.get selectedIndex itemsArray of
                            Just newItem ->
                                if newItem /= currentItem then
                                    Decode.succeed newItem

                                else
                                    Decode.fail "selected item did not change"

                            Nothing ->
                                Decode.fail "selected index out of range"
                    )
    in
    \currentItem ->
        let
            decoder =
                newSelectionDecoder currentItem

            onChange =
                Html.Events.on "change" decoder

            onKeyUp =
                Html.Events.on "keyup" decoder

            toOption item =
                Html.option [ Html.Attributes.selected (item == currentItem) ]
                    [ Html.text (toStr item) ]
        in
        Html.select (onChange :: onKeyUp :: attributes)
            (List.map toOption allItems)
