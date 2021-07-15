module Scene3d.Types exposing (..)

import BoundingBox3d exposing (BoundingBox3d)
import Camera3d exposing (Camera3d)
import Color exposing (Color)
import Frame3d exposing (Frame3d)
import Illuminance exposing (Lux)
import Length exposing (Meters)
import LineSegment3d exposing (LineSegment3d)
import Luminance exposing (Luminance)
import LuminousFlux exposing (Lumens)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import Math.Vector4 exposing (Vec4)
import Point3d exposing (Point3d)
import Polyline3d exposing (Polyline3d)
import Quantity exposing (Quantity, Unitless)
import Rectangle3d exposing (Rectangle3d)
import Triangle3d exposing (Triangle3d)
import TriangularMesh exposing (TriangularMesh)
import Vector3d exposing (Vector3d)
import WebGL
import WebGL.Settings
import WebGL.Texture


type alias Transformation =
    { ix : Float
    , iy : Float
    , iz : Float
    , jx : Float
    , jy : Float
    , jz : Float
    , kx : Float
    , ky : Float
    , kz : Float
    , px : Float
    , py : Float
    , pz : Float
    , scale : Float
    , isRightHanded : Bool
    }


type alias Bounds =
    { centerPoint : { x : Float, y : Float, z : Float }
    , halfX : Float
    , halfY : Float
    , halfZ : Float
    }


type alias PlainVertex =
    { position : Vec3
    }


type alias VertexWithNormal =
    { position : Vec3
    , normal : Vec3
    }


type alias VertexWithUv =
    { position : Vec3
    , uv : Vec2
    }


type alias VertexWithNormalAndUv =
    { position : Vec3
    , normal : Vec3
    , uv : Vec2
    }


type alias VertexWithTangent =
    { position : Vec3
    , normal : Vec3
    , uv : Vec2
    , tangent : Vec4
    }


type Material coordinates attributes
    = UnlitMaterial TextureMap (Texture Vec4)
    | EmissiveMaterial TextureMap (Texture (LinearRgb Unitless)) Luminance
    | LambertianMaterial TextureMap (Texture (LinearRgb Unitless)) (Texture Float) NormalMap
    | PbrMaterial TextureMap (Texture (LinearRgb Unitless)) (Texture Float) (Texture Float) (Texture Float) NormalMap


type NormalMap
    = NoNormalMap
    | NormalMap
        { url : String
        , options : WebGL.Texture.Options
        , data : WebGL.Texture.Texture
        , format : NormalMapFormat
        }


type NormalMapFormat
    = OpenglFormat
    | DirectxFormat


type Texture value
    = Constant value
    | Texture
        { url : String
        , options : WebGL.Texture.Options
        , data : WebGL.Texture.Texture
        -- TODO: transparency here
        }


type TextureMap
    = UseMeshUvs


type Channel
    = Channel Vec4


type BackFaceSetting
    = KeepBackFaces
    | CullBackFaces


type Mesh coordinates attributes
    = EmptyMesh
    | Triangles (BoundingBox3d Meters coordinates) (List (Triangle3d Meters coordinates)) (WebGL.Mesh PlainVertex) BackFaceSetting
    | Facets (BoundingBox3d Meters coordinates) (List (Triangle3d Meters coordinates)) (WebGL.Mesh VertexWithNormal) BackFaceSetting
    | Indexed (BoundingBox3d Meters coordinates) (TriangularMesh (Point3d Meters coordinates)) (WebGL.Mesh PlainVertex) BackFaceSetting
    | MeshWithNormals (BoundingBox3d Meters coordinates) (TriangularMesh { position : Point3d Meters coordinates, normal : Vector3d Unitless coordinates }) (WebGL.Mesh VertexWithNormal) BackFaceSetting
    | MeshWithUvs (BoundingBox3d Meters coordinates) (TriangularMesh { position : Point3d Meters coordinates, uv : ( Float, Float ) }) (WebGL.Mesh VertexWithUv) BackFaceSetting
    | MeshWithNormalsAndUvs (BoundingBox3d Meters coordinates) (TriangularMesh { position : Point3d Meters coordinates, normal : Vector3d Unitless coordinates, uv : ( Float, Float ) }) (WebGL.Mesh VertexWithNormalAndUv) BackFaceSetting
    | MeshWithTangents (BoundingBox3d Meters coordinates) (TriangularMesh { position : Point3d Meters coordinates, normal : Vector3d Unitless coordinates, uv : ( Float, Float ), tangent : Vector3d Unitless coordinates, tangentBasisIsRightHanded : Bool }) (WebGL.Mesh VertexWithTangent) BackFaceSetting
    | LineSegments (BoundingBox3d Meters coordinates) (List (LineSegment3d Meters coordinates)) (WebGL.Mesh PlainVertex)
    | Polyline (BoundingBox3d Meters coordinates) (Polyline3d Meters coordinates) (WebGL.Mesh PlainVertex)
    | Points (BoundingBox3d Meters coordinates) Float (List (Point3d Meters coordinates)) (WebGL.Mesh PlainVertex)


type Shadow coordinates
    = EmptyShadow
    | Shadow (BoundingBox3d Meters coordinates) (TriangularMesh VertexWithNormal) (WebGL.Mesh VertexWithNormal)


type alias LightMatrices =
    { lights12 : Mat4
    , lights34 : Mat4
    , lights56 : Mat4
    , lights78 : Mat4
    }


type alias DrawFunction lights =
    Mat4 -- scene properties
    -> Vec4 -- model scale
    -> Mat4 -- model matrix
    -> Bool -- model matrix is right-handed
    -> Mat4 -- view matrix
    -> Mat4 -- projection matrix
    -> lights -- lights
    -> List WebGL.Settings.Setting -- stencil, depth, blend etc.
    -> WebGL.Entity


type Node
    = EmptyNode
    | OpaqueMeshNode Bounds (DrawFunction ( LightMatrices, Vec4 ))
    | TransparentMeshNode Bounds (DrawFunction ( LightMatrices, Vec4 ))
    | ShadowNode (DrawFunction Mat4)
    | PointNode Bounds (DrawFunction ( LightMatrices, Vec4 ))
    | Group (List Node)
    | Transformed Transformation Node


type Entity coordinates
    = Entity Node


type Chromaticity
    = Chromaticity { x : Float, y : Float }


type CieXyz units
    = CieXyz Float Float Float Float


type LinearRgb units
    = LinearRgb Vec4


type Light coordinates castsShadows
    = Light
        { type_ : Float
        , castsShadows : Bool
        , parameter : Float
        , x : Float
        , y : Float
        , z : Float
        , r : Float
        , g : Float
        , b : Float
        }
