module TestApp exposing (main)

import Angle exposing (Angle)
import Array exposing (Array)
import Array.Extra as Array
import Axis3d exposing (Axis3d)
import Block3d exposing (Block3d)
import Browser
import Browser.Events
import Browser.Navigation as Navigation
import Camera3d exposing (Camera3d)
import Color exposing (Color)
import Cone3d exposing (Cone3d)
import Cylinder3d exposing (Cylinder3d)
import Dict
import Direction3d exposing (Direction3d)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Events
import Element.Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes
import Http
import Illuminance
import Json.Decode as Decode
import Length exposing (Meters)
import LineSegment3d exposing (LineSegment3d)
import Luminance
import LuminousFlux
import Maybe.Extra as Maybe
import Pixels
import Plane3d exposing (Plane3d)
import Point3d exposing (Point3d)
import Polyline3d exposing (Polyline3d)
import Quantity exposing (Quantity, Unitless)
import Quantity.Interval as Interval exposing (Interval)
import Result.Extra
import Scene3d exposing (Entity)
import Scene3d.Light as Light exposing (Light)
import Scene3d.Material as Material exposing (Material)
import Scene3d.Mesh as Mesh exposing (Mesh)
import Set
import Sphere3d exposing (Sphere3d)
import Task
import Temperature
import Triangle3d exposing (Triangle3d)
import TriangularMesh exposing (TriangularMesh)
import Url exposing (Url)
import Url.Parser
import Url.Parser.Query
import Vector3d exposing (Vector3d)
import Viewpoint3d exposing (Viewpoint3d)
import WebGL.Texture


type Mesh
    = Points
    | LineSegments
    | Polyline
    | Triangles
    | Facets
    | Plain
    | Uniform
    | Unlit
    | Textured
    | TexturedFacets
    | Quad
    | Block
    | Sphere
    | Cylinder
    | Cone
    | Facet
    | LineSegment
    | Point


type Material
    = Color
    | Emissive
    | Matte
    | Pbr
    | TexturedColor
    | TexturedEmissive
    | TexturedMatte
    | TexturedPbr


type Transparency
    = Transparent
    | Opaque


type Transformation
    = NoTransformation
    | Translation
    | Rotation
    | Scale
    | Mirror


type ToneMapping
    = NoToneMapping
    | Reinhard
    | ReinhardPerChannel
    | HableFilmic


type Antialiasing
    = NoAntialiasing
    | Multisampling
    | Supersampling


type Projection
    = Perspective
    | Orthographic


type alias TestCase =
    { mesh : Mesh
    , material : Material
    , transparency : Transparency
    , shadows : Bool
    , transformation : Transformation
    , pointLight : Bool
    , directionalLight : Bool
    , softLighting : Bool
    , toneMapping : ToneMapping
    , antialiasing : Antialiasing
    , projection : Projection
    }


toggleMesh : Mesh -> Mesh
toggleMesh mesh =
    case mesh of
        Points ->
            LineSegments

        LineSegments ->
            Polyline

        Polyline ->
            Triangles

        Triangles ->
            Facets

        Facets ->
            Plain

        Plain ->
            Uniform

        Uniform ->
            Unlit

        Unlit ->
            Textured

        Textured ->
            TexturedFacets

        TexturedFacets ->
            Quad

        Quad ->
            Block

        Block ->
            Sphere

        Sphere ->
            Cylinder

        Cylinder ->
            Cone

        Cone ->
            Facet

        Facet ->
            LineSegment

        LineSegment ->
            Point

        Point ->
            Points


toggleTransformation : Transformation -> Transformation
toggleTransformation currentTransformation =
    case currentTransformation of
        NoTransformation ->
            Translation

        Translation ->
            Rotation

        Rotation ->
            Scale

        Scale ->
            Mirror

        Mirror ->
            NoTransformation


toggleProjection : Projection -> Projection
toggleProjection currentProjection =
    case currentProjection of
        Perspective ->
            Orthographic

        Orthographic ->
            Perspective


toggleAntialiasing : Antialiasing -> Antialiasing
toggleAntialiasing currentAntialiasing =
    case currentAntialiasing of
        NoAntialiasing ->
            Multisampling

        Multisampling ->
            Supersampling

        Supersampling ->
            NoAntialiasing


toggleToneMapping : ToneMapping -> ToneMapping
toggleToneMapping currentToneMapping =
    case currentToneMapping of
        NoToneMapping ->
            Reinhard

        Reinhard ->
            ReinhardPerChannel

        ReinhardPerChannel ->
            HableFilmic

        HableFilmic ->
            NoToneMapping


parseMesh : String -> Result String Mesh
parseMesh string =
    case string of
        "Points" ->
            Ok Points

        "LineSegments" ->
            Ok LineSegments

        "Polyline" ->
            Ok Polyline

        "Triangles" ->
            Ok Triangles

        "Facets" ->
            Ok Facets

        "Plain" ->
            Ok Plain

        "Uniform" ->
            Ok Uniform

        "Unlit" ->
            Ok Unlit

        "Textured" ->
            Ok Textured

        "TexturedFacets" ->
            Ok TexturedFacets

        "Quad" ->
            Ok Quad

        "Block" ->
            Ok Block

        "Sphere" ->
            Ok Sphere

        "Cylinder" ->
            Ok Cylinder

        "Cone" ->
            Ok Cone

        "Facet" ->
            Ok Facet

        "LineSegment" ->
            Ok LineSegment

        "Point" ->
            Ok Point

        _ ->
            Err ("Unrecognized mesh type '" ++ string ++ "'")


parseMaterial : String -> Result String Material
parseMaterial string =
    case string of
        "Color" ->
            Ok Color

        "Emissive" ->
            Ok Emissive

        "Matte" ->
            Ok Matte

        "Pbr" ->
            Ok Pbr

        "TexturedColor" ->
            Ok TexturedColor

        "TexturedEmissive" ->
            Ok TexturedEmissive

        "TexturedMatte" ->
            Ok TexturedMatte

        "TexturedPbr" ->
            Ok TexturedPbr

        _ ->
            Err ("Unrecognized material type '" ++ string ++ "'")


parseTransparency : String -> Result String Transparency
parseTransparency string =
    case string of
        "Transparent" ->
            Ok Transparent

        "Opaque" ->
            Ok Opaque

        _ ->
            Err ("Unrecognized transparency type '" ++ string ++ "'")


parseShadows : String -> Result String Bool
parseShadows string =
    case string of
        "NoShadows" ->
            Ok False

        "Shadows" ->
            Ok True

        _ ->
            Err ("Unrecognized shadows setting '" ++ string ++ "'")


parseTransformation : String -> Result String Transformation
parseTransformation string =
    case string of
        "NoTransformation" ->
            Ok NoTransformation

        "Translation" ->
            Ok Translation

        "Rotation" ->
            Ok Rotation

        "Scale" ->
            Ok Scale

        "Mirror" ->
            Ok Mirror

        _ ->
            Err ("Unrecognized transformation type '" ++ string ++ "'")


parsePointLight : String -> Result String Bool
parsePointLight string =
    case string of
        "PointLight" ->
            Ok True

        "NoPointLight" ->
            Ok False

        _ ->
            Err ("Unrecognized point light type '" ++ string ++ "'")


parseDirectionalLight : String -> Result String Bool
parseDirectionalLight string =
    case string of
        "DirectionalLight" ->
            Ok True

        "NoDirectionalLight" ->
            Ok False

        _ ->
            Err ("Unrecognized directional light type '" ++ string ++ "'")


parseSoftLighting : String -> Result String Bool
parseSoftLighting string =
    case string of
        "SoftLighting" ->
            Ok True

        "NoSoftLighting" ->
            Ok False

        _ ->
            Err ("Unrecognized soft lighting type '" ++ string ++ "'")


parseToneMapping : String -> Result String ToneMapping
parseToneMapping string =
    case string of
        "NoToneMapping" ->
            Ok NoToneMapping

        "Reinhard" ->
            Ok Reinhard

        "ReinhardPerChannel" ->
            Ok ReinhardPerChannel

        "HableFilmic" ->
            Ok HableFilmic

        _ ->
            Err ("Unrecognized tone mapping type '" ++ string ++ "'")


parseAntialiasing : String -> Result String Antialiasing
parseAntialiasing string =
    case string of
        "NoAntialiasing" ->
            Ok NoAntialiasing

        "Multisampling" ->
            Ok Multisampling

        "Supersampling" ->
            Ok Supersampling

        _ ->
            Err ("Unrecognized antialiasing type '" ++ string ++ "'")


parseProjection : String -> Result String Projection
parseProjection string =
    case string of
        "Perspective" ->
            Ok Perspective

        "Orthographic" ->
            Ok Orthographic

        _ ->
            Err ("Unrecognized projection type '" ++ string ++ "'")


parseTestCase : String -> Result String TestCase
parseTestCase line =
    let
        items =
            String.split "\t" line
    in
    case items of
        [ meshString, materialString, transparencyString, shadowString, transformationString, pointLightString, directionalLightString, softLightingString, toneMappingString, antialiasingString, projectionString ] ->
            Ok TestCase
                |> Result.Extra.andMap (parseMesh meshString)
                |> Result.Extra.andMap (parseMaterial materialString)
                |> Result.Extra.andMap (parseTransparency transparencyString)
                |> Result.Extra.andMap (parseShadows shadowString)
                |> Result.Extra.andMap (parseTransformation transformationString)
                |> Result.Extra.andMap (parsePointLight pointLightString)
                |> Result.Extra.andMap (parseDirectionalLight directionalLightString)
                |> Result.Extra.andMap (parseSoftLighting softLightingString)
                |> Result.Extra.andMap (parseToneMapping toneMappingString)
                |> Result.Extra.andMap (parseAntialiasing antialiasingString)
                |> Result.Extra.andMap (parseProjection projectionString)

        _ ->
            Err ("Expected 11 items in line, got '" ++ line ++ "' with " ++ String.fromInt (List.length items))


parseTestCases : String -> Result String (List TestCase)
parseTestCases fileContents =
    String.lines fileContents
        |> List.drop 1
        |> List.filter (not << String.isEmpty)
        |> List.map parseTestCase
        |> Result.Extra.combine


type WorldCoordinates
    = WorldCoordinates


type alias Scene =
    { testCase : TestCase
    , entity : Entity WorldCoordinates
    }


addShadowIf : Bool -> Mesh.Shadow WorldCoordinates -> Entity WorldCoordinates -> Entity WorldCoordinates
addShadowIf shadowSetting shadowMesh givenEntity =
    if shadowSetting then
        Scene3d.group [ givenEntity, Scene3d.meshShadow shadowMesh ]

    else
        givenEntity


polyline : Polyline3d Meters WorldCoordinates
polyline =
    Polyline3d.fromVertices
        [ Point3d.meters -1 -1 0.5
        , Point3d.meters 0 -1 0.5
        , Point3d.meters 0 0 0.5
        , Point3d.meters 0 1 0.5
        , Point3d.meters 1 1 0.5
        ]


pointsMesh : Mesh.Plain WorldCoordinates
pointsMesh =
    Mesh.points { radius = Pixels.pixels 10 } (Polyline3d.vertices polyline)


pointsShadow : Mesh.Shadow WorldCoordinates
pointsShadow =
    Mesh.shadow pointsMesh


pointsEntity : { a | shadows : Bool } -> Material.Plain WorldCoordinates -> Entity WorldCoordinates
pointsEntity { shadows } material =
    Scene3d.mesh material pointsMesh |> addShadowIf shadows pointsShadow


lineSegmentsMesh : Mesh.Plain WorldCoordinates
lineSegmentsMesh =
    Mesh.lineSegments (Polyline3d.segments polyline)


lineSegmentsShadow : Mesh.Shadow WorldCoordinates
lineSegmentsShadow =
    Mesh.shadow lineSegmentsMesh


lineSegmentsEntity : { a | shadows : Bool } -> Material.Plain WorldCoordinates -> Entity WorldCoordinates
lineSegmentsEntity { shadows } material =
    Scene3d.mesh material lineSegmentsMesh |> addShadowIf shadows lineSegmentsShadow


polylineMesh : Mesh.Plain WorldCoordinates
polylineMesh =
    Mesh.polyline polyline


polylineShadow : Mesh.Shadow WorldCoordinates
polylineShadow =
    Mesh.shadow polylineMesh


polylineEntity : { a | shadows : Bool } -> Material.Plain WorldCoordinates -> Entity WorldCoordinates
polylineEntity { shadows } material =
    Scene3d.mesh material polylineMesh |> addShadowIf shadows polylineShadow


type alias Vertex =
    { position : Point3d Meters WorldCoordinates
    , normal : Vector3d Unitless WorldCoordinates
    , uv : ( Float, Float )
    }


duckTransform : Entity WorldCoordinates -> Entity WorldCoordinates
duckTransform =
    Scene3d.scaleAbout Point3d.origin 1.75
        >> Scene3d.rotateAround Axis3d.x (Angle.degrees 90)


plainEntity :
    { a | shadows : Bool }
    -> Material.Plain WorldCoordinates
    -> Mesh.Plain WorldCoordinates
    -> Mesh.Shadow WorldCoordinates
    -> Entity WorldCoordinates
plainEntity { shadows } material plainMesh plainShadow =
    Scene3d.mesh material plainMesh
        |> addShadowIf shadows plainShadow
        |> duckTransform


uniformEntity :
    { a | shadows : Bool }
    -> Material.Uniform WorldCoordinates
    -> Mesh.Uniform WorldCoordinates
    -> Mesh.Shadow WorldCoordinates
    -> Entity WorldCoordinates
uniformEntity { shadows } material uniformMesh uniformShadow =
    Scene3d.mesh material uniformMesh
        |> addShadowIf shadows uniformShadow
        |> duckTransform


unlitEntity : { a | shadows : Bool } -> Material.Unlit WorldCoordinates -> Mesh.Unlit WorldCoordinates -> Mesh.Shadow WorldCoordinates -> Entity WorldCoordinates
unlitEntity { shadows } material unlitMesh unlitShadow =
    Scene3d.mesh material unlitMesh
        |> addShadowIf shadows unlitShadow
        |> duckTransform


texturedEntity : { a | shadows : Bool } -> Material.Textured WorldCoordinates -> Mesh.Textured WorldCoordinates -> Mesh.Shadow WorldCoordinates -> Entity WorldCoordinates
texturedEntity { shadows } material texturedMesh texturedShadow =
    Scene3d.mesh material texturedMesh
        |> addShadowIf shadows texturedShadow
        |> duckTransform


quadEntity : { a | shadows : Bool } -> Material.Textured WorldCoordinates -> Entity WorldCoordinates
quadEntity { shadows } material =
    let
        p1 =
            Point3d.meters 1 -1 0.5

        p2 =
            Point3d.meters 1 1 0.5

        p3 =
            Point3d.meters -1 1 0.5

        p4 =
            Point3d.meters -1 -1 0.5
    in
    if shadows then
        Scene3d.quadWithShadow material p1 p2 p3 p4

    else
        Scene3d.quad material p1 p2 p3 p4


blockEntity : { a | shadows : Bool } -> Material.Uniform WorldCoordinates -> Entity WorldCoordinates
blockEntity { shadows } material =
    let
        drawBlock =
            if shadows then
                Scene3d.blockWithShadow

            else
                Scene3d.block
    in
    drawBlock material <|
        Block3d.from
            (Point3d.meters -1 -0.75 0.25)
            (Point3d.meters 1 0.75 1.25)


sphereEntity : { a | shadows : Bool } -> Material.Textured WorldCoordinates -> Entity WorldCoordinates
sphereEntity { shadows } material =
    let
        drawSphere =
            if shadows then
                Scene3d.sphereWithShadow

            else
                Scene3d.sphere
    in
    drawSphere material <|
        Sphere3d.withRadius (Length.meters 1) (Point3d.meters 0 0 1)


cylinderEntity : { a | shadows : Bool } -> Material.Uniform WorldCoordinates -> Entity WorldCoordinates
cylinderEntity { shadows } material =
    let
        drawCylinder =
            if shadows then
                Scene3d.cylinderWithShadow

            else
                Scene3d.cylinder
    in
    drawCylinder material <|
        Cylinder3d.along Axis3d.z
            { start = Length.meters 0.5
            , end = Length.meters 1.5
            , radius = Length.meters 1
            }


coneEntity : { a | shadows : Bool } -> Material.Uniform WorldCoordinates -> Entity WorldCoordinates
coneEntity { shadows } material =
    let
        drawCone =
            if shadows then
                Scene3d.coneWithShadow

            else
                Scene3d.cone
    in
    drawCone material <|
        Cone3d.along Axis3d.z
            { base = Length.meters 0.5
            , tip = Length.meters 2.5
            , radius = Length.meters 1
            }


facetEntity : { a | shadows : Bool } -> Material.Uniform WorldCoordinates -> Entity WorldCoordinates
facetEntity { shadows } material =
    let
        drawFacet =
            if shadows then
                Scene3d.facetWithShadow

            else
                Scene3d.facet
    in
    drawFacet material <|
        Triangle3d.from
            (Point3d.meters -0.5 -1 0.5)
            (Point3d.meters 2 0 0.5)
            (Point3d.meters -0.5 1 0.5)


lineSegmentEntity : Material.Plain WorldCoordinates -> Entity WorldCoordinates
lineSegmentEntity givenMaterial =
    Scene3d.lineSegment givenMaterial <|
        LineSegment3d.from (Point3d.meters 0 0 1) (Point3d.meters 2 0 1)


pointEntity : Material.Plain WorldCoordinates -> Entity WorldCoordinates
pointEntity givenMaterial =
    Scene3d.point { radius = Pixels.pixels 10 } givenMaterial (Point3d.meters 1 0 1)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlChangeRequested
        , subscriptions = subscriptions
        }


type alias LoadingModel =
    { testCases : Maybe (List TestCase)
    , testCaseIndex : Int
    , initialUrl : Url
    , colorTexture : Maybe (Material.Texture Color)
    , roughnessTexture : Maybe (Material.Texture Float)
    , metallicTexture : Maybe (Material.Texture Float)
    , duckMesh : Maybe (TriangularMesh Vertex)
    , duckTexture : Maybe (Material.Texture Color)
    , navigationKey : Navigation.Key
    }


type alias LoadedModel =
    { testCases : Array TestCase
    , testCaseIndex : Int
    , initialUrl : Url
    , navigationKey : Navigation.Key
    , colorTexture : Material.Texture Color
    , roughnessTexture : Material.Texture Float
    , metallicTexture : Material.Texture Float
    , duckTexture : Material.Texture Color
    , trianglesMesh : Mesh.Plain WorldCoordinates
    , facetsMesh : Mesh.Uniform WorldCoordinates
    , plainMesh : Mesh.Plain WorldCoordinates
    , uniformMesh : Mesh.Uniform WorldCoordinates
    , unlitMesh : Mesh.Unlit WorldCoordinates
    , texturedMesh : Mesh.Textured WorldCoordinates
    , texturedFacetsMesh : Mesh.Textured WorldCoordinates
    , shadow : Mesh.Shadow WorldCoordinates
    }


type Model
    = Loading LoadingModel
    | Loaded LoadedModel
    | Error String


getTestCaseIndex : Url -> Int
getTestCaseIndex url =
    case Url.Parser.parse (Url.Parser.query (Url.Parser.Query.int "test_case")) { url | path = "" } of
        Nothing ->
            0

        Just Nothing ->
            0

        Just (Just index) ->
            index - 1


init : flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags initialUrl navigationKey =
    ( Loading
        { testCases = Nothing
        , testCaseIndex = getTestCaseIndex initialUrl
        , initialUrl = initialUrl
        , colorTexture = Nothing
        , roughnessTexture = Nothing
        , metallicTexture = Nothing
        , duckMesh = Nothing
        , duckTexture = Nothing
        , navigationKey = navigationKey
        }
    , Cmd.batch
        [ Http.get
            { url = "portability-testing/test_cases_2.txt"
            , expect = Http.expectString TestCasesResponse
            }
        , Material.load "https://ianmackenzie.github.io/elm-3d-scene/examples/metal/Metal03_col.jpg"
            |> Task.attempt ColorTextureResponse
        , Material.load "https://ianmackenzie.github.io/elm-3d-scene/examples/metal/Metal03_rgh.jpg"
            |> Task.attempt RoughnessTextureResponse
        , Material.load "https://ianmackenzie.github.io/elm-3d-scene/examples/metal/Metal03_met.jpg"
            |> Task.attempt MetallicTextureResponse
        , Material.loadWith
            { minify = WebGL.Texture.linearMipmapLinear
            , magnify = WebGL.Texture.linear
            , horizontalWrap = WebGL.Texture.repeat
            , verticalWrap = WebGL.Texture.repeat
            , flipY = True
            }
            "https://ianmackenzie.github.io/elm-3d-scene/examples/duckling.png"
            |> Task.attempt DuckTextureResponse
        , Http.get
            { url = "https://ianmackenzie.github.io/elm-3d-scene/examples/duckling-medpoly.obj"
            , expect = Http.expectString DuckMeshResponse
            }
        ]
    )


type alias Assets =
    { testCases : String
    , colorTexture : Material.Texture Color
    }


type Msg
    = TestCasesResponse (Result Http.Error String)
    | ColorTextureResponse (Result WebGL.Texture.Error (Material.Texture Color))
    | RoughnessTextureResponse (Result WebGL.Texture.Error (Material.Texture Float))
    | MetallicTextureResponse (Result WebGL.Texture.Error (Material.Texture Float))
    | DuckMeshResponse (Result Http.Error String)
    | DuckTextureResponse (Result WebGL.Texture.Error (Material.Texture Color))
    | UrlChanged Url
    | UrlChangeRequested Browser.UrlRequest
    | Next
    | Previous
    | First
    | Last
    | ToggleShadow
    | ToggleTransformation
    | TogglePointLight
    | ToggleDirectionalLight
    | ToggleSoftLighting
    | ToggleProjection
    | ToggleAntialiasing
    | ToggleToneMapping


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        updateCurrentTestCase function =
            ( case model of
                Loaded loadedModel ->
                    Loaded
                        { loadedModel
                            | testCases =
                                loadedModel.testCases
                                    |> Array.update loadedModel.testCaseIndex function
                        }

                _ ->
                    model
            , Cmd.none
            )

        switchTo newIndex loadedModel =
            let
                initialUrl =
                    loadedModel.initialUrl
            in
            ( Loaded { loadedModel | testCaseIndex = newIndex }
            , Navigation.pushUrl loadedModel.navigationKey <|
                Url.toString <|
                    { initialUrl | query = Just ("test_case=" ++ String.fromInt (newIndex + 1)) }
            )
    in
    case msg of
        TestCasesResponse (Ok fileContents) ->
            case model of
                Loading loadingModel ->
                    case parseTestCases fileContents of
                        Ok testCases ->
                            ( checkIfLoaded { loadingModel | testCases = Just testCases }
                            , Cmd.none
                            )

                        Err message ->
                            ( Error message, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        TestCasesResponse (Err _) ->
            ( Error "Error loading test cases", Cmd.none )

        ColorTextureResponse (Ok colorTexture) ->
            case model of
                Loading loadingModel ->
                    ( checkIfLoaded { loadingModel | colorTexture = Just colorTexture }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ColorTextureResponse (Err _) ->
            ( Error "Error loading color texture", Cmd.none )

        RoughnessTextureResponse (Ok roughnessTexture) ->
            case model of
                Loading loadingModel ->
                    ( checkIfLoaded { loadingModel | roughnessTexture = Just roughnessTexture }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        RoughnessTextureResponse (Err _) ->
            ( Error "Error loading roughness texture", Cmd.none )

        MetallicTextureResponse (Ok metallicTexture) ->
            case model of
                Loading loadingModel ->
                    ( checkIfLoaded { loadingModel | metallicTexture = Just metallicTexture }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        MetallicTextureResponse (Err _) ->
            ( Error "Error loading metallic texture", Cmd.none )

        DuckMeshResponse (Ok fileContents) ->
            case model of
                Loading loadingModel ->
                    ( checkIfLoaded { loadingModel | duckMesh = Just (trace "Parsing OBJ" (\() -> parseObj fileContents)) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        DuckMeshResponse (Err _) ->
            ( Error "Error loading duck mesh", Cmd.none )

        DuckTextureResponse (Ok duckTexture) ->
            case model of
                Loading loadingModel ->
                    ( checkIfLoaded { loadingModel | duckTexture = Just duckTexture }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        DuckTextureResponse (Err _) ->
            ( Error "Error loading duck texture", Cmd.none )

        Previous ->
            case model of
                Loaded loadedModel ->
                    switchTo
                        (max 0 (loadedModel.testCaseIndex - 1))
                        loadedModel

                _ ->
                    ( model, Cmd.none )

        Next ->
            case model of
                Loaded loadedModel ->
                    switchTo
                        (min (loadedModel.testCaseIndex + 1) (Array.length loadedModel.testCases - 1))
                        loadedModel

                _ ->
                    ( model, Cmd.none )

        First ->
            case model of
                Loaded loadedModel ->
                    switchTo 0 loadedModel

                _ ->
                    ( model, Cmd.none )

        Last ->
            case model of
                Loaded loadedModel ->
                    switchTo (Array.length loadedModel.testCases - 1) loadedModel

                _ ->
                    ( model, Cmd.none )

        UrlChangeRequested request ->
            case model of
                Loaded loadedModel ->
                    case request of
                        Browser.Internal url ->
                            ( model, Navigation.pushUrl loadedModel.navigationKey (Url.toString url) )

                        Browser.External url ->
                            ( model, Navigation.load url )

                _ ->
                    ( model, Cmd.none )

        UrlChanged newUrl ->
            case model of
                Loaded loadedModel ->
                    ( Loaded { loadedModel | testCaseIndex = getTestCaseIndex newUrl }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ToggleShadow ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | shadows = not testCase.shadows
                    }
                )

        ToggleTransformation ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | transformation = toggleTransformation testCase.transformation
                    }
                )

        TogglePointLight ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | pointLight = not testCase.pointLight
                    }
                )

        ToggleDirectionalLight ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | directionalLight = not testCase.directionalLight
                    }
                )

        ToggleSoftLighting ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | softLighting = not testCase.softLighting
                    }
                )

        ToggleProjection ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | projection = toggleProjection testCase.projection
                    }
                )

        ToggleAntialiasing ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | antialiasing = toggleAntialiasing testCase.antialiasing
                    }
                )

        ToggleToneMapping ->
            updateCurrentTestCase
                (\testCase ->
                    { testCase
                        | toneMapping = toggleToneMapping testCase.toneMapping
                    }
                )


trace : String -> (() -> a) -> a
trace description callback =
    let
        _ =
            Debug.log "Starting" description
    in
    let
        result =
            callback ()
    in
    let
        _ =
            Debug.log "Finished" description
    in
    result


parseObj : String -> TriangularMesh Vertex
parseObj fileContents =
    let
        lines =
            String.lines fileContents

        positionLines =
            lines |> List.filter (String.startsWith "v ")

        uvLines =
            lines |> List.filter (String.startsWith "vt ")

        normalLines =
            lines |> List.filter (String.startsWith "vn ")

        faceLines =
            lines |> List.filter (String.startsWith "f ")

        positions =
            Array.fromList (List.filterMap parsePosition positionLines)

        uvs =
            Array.fromList (List.filterMap parseUv uvLines)

        normals =
            Array.fromList (List.filterMap parseNormal normalLines)

        faceVertexIndices =
            List.concatMap parseFace faceLines

        uniqueVertices =
            faceVertexIndices
                |> List.concatMap (\( v1, v2, v3 ) -> [ v1, v2, v3 ])
                |> Set.fromList
                |> Set.toList
                |> List.filterMap
                    (\(( positionIndex, uvIndex, normalIndex ) as vertexIndices) ->
                        Maybe.map3
                            (\position uv normal ->
                                ( vertexIndices
                                , { position = position, uv = uv, normal = normal }
                                )
                            )
                            (Array.get positionIndex positions)
                            (Array.get uvIndex uvs)
                            (Array.get normalIndex normals)
                    )

        vertexArray =
            uniqueVertices |> List.map Tuple.second |> Array.fromList

        vertexIndexDict =
            uniqueVertices
                |> List.indexedMap (\index ( vertexIndices, _ ) -> ( vertexIndices, index ))
                |> Dict.fromList

        faceIndices =
            faceVertexIndices
                |> List.filterMap
                    (\( v1, v2, v3 ) ->
                        Maybe.map3
                            (\i j k -> ( i, j, k ))
                            (Dict.get v1 vertexIndexDict)
                            (Dict.get v2 vertexIndexDict)
                            (Dict.get v3 vertexIndexDict)
                    )
    in
    TriangularMesh.indexed vertexArray faceIndices


parsePosition : String -> Maybe (Point3d Meters WorldCoordinates)
parsePosition line =
    let
        coordinates =
            line
                |> String.dropLeft 2
                |> String.words
                |> List.filterMap String.toFloat
    in
    case coordinates of
        [ x, y, z ] ->
            Just (Point3d.meters x y z)

        _ ->
            Nothing


parseNormal : String -> Maybe (Vector3d Unitless WorldCoordinates)
parseNormal line =
    let
        coordinates =
            line
                |> String.dropLeft 3
                |> String.words
                |> List.filterMap String.toFloat
    in
    case coordinates of
        [ x, y, z ] ->
            Just (Vector3d.unitless x y z)

        _ ->
            Nothing


parseUv : String -> Maybe ( Float, Float )
parseUv line =
    let
        coordinates =
            line
                |> String.dropLeft 3
                |> String.words
                |> List.filterMap String.toFloat
    in
    case coordinates of
        u :: v :: rest ->
            Just ( u, v )

        _ ->
            Nothing


parseFace : String -> List ( ( Int, Int, Int ), ( Int, Int, Int ), ( Int, Int, Int ) )
parseFace line =
    let
        vertices =
            line
                |> String.dropLeft 2
                |> String.words
                |> List.filterMap parseFaceVertex
    in
    case vertices of
        [ v1, v2, v3 ] ->
            [ ( v1, v2, v3 ) ]

        [ v1, v2, v3, v4 ] ->
            [ ( v1, v2, v3 ), ( v1, v3, v4 ) ]

        _ ->
            []


parseFaceVertex : String -> Maybe ( Int, Int, Int )
parseFaceVertex string =
    case String.split "/" string |> List.filterMap String.toInt of
        [ positionIndex, uvIndex, normalIndex ] ->
            Just ( positionIndex - 1, uvIndex - 1, normalIndex - 1 )

        _ ->
            Nothing


testCaseArray : List TestCase -> Array TestCase
testCaseArray testCases =
    let
        filteredTestCases =
            testCases
                |> List.filter
                    (\testCase ->
                        List.all (List.any ((==) True))
                            []
                    )

        ( firstGroup, secondGroup ) =
            List.partition (.antialiasing >> (==) Multisampling)
                filteredTestCases
    in
    Array.fromList (firstGroup ++ secondGroup)


checkIfLoaded : LoadingModel -> Model
checkIfLoaded loadingModel =
    Just
        (\testCases colorTexture roughnessTexture metallicTexture duckMesh duckTexture ->
            let
                plainTriangularMesh =
                    TriangularMesh.mapVertices .position duckMesh

                triangles =
                    List.map Triangle3d.fromVertices
                        (TriangularMesh.faceVertices plainTriangularMesh)

                trianglesMesh =
                    Mesh.triangles triangles

                facetsMesh =
                    Mesh.facets triangles

                plainMesh =
                    Mesh.indexedTriangles plainTriangularMesh

                uniformMesh =
                    Mesh.indexedFaces
                        (TriangularMesh.mapVertices
                            (\{ position, normal } -> { position = position, normal = normal })
                            duckMesh
                        )

                unlitMesh =
                    Mesh.texturedTriangles
                        (TriangularMesh.mapVertices
                            (\{ position, uv } -> { position = position, uv = uv })
                            duckMesh
                        )

                texturedMesh =
                    Mesh.texturedFaces duckMesh

                texturedFacetsMesh =
                    Mesh.texturedFacets
                        (TriangularMesh.mapVertices
                            (\{ position, uv } -> { position = position, uv = uv })
                            duckMesh
                        )
            in
            { testCases = testCaseArray testCases
            , testCaseIndex = loadingModel.testCaseIndex
            , navigationKey = loadingModel.navigationKey
            , initialUrl = loadingModel.initialUrl
            , colorTexture = colorTexture
            , roughnessTexture = roughnessTexture
            , metallicTexture = metallicTexture
            , duckTexture = duckTexture
            , trianglesMesh = trianglesMesh
            , facetsMesh = facetsMesh
            , plainMesh = plainMesh
            , uniformMesh = uniformMesh
            , unlitMesh = unlitMesh
            , texturedMesh = texturedMesh
            , texturedFacetsMesh = texturedFacetsMesh
            , shadow = Mesh.shadow trianglesMesh
            }
        )
        |> Maybe.andMap loadingModel.testCases
        |> Maybe.andMap loadingModel.colorTexture
        |> Maybe.andMap loadingModel.roughnessTexture
        |> Maybe.andMap loadingModel.metallicTexture
        |> Maybe.andMap loadingModel.duckMesh
        |> Maybe.andMap loadingModel.duckTexture
        |> Maybe.map Loaded
        |> Maybe.withDefault (Loading loadingModel)


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onKeyDown
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    case key of
                        "ArrowLeft" ->
                            Decode.succeed Previous

                        "ArrowRight" ->
                            Decode.succeed Next

                        "ArrowUp" ->
                            Decode.succeed Previous

                        "ArrowDown" ->
                            Decode.succeed Next

                        "Home" ->
                            Decode.succeed First

                        "End" ->
                            Decode.succeed Last

                        _ ->
                            Decode.fail "Unrecognized key"
                )
        )


view : Model -> Browser.Document Msg
view model =
    { title = "elm-3d-scene portability testing"
    , body =
        [ case model of
            Loading _ ->
                Html.text "Loading..."

            Loaded loadedModel ->
                case Array.get loadedModel.testCaseIndex loadedModel.testCases of
                    Just currentTestCase ->
                        Element.layout [] <|
                            Element.column []
                                [ viewTestCase loadedModel currentTestCase
                                ]

                    Nothing ->
                        Html.text ""

            Error message ->
                Html.text message
        ]
    }


entity : LoadedModel -> TestCase -> Maybe (Entity WorldCoordinates)
entity model testCase =
    let
        withTransparency : Color -> Color
        withTransparency baseColor =
            let
                { red, green, blue } =
                    Color.toRgba baseColor
            in
            Color.fromRgba
                { red = red
                , green = green
                , blue = blue
                , alpha =
                    case testCase.transparency of
                        Transparent ->
                            0.5

                        Opaque ->
                            1.0
                }
    in
    case testCase.material of
        Color ->
            let
                material =
                    Material.color (withTransparency Color.blue)
            in
            case testCase.mesh of
                Points ->
                    Just (pointsEntity testCase material)

                LineSegments ->
                    Just (lineSegmentsEntity testCase material)

                Polyline ->
                    Just (polylineEntity testCase material)

                Triangles ->
                    Just (plainEntity testCase material model.trianglesMesh model.shadow)

                Facets ->
                    Just (uniformEntity testCase material model.facetsMesh model.shadow)

                Plain ->
                    Just (plainEntity testCase material model.plainMesh model.shadow)

                Uniform ->
                    Just (uniformEntity testCase material model.uniformMesh model.shadow)

                Unlit ->
                    Just (unlitEntity testCase material model.unlitMesh model.shadow)

                Textured ->
                    Just (texturedEntity testCase material model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase material model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase material)

                Block ->
                    Just (blockEntity testCase material)

                Sphere ->
                    Just (sphereEntity testCase material)

                Cylinder ->
                    Just (cylinderEntity testCase material)

                Cone ->
                    Just (coneEntity testCase material)

                Facet ->
                    Just (facetEntity testCase material)

                LineSegment ->
                    Just (lineSegmentEntity material)

                Point ->
                    Just (pointEntity material)

        Emissive ->
            let
                material =
                    Material.emissive (Light.color Color.orange) (Luminance.nits 250)
            in
            case testCase.mesh of
                Points ->
                    Just (pointsEntity testCase material)

                LineSegments ->
                    Just (lineSegmentsEntity testCase material)

                Polyline ->
                    Just (polylineEntity testCase material)

                Triangles ->
                    Just (plainEntity testCase material model.trianglesMesh model.shadow)

                Facets ->
                    Just (uniformEntity testCase material model.facetsMesh model.shadow)

                Plain ->
                    Just (plainEntity testCase material model.plainMesh model.shadow)

                Uniform ->
                    Just (uniformEntity testCase material model.uniformMesh model.shadow)

                Unlit ->
                    Just (unlitEntity testCase material model.unlitMesh model.shadow)

                Textured ->
                    Just (texturedEntity testCase material model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase material model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase material)

                Block ->
                    Just (blockEntity testCase material)

                Sphere ->
                    Just (sphereEntity testCase material)

                Cylinder ->
                    Just (cylinderEntity testCase material)

                Cone ->
                    Just (coneEntity testCase material)

                Facet ->
                    Just (facetEntity testCase material)

                LineSegment ->
                    Just (lineSegmentEntity material)

                Point ->
                    Just (pointEntity material)

        Matte ->
            let
                material =
                    Material.matte (withTransparency Color.blue)
            in
            case testCase.mesh of
                Points ->
                    Nothing

                LineSegments ->
                    Nothing

                Polyline ->
                    Nothing

                Triangles ->
                    Nothing

                Facets ->
                    Just (uniformEntity testCase material model.facetsMesh model.shadow)

                Plain ->
                    Nothing

                Uniform ->
                    Just (uniformEntity testCase material model.uniformMesh model.shadow)

                Unlit ->
                    Nothing

                Textured ->
                    Just (texturedEntity testCase material model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase material model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase material)

                Block ->
                    Just (blockEntity testCase material)

                Sphere ->
                    Just (sphereEntity testCase material)

                Cylinder ->
                    Just (cylinderEntity testCase material)

                Cone ->
                    Just (coneEntity testCase material)

                Facet ->
                    Just (facetEntity testCase material)

                LineSegment ->
                    Nothing

                Point ->
                    Nothing

        Pbr ->
            let
                material =
                    Material.nonmetal
                        { baseColor = withTransparency Color.blue
                        , roughness = 0.25
                        }
            in
            case testCase.mesh of
                Points ->
                    Nothing

                LineSegments ->
                    Nothing

                Polyline ->
                    Nothing

                Triangles ->
                    Nothing

                Facets ->
                    Just (uniformEntity testCase material model.facetsMesh model.shadow)

                Plain ->
                    Nothing

                Uniform ->
                    Just (uniformEntity testCase material model.uniformMesh model.shadow)

                Unlit ->
                    Nothing

                Textured ->
                    Just (texturedEntity testCase material model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase material model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase material)

                Block ->
                    Just (blockEntity testCase material)

                Sphere ->
                    Just (sphereEntity testCase material)

                Cylinder ->
                    Just (cylinderEntity testCase material)

                Cone ->
                    Just (coneEntity testCase material)

                Facet ->
                    Just (facetEntity testCase material)

                LineSegment ->
                    Nothing

                Point ->
                    Nothing

        TexturedColor ->
            let
                metalMaterial =
                    Material.texturedColor model.colorTexture

                duckMaterial =
                    Material.texturedColor model.duckTexture
            in
            case testCase.mesh of
                Points ->
                    Nothing

                LineSegments ->
                    Nothing

                Polyline ->
                    Nothing

                Triangles ->
                    Nothing

                Facets ->
                    Nothing

                Plain ->
                    Nothing

                Uniform ->
                    Nothing

                Unlit ->
                    Just (unlitEntity testCase duckMaterial model.unlitMesh model.shadow)

                Textured ->
                    Just (texturedEntity testCase duckMaterial model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase duckMaterial model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase metalMaterial)

                Block ->
                    Nothing

                Sphere ->
                    Just (sphereEntity testCase metalMaterial)

                Cylinder ->
                    Nothing

                Cone ->
                    Nothing

                Facet ->
                    Nothing

                LineSegment ->
                    Nothing

                Point ->
                    Nothing

        TexturedEmissive ->
            let
                metalMaterial =
                    Material.texturedEmissive model.colorTexture (Luminance.nits 10)

                duckMaterial =
                    Material.texturedEmissive model.duckTexture (Luminance.nits 10)
            in
            case testCase.mesh of
                Points ->
                    Nothing

                LineSegments ->
                    Nothing

                Polyline ->
                    Nothing

                Triangles ->
                    Nothing

                Facets ->
                    Nothing

                Plain ->
                    Nothing

                Uniform ->
                    Nothing

                Unlit ->
                    Just (unlitEntity testCase duckMaterial model.unlitMesh model.shadow)

                Textured ->
                    Just (texturedEntity testCase duckMaterial model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase duckMaterial model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase metalMaterial)

                Block ->
                    Nothing

                Sphere ->
                    Just (sphereEntity testCase metalMaterial)

                Cylinder ->
                    Nothing

                Cone ->
                    Nothing

                Facet ->
                    Nothing

                LineSegment ->
                    Nothing

                Point ->
                    Nothing

        TexturedMatte ->
            let
                metalMaterial =
                    Material.texturedMatte model.colorTexture

                duckMaterial =
                    Material.texturedMatte model.duckTexture
            in
            case testCase.mesh of
                Points ->
                    Nothing

                LineSegments ->
                    Nothing

                Polyline ->
                    Nothing

                Triangles ->
                    Nothing

                Facets ->
                    Nothing

                Plain ->
                    Nothing

                Uniform ->
                    Nothing

                Unlit ->
                    Nothing

                Textured ->
                    Just (texturedEntity testCase duckMaterial model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase duckMaterial model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase metalMaterial)

                Block ->
                    Nothing

                Sphere ->
                    Just (sphereEntity testCase metalMaterial)

                Cylinder ->
                    Nothing

                Cone ->
                    Nothing

                Facet ->
                    Nothing

                LineSegment ->
                    Nothing

                Point ->
                    Nothing

        TexturedPbr ->
            let
                metalMaterial =
                    Material.texturedPbr
                        { baseColor = model.colorTexture
                        , roughness = model.roughnessTexture
                        , metallic = model.metallicTexture
                        }

                duckMaterial =
                    Material.texturedPbr
                        { baseColor = model.duckTexture
                        , roughness = Material.constant 0.25
                        , metallic = Material.constant 0
                        }
            in
            case testCase.mesh of
                Points ->
                    Nothing

                LineSegments ->
                    Nothing

                Polyline ->
                    Nothing

                Triangles ->
                    Nothing

                Facets ->
                    Nothing

                Plain ->
                    Nothing

                Uniform ->
                    Nothing

                Unlit ->
                    Nothing

                Textured ->
                    Just (texturedEntity testCase duckMaterial model.texturedMesh model.shadow)

                TexturedFacets ->
                    Just (texturedEntity testCase duckMaterial model.texturedFacetsMesh model.shadow)

                Quad ->
                    Just (quadEntity testCase metalMaterial)

                Block ->
                    Nothing

                Sphere ->
                    Just (sphereEntity testCase metalMaterial)

                Cylinder ->
                    Nothing

                Cone ->
                    Nothing

                Facet ->
                    Nothing

                LineSegment ->
                    Nothing

                Point ->
                    Nothing


transformation : TestCase -> Entity WorldCoordinates -> Entity WorldCoordinates
transformation testCase =
    case testCase.transformation of
        NoTransformation ->
            identity

        Translation ->
            Scene3d.translateIn Direction3d.x (Length.meters 1)

        Rotation ->
            Scene3d.rotateAround Axis3d.z (Angle.degrees 135)

        Scale ->
            Scene3d.scaleAbout Point3d.origin (2 / 3)

        Mirror ->
            Scene3d.mirrorAcross Plane3d.zx


lights : TestCase -> Scene3d.Lights WorldCoordinates
lights testCase =
    let
        pointLight =
            Light.point (Light.castsShadows testCase.shadows)
                { chromaticity = Light.daylight
                , position = Point3d.meters -3 4 4
                , intensity = LuminousFlux.lumens 20000
                }

        directionalLight =
            Light.directional (Light.castsShadows testCase.shadows)
                { chromaticity = Light.daylight
                , intensity = Illuminance.lux 60
                , direction = Direction3d.xyZ (Angle.degrees 45) (Angle.degrees -25)
                }

        softLighting =
            Light.soft
                { upDirection = Direction3d.z
                , chromaticity = Light.daylight
                , intensityAbove = Illuminance.lux 30
                , intensityBelow = Illuminance.lux 6
                }
    in
    case ( testCase.pointLight, testCase.directionalLight, testCase.softLighting ) of
        ( False, False, False ) ->
            Scene3d.noLights

        ( True, False, False ) ->
            Scene3d.oneLight pointLight

        ( False, True, False ) ->
            Scene3d.oneLight directionalLight

        ( True, True, False ) ->
            Scene3d.twoLights pointLight directionalLight

        ( False, False, True ) ->
            Scene3d.oneLight softLighting

        ( True, False, True ) ->
            Scene3d.twoLights pointLight softLighting

        ( False, True, True ) ->
            Scene3d.twoLights directionalLight softLighting

        ( True, True, True ) ->
            Scene3d.threeLights pointLight directionalLight softLighting


camera : TestCase -> Camera3d Meters WorldCoordinates
camera testCase =
    let
        focalPoint =
            Point3d.meters 0 0 0.5

        eyePoint =
            Point3d.meters 8 4 6

        verticalFieldOfView =
            Angle.degrees 30

        focalDistance =
            Point3d.distanceFrom eyePoint focalPoint

        viewportHeight =
            focalDistance
                |> Quantity.multiplyBy
                    (2 * Angle.tan (Quantity.half verticalFieldOfView))

        viewpoint =
            Viewpoint3d.lookAt
                { focalPoint = focalPoint
                , eyePoint = eyePoint
                , upDirection = Direction3d.z
                }
    in
    case testCase.projection of
        Perspective ->
            Camera3d.perspective
                { viewpoint = viewpoint
                , verticalFieldOfView = verticalFieldOfView
                }

        Orthographic ->
            Camera3d.orthographic
                { viewpoint = viewpoint
                , viewportHeight = viewportHeight
                }


antialiasing : TestCase -> Scene3d.Antialiasing
antialiasing testCase =
    case testCase.antialiasing of
        NoAntialiasing ->
            Scene3d.noAntialiasing

        Multisampling ->
            Scene3d.multisampling

        Supersampling ->
            Scene3d.supersampling 2


toneMapping : TestCase -> Scene3d.ToneMapping
toneMapping testCase =
    case testCase.toneMapping of
        NoToneMapping ->
            Scene3d.noToneMapping

        Reinhard ->
            Scene3d.reinhardToneMapping 5

        ReinhardPerChannel ->
            Scene3d.reinhardPerChannelToneMapping 5

        HableFilmic ->
            Scene3d.hableFilmicToneMapping


button : { onPress : Maybe Msg, label : Element Msg } -> Element Msg
button properties =
    Input.button
        [ Element.Border.rounded 3
        , Element.Border.solid
        , Element.Border.width 1
        , Element.Border.color (Element.rgb 0.25 0.25 0.25)
        ]
        properties


meshDescription : Mesh -> String
meshDescription mesh =
    case mesh of
        Points ->
            "Points"

        LineSegments ->
            "Line segments"

        Polyline ->
            "Polyline"

        Triangles ->
            "Triangles"

        Facets ->
            "Facets"

        Plain ->
            "Plain"

        Uniform ->
            "Uniform"

        Unlit ->
            "Unlit"

        Textured ->
            "Textured"

        TexturedFacets ->
            "Textured facets"

        Quad ->
            "Quad"

        Block ->
            "Block"

        Sphere ->
            "Sphere"

        Cylinder ->
            "Cylinder"

        Cone ->
            "Cone"

        Facet ->
            "Facet"

        LineSegment ->
            "Line segment"

        Point ->
            "Point"


transparencyDescription : Transparency -> String
transparencyDescription transparency =
    case transparency of
        Transparent ->
            "Transparent"

        Opaque ->
            "Opaque"


materialDescription : Material -> String
materialDescription material =
    case material of
        Color ->
            "Color"

        Emissive ->
            "Emissive"

        Matte ->
            "Matte"

        Pbr ->
            "PBR"

        TexturedColor ->
            "Textured color"

        TexturedEmissive ->
            "Textured emissive"

        TexturedMatte ->
            "Textured matte"

        TexturedPbr ->
            "Textured PBR"


shadowsDescription : Bool -> String
shadowsDescription shadows =
    if shadows then
        "Shadows"

    else
        "No shadows"


transformationDescription : Transformation -> String
transformationDescription givenTransformation =
    case givenTransformation of
        NoTransformation ->
            "No transformation"

        Translation ->
            "Translation"

        Rotation ->
            "Rotation"

        Scale ->
            "Scale"

        Mirror ->
            "Mirror"


pointLightDescription : Bool -> String
pointLightDescription pointLight =
    if pointLight then
        "Point light"

    else
        "No point light"


directionalLightDescription : Bool -> String
directionalLightDescription directionalLight =
    if directionalLight then
        "Directional light"

    else
        "No directional light"


softLightingDescription : Bool -> String
softLightingDescription softLighting =
    if softLighting then
        "Soft lighting"

    else
        "No soft lighting"


toneMappingDescription : ToneMapping -> String
toneMappingDescription givenToneMapping =
    case givenToneMapping of
        NoToneMapping ->
            "No tone mapping"

        Reinhard ->
            "Reinhard"

        ReinhardPerChannel ->
            "Reinhard per channel"

        HableFilmic ->
            "Hable filmic"


antialiasingDescription : Antialiasing -> String
antialiasingDescription givenAntialiasing =
    case givenAntialiasing of
        NoAntialiasing ->
            "No antialiasing"

        Multisampling ->
            "Multisampling"

        Supersampling ->
            "Supersampling"


projectionDescription : Projection -> String
projectionDescription projection =
    case projection of
        Perspective ->
            "Perspective"

        Orthographic ->
            "Orthographic"


viewTestCaseProperties : Int -> Int -> TestCase -> Element Msg
viewTestCaseProperties testCaseIndex numTestCases testCase =
    Element.table [ Element.Font.size 14, Element.spacingXY 10 3 ]
        { data =
            [ ( "Test case:", String.fromInt (testCaseIndex + 1) ++ " of " ++ String.fromInt numTestCases, Nothing )
            , ( "Mesh:", meshDescription testCase.mesh, Nothing )
            , ( "Material:", materialDescription testCase.material, Nothing )
            , ( "Transparency:", transparencyDescription testCase.transparency, Nothing )
            , ( "Shadows:", shadowsDescription testCase.shadows, Just ToggleShadow )
            , ( "Transformation:", transformationDescription testCase.transformation, Just ToggleTransformation )
            , ( "Point light:", pointLightDescription testCase.pointLight, Just TogglePointLight )
            , ( "Directional light:", directionalLightDescription testCase.directionalLight, Just ToggleDirectionalLight )
            , ( "Soft lighting:", softLightingDescription testCase.softLighting, Just ToggleSoftLighting )
            , ( "Tone mapping:", toneMappingDescription testCase.toneMapping, Just ToggleToneMapping )
            , ( "Antialiasing:", antialiasingDescription testCase.antialiasing, Just ToggleAntialiasing )
            , ( "Projection:", projectionDescription testCase.projection, Just ToggleProjection )
            ]
        , columns =
            [ { header = Element.none, width = Element.shrink, view = \( property, _, _ ) -> Element.text property }
            , { header = Element.none
              , width = Element.shrink
              , view =
                    \( _, value, maybeMessage ) ->
                        case maybeMessage of
                            Nothing ->
                                Element.text value

                            Just message ->
                                button
                                    { onPress = Just message
                                    , label = Element.text value
                                    }
              }
            ]
        }


axes : Entity WorldCoordinates
axes =
    let
        xAxisMesh =
            Mesh.lineSegments
                [ LineSegment3d.from
                    (Point3d.meters 0 0 0.01)
                    (Point3d.meters 3 0 0.01)
                ]

        yAxisMesh =
            Mesh.lineSegments
                [ LineSegment3d.from
                    (Point3d.meters 0 0 0.01)
                    (Point3d.meters 0 3 0.01)
                ]

        zAxisMesh =
            Mesh.lineSegments
                [ LineSegment3d.from
                    (Point3d.meters 0 0 0.01)
                    (Point3d.meters 0 0 3.01)
                ]
    in
    Scene3d.group
        [ Scene3d.mesh (Material.color Color.lightRed) xAxisMesh
        , Scene3d.mesh (Material.color Color.lightGreen) yAxisMesh
        , Scene3d.mesh (Material.color Color.lightBlue) zAxisMesh
        ]


floor : Entity WorldCoordinates
floor =
    Scene3d.quad (Material.matte Color.darkGray)
        (Point3d.meters 2.25 -2.25 0)
        (Point3d.meters 2.25 2.25 0)
        (Point3d.meters -2.25 2.25 0)
        (Point3d.meters -2.25 -2.25 0)


viewTestCase : LoadedModel -> TestCase -> Element Msg
viewTestCase model testCase =
    case entity model testCase of
        Just validEntity ->
            Element.column [ Element.spacing 10 ]
                [ Element.el [ Element.Events.onClick Next ] <|
                    Element.html <|
                        Scene3d.custom
                            { lights = lights testCase
                            , background = Scene3d.transparentBackground
                            , camera = camera testCase
                            , clipDepth = Length.meters 1
                            , dimensions = ( Pixels.pixels 400, Pixels.pixels 300 )
                            , antialiasing = antialiasing testCase
                            , exposure = Scene3d.exposureValue 4
                            , toneMapping = toneMapping testCase
                            , whiteBalance = Light.daylight
                            , entities = [ floor, validEntity |> transformation testCase ]
                            }

                -- , Element.image
                --     [ Element.width (Element.px 480)
                --     , Element.height (Element.px 360)
                --     , Element.Events.onClick Next
                --     ]
                --     { src = "https://ianmackenzie.github.io/elm-3d-scene/images/1.0.0/test-v2/test" ++ String.fromInt (model.testCaseIndex + 1) ++ ".png"
                --     , description = "Reference render"
                --     }
                , Element.column []
                    [ Element.row [] <|
                        [ button
                            { onPress = Just Previous
                            , label = Element.text "Prev"
                            }
                        , button
                            { onPress = Just Next
                            , label = Element.text "Next"
                            }
                        ]
                    , Element.el [ Element.Font.size 14 ] (Element.text "(or use arrow keys, or click on either image)")
                    ]
                , viewTestCaseProperties model.testCaseIndex (Array.length model.testCases) testCase
                ]

        Nothing ->
            Element.text "ERROR: Invalid test case"
