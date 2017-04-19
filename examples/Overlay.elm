module OrthographicLogo exposing (..)

import OpenSolid.SceneGraph as SceneGraph
import OpenSolid.Geometry.Types exposing (..)
import OpenSolid.Direction3d as Direction3d
import OpenSolid.Direction2d as Direction2d
import OpenSolid.Frame3d as Frame3d
import OpenSolid.Plane3d as Plane3d
import OpenSolid.LineSegment3d as LineSegment3d
import OpenSolid.WebGL.Frame3d as Frame3d
import OpenSolid.WebGL.Projection as Projection
import OpenSolid.WebGL.Point3d as Point3d
import OpenSolid.WebGL.LineSegment3d as LineSegment3d
import OpenSolid.Svg as Svg
import Svg exposing (Svg)
import Svg.Attributes
import WebGL
import OpenSolid.Axis3d as Axis3d
import OpenSolid.Point3d as Point3d
import Html exposing (Html)
import Html.Attributes as Attributes
import Kintail.InputWidget as InputWidget
import Logo


view : Float -> Html Float
view angleInDegrees =
    let
        width =
            800

        height =
            600

        eyePoint =
            Point3d ( 5, 0, 0 )
                |> Point3d.rotateAround Axis3d.y (degrees -22.5)
                |> Point3d.rotateAround Axis3d.z (degrees 60)

        eyeFrame =
            Frame3d.lookAt
                { focalPoint = Point3d.origin
                , eyePoint = eyePoint
                , upDirection = Direction3d.z
                }

        projection =
            Projection.perspective
                { eyeFrame = eyeFrame
                , screenWidth = toFloat width
                , screenHeight = toFloat height
                , verticalFov = degrees 30
                , zNear = 0.1
                , zFar = 100
                }

        angle =
            degrees angleInDegrees

        rotatedLogo =
            Logo.node |> SceneGraph.rotateAround Axis3d.z angle

        svgCircles =
            Logo.vertices
                |> List.map (Point3d.rotateAround Axis3d.z angle)
                |> List.map (Point3d.toScreenSpace projection)
                |> List.map
                    (\point ->
                        Svg.circle2d
                            [ Svg.Attributes.stroke "grey"
                            , Svg.Attributes.fill "none"
                            ]
                            (Circle2d { centerPoint = point, radius = 5 })
                    )

        svgLines =
            Logo.edges
                |> List.map (LineSegment3d.rotateAround Axis3d.z angle)
                |> List.map (LineSegment3d.toScreenSpace projection)
                |> List.map (Svg.lineSegment2d [ Svg.Attributes.stroke "grey", Svg.Attributes.strokeDasharray "3 3" ])

        topLeftFrame =
            Frame2d
                { originPoint = Point2d ( 0, height )
                , xDirection = Direction2d.x
                , yDirection = Direction2d.flip Direction2d.y
                }

        svgElement =
            Svg.svg
                [ Attributes.width width
                , Attributes.height height
                , Attributes.style
                    [ ( "position", "absolute" )
                    , ( "z-index", "1" )
                    ]
                ]
                [ Svg.relativeTo topLeftFrame (Svg.g [] (svgCircles ++ svgLines)) ]

        entities =
            SceneGraph.toEntities projection rotatedLogo

        attributes =
            [ Attributes.width width
            , Attributes.height height
            , Attributes.style
                [ ( "position", "absolute" )
                , ( "z-index", "1" )
                ]
            ]

        sliderAttributes =
            [ Attributes.style [ ( "width", toString width ++ "px" ) ] ]

        sliderConfig =
            { min = 0
            , max = 360
            , step = 1
            }
    in
        Html.div []
            [ Html.div
                [ Attributes.style
                    [ ( "position", "relative" )
                    , ( "width", toString width ++ "px" )
                    , ( "height", toString height ++ "px" )
                    ]
                ]
                [ WebGL.toHtml attributes entities
                , svgElement
                ]
            , InputWidget.slider sliderAttributes sliderConfig angleInDegrees
            ]


main : Program Never Float Float
main =
    Html.beginnerProgram
        { model = 0.0
        , view = view
        , update = always
        }