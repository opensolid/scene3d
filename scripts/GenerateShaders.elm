module GenerateShaders exposing (main)

import Glsl
import Regex
import Script exposing (Script, UserPrivileges)
import Script.Directory as Directory exposing (Directory)
import Script.File as File exposing (File, Writable)



---------- ATTRIBUTES ----------


position : Glsl.Attribute
position =
    Glsl.attribute Glsl.highp Glsl.vec3 "position"


normal : Glsl.Attribute
normal =
    Glsl.attribute Glsl.highp Glsl.vec3 "normal"


uv : Glsl.Attribute
uv =
    Glsl.attribute Glsl.mediump Glsl.vec2 "uv"


tangent : Glsl.Attribute
tangent =
    Glsl.attribute Glsl.highp Glsl.vec4 "tangent"


quadVertex : Glsl.Attribute
quadVertex =
    Glsl.attribute Glsl.highp Glsl.vec3 "quadVertex"


quadShadowVertex : Glsl.Attribute
quadShadowVertex =
    Glsl.attribute Glsl.highp Glsl.vec2 "quadShadowVertex"


triangleVertex : Glsl.Attribute
triangleVertex =
    Glsl.attribute Glsl.lowp Glsl.float "triangleVertex"


triangleShadowVertex : Glsl.Attribute
triangleShadowVertex =
    Glsl.attribute Glsl.highp Glsl.vec2 "triangleShadowVertex"


lineSegmentVertex : Glsl.Attribute
lineSegmentVertex =
    Glsl.attribute Glsl.lowp Glsl.float "lineSegmentVertex"


dummyAttribute : Glsl.Attribute
dummyAttribute =
    Glsl.attribute Glsl.lowp Glsl.float "dummyAttribute"


angle : Glsl.Attribute
angle =
    Glsl.attribute Glsl.highp Glsl.float "angle"


offsetScale : Glsl.Attribute
offsetScale =
    Glsl.attribute Glsl.highp Glsl.float "offsetScale"


radiusScale : Glsl.Attribute
radiusScale =
    Glsl.attribute Glsl.highp Glsl.float "radiusScale"



---------- UNIFORMS ----------


modelScale : Glsl.Uniform
modelScale =
    Glsl.uniform Glsl.highp Glsl.vec4 "modelScale"


modelMatrix : Glsl.Uniform
modelMatrix =
    Glsl.uniform Glsl.highp Glsl.mat4 "modelMatrix"


viewMatrix : Glsl.Uniform
viewMatrix =
    Glsl.uniform Glsl.highp Glsl.mat4 "viewMatrix"


projectionMatrix : Glsl.Uniform
projectionMatrix =
    Glsl.uniform Glsl.highp Glsl.mat4 "projectionMatrix"


sceneProperties : Glsl.Uniform
sceneProperties =
    Glsl.uniform Glsl.highp Glsl.mat4 "sceneProperties"


shadowLight : Glsl.Uniform
shadowLight =
    Glsl.uniform Glsl.highp Glsl.mat4 "shadowLight"


pointRadius : Glsl.Uniform
pointRadius =
    Glsl.uniform Glsl.lowp Glsl.float "pointRadius"


constantColor : Glsl.Uniform
constantColor =
    Glsl.uniform Glsl.lowp Glsl.vec4 "constantColor"


colorTexture : Glsl.Uniform
colorTexture =
    Glsl.uniform Glsl.mediump Glsl.sampler2D "colorTexture"


emissiveColor : Glsl.Uniform
emissiveColor =
    Glsl.uniform Glsl.mediump Glsl.vec4 "emissiveColor"


backlight : Glsl.Uniform
backlight =
    Glsl.uniform Glsl.mediump Glsl.float "backlight"


baseColor : Glsl.Uniform
baseColor =
    Glsl.uniform Glsl.lowp Glsl.vec4 "baseColor"


baseColorTexture : Glsl.Uniform
baseColorTexture =
    Glsl.uniform Glsl.mediump Glsl.sampler2D "baseColorTexture"


constantBaseColor : Glsl.Uniform
constantBaseColor =
    Glsl.uniform Glsl.lowp Glsl.vec4 "constantBaseColor"


roughness : Glsl.Uniform
roughness =
    Glsl.uniform Glsl.lowp Glsl.float "roughness"


roughnessTexture : Glsl.Uniform
roughnessTexture =
    Glsl.uniform Glsl.mediump Glsl.sampler2D "roughnessTexture"


constantRoughness : Glsl.Uniform
constantRoughness =
    Glsl.uniform Glsl.lowp Glsl.vec2 "constantRoughness"


metallic : Glsl.Uniform
metallic =
    Glsl.uniform Glsl.lowp Glsl.float "metallic"


metallicTexture : Glsl.Uniform
metallicTexture =
    Glsl.uniform Glsl.mediump Glsl.sampler2D "metallicTexture"


constantMetallic : Glsl.Uniform
constantMetallic =
    Glsl.uniform Glsl.lowp Glsl.vec2 "constantMetallic"


ambientOcclusion : Glsl.Uniform
ambientOcclusion =
    Glsl.uniform Glsl.lowp Glsl.float "ambientOcclusion"


ambientOcclusionTexture : Glsl.Uniform
ambientOcclusionTexture =
    Glsl.uniform Glsl.mediump Glsl.sampler2D "ambientOcclusionTexture"


constantAmbientOcclusion : Glsl.Uniform
constantAmbientOcclusion =
    Glsl.uniform Glsl.lowp Glsl.vec2 "constantAmbientOcclusion"


normalMapTexture : Glsl.Uniform
normalMapTexture =
    Glsl.uniform Glsl.mediump Glsl.sampler2D "normalMapTexture"


normalMapType : Glsl.Uniform
normalMapType =
    Glsl.uniform Glsl.lowp Glsl.float "normalMapType"


lights12 : Glsl.Uniform
lights12 =
    Glsl.uniform Glsl.highp Glsl.mat4 "lights12"


lights34 : Glsl.Uniform
lights34 =
    Glsl.uniform Glsl.highp Glsl.mat4 "lights34"


lights56 : Glsl.Uniform
lights56 =
    Glsl.uniform Glsl.highp Glsl.mat4 "lights56"


lights78 : Glsl.Uniform
lights78 =
    Glsl.uniform Glsl.highp Glsl.mat4 "lights78"


enabledLights : Glsl.Uniform
enabledLights =
    Glsl.uniform Glsl.lowp Glsl.vec4 "enabledLights"


materialColor : Glsl.Uniform
materialColor =
    Glsl.uniform Glsl.lowp Glsl.vec4 "materialColor"


constantMaterialColor : Glsl.Uniform
constantMaterialColor =
    Glsl.uniform Glsl.lowp Glsl.vec4 "constantMaterialColor"


materialColorTexture : Glsl.Uniform
materialColorTexture =
    Glsl.uniform Glsl.mediump Glsl.sampler2D "materialColorTexture"


quadVertexPositions : Glsl.Uniform
quadVertexPositions =
    Glsl.uniform Glsl.highp Glsl.mat4 "quadVertexPositions"


triangleVertexPositions : Glsl.Uniform
triangleVertexPositions =
    Glsl.uniform Glsl.highp Glsl.mat4 "triangleVertexPositions"


lineSegmentStartPoint : Glsl.Uniform
lineSegmentStartPoint =
    Glsl.uniform Glsl.highp Glsl.vec3 "lineSegmentStartPoint"


lineSegmentEndPoint : Glsl.Uniform
lineSegmentEndPoint =
    Glsl.uniform Glsl.highp Glsl.vec3 "lineSegmentEndPoint"


pointPosition : Glsl.Uniform
pointPosition =
    Glsl.uniform Glsl.highp Glsl.vec3 "pointPosition"



---------- VARYINGS ----------


interpolatedPosition : Glsl.Varying
interpolatedPosition =
    Glsl.varying Glsl.highp Glsl.vec3 "interpolatedPosition"


interpolatedNormal : Glsl.Varying
interpolatedNormal =
    Glsl.varying Glsl.highp Glsl.vec3 "interpolatedNormal"


interpolatedUv : Glsl.Varying
interpolatedUv =
    Glsl.varying Glsl.mediump Glsl.vec2 "interpolatedUv"


interpolatedTangent : Glsl.Varying
interpolatedTangent =
    Glsl.varying Glsl.highp Glsl.vec4 "interpolatedTangent"



---------- CONSTANTS ----------


kPerspectiveProjection : Glsl.Constant
kPerspectiveProjection =
    Glsl.constant Glsl.lowp Glsl.float "kPerspectiveProjection" "0.0"


kOrthographicProjection : Glsl.Constant
kOrthographicProjection =
    Glsl.constant Glsl.lowp Glsl.float "kOrthographicProjection" "1.0"


kDisabledLight : Glsl.Constant
kDisabledLight =
    Glsl.constant Glsl.lowp Glsl.float "kDisabledLight" "0.0"


kDirectionalLight : Glsl.Constant
kDirectionalLight =
    Glsl.constant Glsl.lowp Glsl.float "kDirectionalLight" "1.0"


kPointLight : Glsl.Constant
kPointLight =
    Glsl.constant Glsl.lowp Glsl.float "kPointLight" "2.0"


kSoftLighting : Glsl.Constant
kSoftLighting =
    Glsl.constant Glsl.lowp Glsl.float "kSoftLighting" "3.0"


kPi : Glsl.Constant
kPi =
    Glsl.constant Glsl.highp Glsl.float "kPi" "3.14159265359"


kMediumpFloatMax : Glsl.Constant
kMediumpFloatMax =
    Glsl.constant Glsl.mediump Glsl.float "kMediumpFloatMax" "65504.0"



---------- FUNCTIONS ----------


gammaCorrect : Glsl.Function
gammaCorrect =
    Glsl.function { dependencies = [], constants = [] }
        """
        float gammaCorrect(float u) {
            if (u <= 0.0031308) {
                return 12.92 * u;
            } else {
                return 1.055 * pow(u, 1.0 / 2.4) - 0.055;
            }
        }
        """


gammaCorrectedColor : Glsl.Function
gammaCorrectedColor =
    Glsl.function { dependencies = [ gammaCorrect ], constants = [] }
        """
        vec3 gammaCorrectedColor(vec3 color) {
            float red = gammaCorrect(color.r);
            float green = gammaCorrect(color.g);
            float blue = gammaCorrect(color.b);
            return vec3(red, green, blue);
        }
        """


reinhardLuminanceToneMap : Glsl.Function
reinhardLuminanceToneMap =
    Glsl.function { dependencies = [ gammaCorrectedColor ], constants = [] }
        """
        vec3 reinhardLuminanceToneMap(vec3 color) {
            float luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
            float scale = 1.0 / (1.0 + luminance);
            return gammaCorrectedColor(color * scale);
        }
        """


reinhardPerChannelToneMap : Glsl.Function
reinhardPerChannelToneMap =
    Glsl.function { dependencies = [ gammaCorrectedColor ], constants = [] }
        """
        vec3 reinhardPerChannelToneMap(vec3 color) {
            return gammaCorrectedColor(color / (color + 1.0));
        }
        """


extendedReinhardToneMap : Glsl.Function
extendedReinhardToneMap =
    Glsl.function { dependencies = [], constants = [] }
        """
        float extendedReinhardToneMap(float x, float xMax) {
            return x * (1.0 + (x / (xMax * xMax))) / (1.0 + x);
        }
        """


extendedReinhardLuminanceToneMap : Glsl.Function
extendedReinhardLuminanceToneMap =
    Glsl.function { dependencies = [ extendedReinhardToneMap, gammaCorrectedColor ], constants = [] }
        """
        vec3 extendedReinhardLuminanceToneMap(vec3 color, float overexposureLimit) {
            float luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
            float scaledLuminance = extendedReinhardToneMap(luminance, overexposureLimit);
            float scale = scaledLuminance / luminance;
            return gammaCorrectedColor(color * scale);
        }
        """


extendedReinhardPerChannelToneMap : Glsl.Function
extendedReinhardPerChannelToneMap =
    Glsl.function { dependencies = [ extendedReinhardToneMap, gammaCorrectedColor ], constants = [] }
        """
        vec3 extendedReinhardPerChannelToneMap(vec3 color, float overexposureLimit) {
            float red = extendedReinhardToneMap(color.r, overexposureLimit);
            float green = extendedReinhardToneMap(color.g, overexposureLimit);
            float blue = extendedReinhardToneMap(color.b, overexposureLimit);
            return gammaCorrectedColor(vec3(red, green, blue));
        }
        """


hableFilmicHelper : Glsl.Function
hableFilmicHelper =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 hableFilmicHelper(vec3 color) {
            float a = 0.15;
            float b = 0.5;
            float c = 0.1;
            float d = 0.2;
            float e = 0.02;
            float f = 0.3;
            return (color * (a * color + c * b) + d * e) / (color * (a * color + b) + d * f) - e / f;
        }
        """


hableFilmicToneMap : Glsl.Function
hableFilmicToneMap =
    Glsl.function { dependencies = [ hableFilmicHelper, gammaCorrectedColor ], constants = [] }
        """
        vec3 hableFilmicToneMap(vec3 color) {
            float exposureBias = 2.0;
            vec3 unscaled = hableFilmicHelper(exposureBias * color);
            vec3 scale = 1.0 / hableFilmicHelper(vec3(11.2));
            return gammaCorrectedColor(scale * unscaled);
        }
        """


toneMap : Glsl.Function
toneMap =
    Glsl.function
        { dependencies =
            [ gammaCorrectedColor
            , reinhardLuminanceToneMap
            , reinhardPerChannelToneMap
            , extendedReinhardLuminanceToneMap
            , extendedReinhardPerChannelToneMap
            , hableFilmicToneMap
            ]
        , constants = []
        }
        """
        vec3 toneMap(vec3 color, float toneMapType, float toneMapParam) {
            if (toneMapType == 0.0) {
                return gammaCorrectedColor(color);
            } else if (toneMapType == 1.0) {
                return reinhardLuminanceToneMap(color);
            } else if (toneMapType == 2.0) {
                return reinhardPerChannelToneMap(color);
            } else if (toneMapType == 3.0) {
                return extendedReinhardLuminanceToneMap(color, toneMapParam);
            } else if (toneMapType == 4.0) {
                return extendedReinhardPerChannelToneMap(color, toneMapParam);
            } else if (toneMapType == 5.0) {
                return hableFilmicToneMap(color);
            } else {
                return vec3(0.0, 0.0, 0.0);
            }
        }
        """


toSrgb : Glsl.Function
toSrgb =
    Glsl.function { dependencies = [ toneMap, gammaCorrect, inverseAlpha ], constants = [] }
        """
        vec4 toSrgb(vec4 linearColor, mat4 sceneProperties) {
            float invAlpha = inverseAlpha(linearColor.a);
            vec3 referenceWhite = sceneProperties[2].rgb;
            float unitR = linearColor.r / referenceWhite.r * invAlpha;
            float unitG = linearColor.g / referenceWhite.g * invAlpha;
            float unitB = linearColor.b / referenceWhite.b * invAlpha;
            float toneMapType = sceneProperties[3][2];
            float toneMapParam = sceneProperties[3][3];
            return vec4(toneMap(vec3(unitR, unitG, unitB), toneMapType, toneMapParam) * linearColor.a, linearColor.a);
        }
        """


inverseGamma : Glsl.Function
inverseGamma =
    Glsl.function { dependencies = [], constants = [] }
        """
        float inverseGamma(float u) {
            if (u <= 0.04045) {
                return clamp(u / 12.92, 0.0, 1.0);
            } else {
                return clamp(pow((u + 0.055) / 1.055, 2.4), 0.0, 1.0);
            }
        }
        """


inverseAlpha : Glsl.Function
inverseAlpha =
    Glsl.function { dependencies = [], constants = [] }
        """
        float inverseAlpha(float value) {
            // the value used for alpha cannot be less than zero
            float signValue = float(sign(value));
            return signValue / (value + (signValue - 1.0));
        }
        """


fromSrgb : Glsl.Function
fromSrgb =
    Glsl.function { dependencies = [ inverseGamma, inverseAlpha ], constants = [] }
        """
        vec4 fromSrgb(vec4 srgbColor) {
            float invAlpha = inverseAlpha(srgbColor.a);
            return vec4(
                inverseGamma(srgbColor.r * invAlpha) * srgbColor.a,
                inverseGamma(srgbColor.g * invAlpha) * srgbColor.a,
                inverseGamma(srgbColor.b * invAlpha) * srgbColor.a,
                srgbColor.a
            );
        }
        """


pointAlpha : Glsl.Function
pointAlpha =
    Glsl.function { dependencies = [], constants = [] }
        """
        float pointAlpha(float pointRadius, vec2 pointCoord) {
            float pointSize = 2.0 * pointRadius;
            float x = (pointSize + 2.0) * (pointCoord.s - 0.5);
            float y = (pointSize + 2.0) * (pointCoord.t - 0.5);
            float r = sqrt(x * x + y * y);
            float innerRadius = pointRadius;
            float outerRadius = pointRadius + 1.0;
            if (r > outerRadius) {
                return 0.0;
            } else if (r > innerRadius) {
                return outerRadius - r;
            } else {
                return 1.0;
            }
        }
        """


safeNormalize : Glsl.Function
safeNormalize =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 safeNormalize(vec3 vector) {
            if (vector == vec3(0.0, 0.0, 0.0)) {
                return vector;
            } else {
                return normalize(vector);
            }
        }
        """


getWorldPosition : Glsl.Function
getWorldPosition =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec4 getWorldPosition(vec3 modelPosition, vec4 modelScale, mat4 modelMatrix) {
            vec4 scaledPosition = vec4(modelScale.xyz * modelPosition, 1.0);
            return modelMatrix * scaledPosition;
        }
        """


getWorldTangent : Glsl.Function
getWorldTangent =
    Glsl.function { dependencies = [ safeNormalize ], constants = [] }
        """
        vec4 getWorldTangent(vec4 modelTangent, vec4 modelScale, mat4 modelMatrix) {
            return vec4((modelMatrix * vec4(safeNormalize(modelScale.xyz * modelTangent.xyz), 0.0)).xyz, modelScale.w * modelTangent.w);
        }
        """


getWorldNormal : Glsl.Function
getWorldNormal =
    Glsl.function { dependencies = [ safeNormalize ], constants = [] }
        """
        vec3 getWorldNormal(vec3 modelNormal, vec4 modelScale, mat4 modelMatrix) {
            vec3 normalScale = vec3(modelScale.w / modelScale.x, modelScale.w / modelScale.y, modelScale.w / modelScale.z);
            return (modelMatrix * vec4(safeNormalize(normalScale * modelNormal), 0.0)).xyz;
        }
        """


getDirectionToLight : Glsl.Function
getDirectionToLight =
    Glsl.function
        { dependencies = []
        , constants = [ kDirectionalLight, kPointLight ]
        }
        """
        vec3 getDirectionToLight(vec3 surfacePosition, vec4 xyz_type, vec4 rgb_parameter) {
            float lightType = xyz_type.w;
            if (lightType == kDirectionalLight) {
                return xyz_type.xyz;
            } else if (lightType == kPointLight) {
                vec3 lightPosition = xyz_type.xyz;
                return normalize(lightPosition - surfacePosition);
            } else {
                return vec3(0.0, 0.0, 0.0);
            }
        }
        """


positiveDotProduct : Glsl.Function
positiveDotProduct =
    Glsl.function { dependencies = [], constants = [] }
        """
        float positiveDotProduct(vec3 v1, vec3 v2) {
            return clamp(dot(v1, v2), 0.0, 1.0);
        }
        """


softLightingLuminance : Glsl.Function
softLightingLuminance =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 softLightingLuminance(
            vec3 aboveLuminance,
            vec3 belowLuminance,
            vec3 localUpDirection,
            vec3 localLightDirection
        ) {
            float sinElevation = dot(localLightDirection, localUpDirection);
            float t = (sinElevation + 1.0) / 2.0;
            return aboveLuminance * t + belowLuminance * (1.0 - t);
        }
        """


getDirectionToLightAndNormalIlluminance : Glsl.Function
getDirectionToLightAndNormalIlluminance =
    Glsl.function
        { dependencies = []
        , constants = [ kDirectionalLight, kPointLight, kPi ]
        }
        """
        void getDirectionToLightAndNormalIlluminance(
            vec4 xyz_type,
            vec4 rgb_parameter,
            vec3 surfacePosition,
            out vec3 directionToLight,
            out vec3 normalIlluminance
        ) {
            float lightType = xyz_type.w;
            if (lightType == kDirectionalLight) {
                directionToLight = xyz_type.xyz;
                normalIlluminance = rgb_parameter.rgb;
            } else if (lightType == kPointLight) {
                vec3 lightPosition = xyz_type.xyz;
                vec3 displacement = lightPosition - surfacePosition;
                float distance = length(displacement);
                directionToLight = displacement / distance;
                normalIlluminance = rgb_parameter.rgb / (4.0 * kPi * distance * distance);
            }
        }
        """


getDirectionToCamera : Glsl.Function
getDirectionToCamera =
    Glsl.function { dependencies = [], constants = [ kPerspectiveProjection, kOrthographicProjection ] }
        """
        vec3 getDirectionToCamera(vec3 surfacePosition, mat4 sceneProperties) {
            float projectionType = sceneProperties[1].w;
            if (projectionType == kPerspectiveProjection) {
                vec3 cameraPoint = sceneProperties[1].xyz;
                return normalize(cameraPoint - surfacePosition);
            } else if (projectionType == kOrthographicProjection) {
                return sceneProperties[1].xyz;
            } else {
                return vec3(0.0, 0.0, 0.0);
            }
        }
        """


getFloatValue : Glsl.Function
getFloatValue =
    Glsl.function { dependencies = [], constants = [] }
        """
        float getFloatValue(sampler2D texture, vec2 uv, vec2 constantValue) {
            if (constantValue.y == 1.0) {
                return constantValue.x;
            } else {
                vec4 textureColor = texture2D(texture, uv);
                return dot(textureColor, vec4(0.2126, 0.7152, 0.0722, 0.0));
            }
        }
        """


getLocalNormal : Glsl.Function
getLocalNormal =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 getLocalNormal(sampler2D normalMap, float normalMapType, vec2 uv) {
            if (normalMapType == 0.0) {
                return vec3(0.0, 0.0, 1.0);
            } else {
                vec3 rgb = texture2D(normalMap, uv).rgb;
                float x = 2.0 * (rgb.r - 0.5);
                float y = 2.0 * (rgb.g - 0.5) * normalMapType;
                float z = 2.0 * (rgb.b - 0.5);
                return normalize(vec3(x, y, z));
            }
        }
        """


getNormalSign : Glsl.Function
getNormalSign =
    Glsl.function { dependencies = [], constants = [] }
        """
        float getNormalSign() {
            return 2.0 * float(gl_FrontFacing) - 1.0;
        }
        """


getMappedNormal : Glsl.Function
getMappedNormal =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 getMappedNormal(vec3 normal, vec4 tangent, vec3 localNormal) {
            vec3 bitangent = cross(normal, tangent.xyz) * tangent.w;
            return normalize(localNormal.x * tangent.xyz + localNormal.y * bitangent + localNormal.z * normal);
        }
        """


lambertianLight : Glsl.Function
lambertianLight =
    Glsl.function
        { dependencies = [ getDirectionToLightAndNormalIlluminance, positiveDotProduct, softLightingLuminance ]
        , constants = [ kDisabledLight, kSoftLighting, kPi ]
        }
        """
        vec3 lambertianLight(
            vec3 surfacePosition,
            vec3 surfaceNormal,
            vec3 materialColor,
            float ambientOcclusion,
            vec4 xyz_type,
            vec4 rgb_parameter
        ) {
            float lightType = xyz_type.w;
            if (lightType == kDisabledLight) {
                return vec3(0.0, 0.0, 0.0);
            } else if (lightType == kSoftLighting) {
                vec3 upDirection = xyz_type.xyz;
                vec3 aboveLuminance = rgb_parameter.rgb;
                vec3 belowLuminance = rgb_parameter.a * aboveLuminance;
                vec3 luminance = softLightingLuminance(aboveLuminance, belowLuminance, upDirection, surfaceNormal);
                return luminance * materialColor * ambientOcclusion;
            }

            vec3 directionToLight = vec3(0.0, 0.0, 0.0);
            vec3 normalIlluminance = vec3(0.0, 0.0, 0.0);
            getDirectionToLightAndNormalIlluminance(
                xyz_type,
                rgb_parameter,
                surfacePosition,
                directionToLight,
                normalIlluminance
            );

            float dotNL = positiveDotProduct(directionToLight, surfaceNormal);
            return (normalIlluminance * dotNL) * (materialColor / kPi);
        }
        """


lambertianLighting : Glsl.Function
lambertianLighting =
    Glsl.function
        { dependencies = [ lambertianLight ]
        , constants = []
        }
        """
        vec3 lambertianLighting(
            vec3 surfacePosition,
            vec3 surfaceNormal,
            vec3 materialColor,
            float ambientOcclusion,
            mat4 lights12,
            mat4 lights34,
            mat4 lights56,
            mat4 lights78,
            vec4 enabledLights
        ) {
            vec3 litColor1 = enabledLights[0] == 1.0 ? lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights12[0], lights12[1]) : vec3(0.0, 0.0, 0.0);
            vec3 litColor2 = enabledLights[1] == 1.0 ? lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights12[2], lights12[3]) : vec3(0.0, 0.0, 0.0);
            vec3 litColor3 = enabledLights[2] == 1.0 ? lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights34[0], lights34[1]) : vec3(0.0, 0.0, 0.0);
            vec3 litColor4 = enabledLights[3] == 1.0 ? lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights34[2], lights34[3]) : vec3(0.0, 0.0, 0.0);
            vec3 litColor5 = lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights56[0], lights56[1]);
            vec3 litColor6 = lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights56[2], lights56[3]);
            vec3 litColor7 = lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights78[0], lights78[1]);
            vec3 litColor8 = lambertianLight(surfacePosition, surfaceNormal, materialColor, ambientOcclusion, lights78[2], lights78[3]);
            return litColor1 + litColor2 + litColor3 + litColor4 + litColor5 + litColor6 + litColor7 + litColor8;
        }
        """


safeQuotient : Glsl.Function
safeQuotient =
    Glsl.function { dependencies = [], constants = [] }
        """
        float safeQuotient(float numerator, float denominator) {
            if (denominator == 0.0) {
                return 0.0;
            } else {
                return numerator / denominator;
            }
        }
        """


specularD : Glsl.Function
specularD =
    Glsl.function { dependencies = [], constants = [ kPi, kMediumpFloatMax ] }
        """
        // Adapted from https://google.github.io/filament/Filament.md.html#materialsystem/specularbrdf/normaldistributionfunction(speculard)
        float specularD(float alpha, float dotNH, vec3 normalDirection, vec3 halfDirection) {
            vec3 crossNH = cross(normalDirection, halfDirection);
            float a = dotNH * alpha;
            float k = alpha / (dot(crossNH, crossNH) + a * a);
            float d = k * k * (1.0 / kPi);
            return min(d, kMediumpFloatMax);
        }
        """


g1 : Glsl.Function
g1 =
    Glsl.function { dependencies = [ safeQuotient ], constants = [] }
        """
        float g1(float dotNV, float alphaSquared) {
            return safeQuotient(2.0 * dotNV, dotNV + sqrt(alphaSquared + (1.0 - alphaSquared) * dotNV * dotNV));
        }
        """


specularG : Glsl.Function
specularG =
    Glsl.function { dependencies = [ g1 ], constants = [] }
        """
        float specularG(float dotNL, float dotNV, float alphaSquared) {
            return g1(dotNV, alphaSquared) * g1(dotNL, alphaSquared);
        }
        """


fresnelColor : Glsl.Function
fresnelColor =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 fresnelColor(vec3 specularBaseColor, float dotVH) {
            vec3 one = vec3(1.0, 1.0, 1.0);
            float scale = exp2((-5.55473 * dotVH - 6.98316) * dotVH);
            return specularBaseColor + (one - specularBaseColor) * scale;
        }
        """


brdf : Glsl.Function
brdf =
    Glsl.function
        { dependencies = [ specularD, specularG, fresnelColor, safeQuotient ]
        , constants = []
        }
        """
        vec3 brdf(vec3 normalDirection, vec3 directionToCamera, vec3 directionToLight, float alpha, float dotNV, float dotNL, vec3 specularBaseColor, vec3 normalIlluminance) {
            vec3 halfDirection = normalize(directionToCamera + directionToLight);
            float dotVH = positiveDotProduct(directionToCamera, halfDirection);
            float dotNH = positiveDotProduct(normalDirection, halfDirection);
            float dotNHSquared = dotNH * dotNH;

            float d = specularD(alpha, dotNH, normalDirection, halfDirection);
            float g = specularG(dotNL, dotNV, alpha * alpha);
            vec3 f = fresnelColor(specularBaseColor, dotVH);
            return safeQuotient(d * g, 4.0 * dotNL * dotNV) * f;
        }
        """


sampleFacetNormal : Glsl.Function
sampleFacetNormal =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 sampleFacetNormal(vec3 vH, vec3 vT1, vec3 vT2, float s, float alpha) {
            float t2 = (1.0 - s);
            vec3 vNh = t2 * vT2 + sqrt(max(0.0, 1.0 - t2 * t2)) * vH;
            return normalize(vec3(alpha * vNh.x, alpha * vNh.y, max(0.0, vNh.z)));
        }
        """


softLightingSpecularSample : Glsl.Function
softLightingSpecularSample =
    Glsl.function
        { dependencies = [ softLightingLuminance, positiveDotProduct, fresnelColor, g1 ]
        , constants = []
        }
        """
        vec3 softLightingSpecularSample(
            vec3 aboveLuminance,
            vec3 belowLuminance,
            vec3 localUpDirection,
            vec3 localViewDirection,
            vec3 localLightDirection,
            vec3 localHalfDirection,
            float alphaSquared,
            vec3 specularBaseColor
        ) {
            vec3 luminance = softLightingLuminance(aboveLuminance, belowLuminance, localUpDirection, localLightDirection);
            float dotVH = positiveDotProduct(localViewDirection, localHalfDirection);
            float dotNL = localLightDirection.z;
            return luminance * (fresnelColor(specularBaseColor, dotVH) * g1(dotNL, alphaSquared));
        }
        """


physicalLight : Glsl.Function
physicalLight =
    Glsl.function
        { dependencies =
            [ getDirectionToLightAndNormalIlluminance
            , positiveDotProduct
            , brdf
            , softLighting
            ]
        , constants = [ kDisabledLight, kSoftLighting, kPi ]
        }
        """
        vec3 physicalLight(
            vec4 xyz_type,
            vec4 rgb_parameter,
            vec3 surfacePosition,
            vec3 normalDirection,
            vec3 directionToCamera,
            vec3 viewY,
            float dotNV,
            vec3 diffuseBaseColor,
            vec3 specularBaseColor,
            float alpha,
            float ambientOcclusion
        ) {
            float lightType = xyz_type.w;
            if (lightType == kDisabledLight) {
                return vec3(0.0, 0.0, 0.0);
            } else if (lightType == kSoftLighting) {
                return softLighting(normalDirection, diffuseBaseColor, specularBaseColor, alpha, directionToCamera, viewY, xyz_type, rgb_parameter) * ambientOcclusion;
            }

            vec3 directionToLight = vec3(0.0, 0.0, 0.0);
            vec3 normalIlluminance = vec3(0.0, 0.0, 0.0);
            getDirectionToLightAndNormalIlluminance(xyz_type, rgb_parameter, surfacePosition, directionToLight, normalIlluminance);

            float dotNL = positiveDotProduct(normalDirection, directionToLight);
            vec3 specularColor = brdf(normalDirection, directionToCamera, directionToLight, alpha, dotNV, dotNL, specularBaseColor, normalIlluminance);
            return (normalIlluminance * dotNL) * ((diffuseBaseColor / kPi) + specularColor);
        }
        """


softLighting : Glsl.Function
softLighting =
    Glsl.function
        { dependencies =
            [ sampleFacetNormal
            , softLightingSpecularSample
            , softLightingLuminance
            ]
        , constants = []
        }
        """
        vec3 softLighting(
            vec3 normalDirection,
            vec3 diffuseBaseColor,
            vec3 specularBaseColor,
            float alpha,
            vec3 directionToCamera,
            vec3 viewY,
            vec4 xyz_type,
            vec4 rgb_parameter
        ) {
            float alphaSquared = alpha * alpha;
            vec3 upDirection = xyz_type.xyz;
            vec3 luminanceAbove = rgb_parameter.rgb;
            vec3 luminanceBelow = rgb_parameter.a * luminanceAbove;
            vec3 crossProduct = cross(normalDirection, directionToCamera);
            float crossMagnitude = length(crossProduct);
            vec3 xDirection = vec3(0.0, 0.0, 0.0);
            vec3 yDirection = vec3(0.0, 0.0, 0.0);
            if (crossMagnitude > 1.0e-6) {
                yDirection = (1.0 / crossMagnitude) * crossProduct;
                xDirection = cross(yDirection, normalDirection);
            } else {
                vec3 viewY = vec3(viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1]);
                xDirection = normalize(cross(viewY, normalDirection));
                yDirection = cross(normalDirection, xDirection);
            }
            float localViewX = dot(directionToCamera, xDirection);
            float localViewZ = dot(directionToCamera, normalDirection);
            vec3 localViewDirection = vec3(localViewX, 0, localViewZ);
            float localUpX = dot(upDirection, xDirection);
            float localUpY = dot(upDirection, yDirection);
            float localUpZ = dot(upDirection, normalDirection);
            vec3 localUpDirection = vec3(localUpX, localUpY, localUpZ);

            vec3 vH = normalize(vec3(alpha * localViewX, 0.0, localViewZ));
            vec3 vT1 = vec3(0.0, 1.0, 0.0);
            vec3 vT2 = cross(vH, vT1);
            float s = 0.5 * (1.0 + vH.z);

            vec3 localHalfDirection = sampleFacetNormal(vH, vT1, vT2, s, alpha);
            vec3 localLightDirection = vec3(0.0, 0.0, 0.0);

            localLightDirection = -reflect(localViewDirection, localHalfDirection);
            vec3 specular = softLightingSpecularSample(luminanceAbove, luminanceBelow, localUpDirection, localViewDirection, localLightDirection, localHalfDirection, alphaSquared, specularBaseColor);

            localLightDirection = vec3(0.000000, 0.000000, 1.000000);
            vec3 diffuse = softLightingLuminance(luminanceAbove, luminanceBelow, localUpDirection, localLightDirection) * localLightDirection.z;

            return specular + diffuse * diffuseBaseColor;
        }
        """


physicalLighting : Glsl.Function
physicalLighting =
    Glsl.function { dependencies = [ physicalLight ], constants = [] }
        """
        vec3 physicalLighting(
            vec3 surfacePosition,
            vec3 surfaceNormal,
            vec3 baseColor,
            vec3 directionToCamera,
            mat4 viewMatrix,
            float roughness,
            float metallic,
            float ambientOcclusion,
            mat4 lights12,
            mat4 lights34,
            mat4 lights56,
            mat4 lights78,
            vec4 enabledLights
        ) {
            float dotNV = positiveDotProduct(surfaceNormal, directionToCamera);
            float alpha = roughness * roughness;
            float nonmetallic = 1.0 - metallic;
            vec3 diffuseBaseColor = nonmetallic * 0.96 * baseColor;
            vec3 specularBaseColor = nonmetallic * 0.04 * vec3(1.0, 1.0, 1.0) + metallic * baseColor;
            vec3 viewY = vec3(viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1]);

            vec3 litColor1 = enabledLights[0] == 1.0 ? physicalLight(lights12[0], lights12[1], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion) : vec3(0.0, 0.0, 0.0);
            vec3 litColor2 = enabledLights[1] == 1.0 ? physicalLight(lights12[2], lights12[3], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion) : vec3(0.0, 0.0, 0.0);
            vec3 litColor3 = enabledLights[2] == 1.0 ? physicalLight(lights34[0], lights34[1], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion) : vec3(0.0, 0.0, 0.0);
            vec3 litColor4 = enabledLights[3] == 1.0 ? physicalLight(lights34[2], lights34[3], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion) : vec3(0.0, 0.0, 0.0);
            vec3 litColor5 = physicalLight(lights56[0], lights56[1], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion);
            vec3 litColor6 = physicalLight(lights56[2], lights56[3], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion);
            vec3 litColor7 = physicalLight(lights78[0], lights78[1], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion);
            vec3 litColor8 = physicalLight(lights78[2], lights78[3], surfacePosition, surfaceNormal, directionToCamera, viewY, dotNV, diffuseBaseColor, specularBaseColor, alpha, ambientOcclusion);
            return litColor1 + litColor2 + litColor3 + litColor4 + litColor5 + litColor6 + litColor7 + litColor8;
        }
        """


getQuadVertex : Glsl.Function
getQuadVertex =
    Glsl.function { dependencies = [], constants = [] }
        """
        void getQuadVertex(int quadVertexIndex, mat4 quadVertexPositions, out vec3 position, out vec3 normal, out vec4 tangent) {
            vec3 next = vec3(0.0, 0.0, 0.0);
            vec3 prev = vec3(0.0, 0.0, 0.0);
            if (quadVertexIndex == 0) {
                prev = quadVertexPositions[3].xyz;
                position = quadVertexPositions[0].xyz;
                next = quadVertexPositions[1].xyz;
                tangent = vec4(normalize(next - position), 1.0);
            } else if (quadVertexIndex == 1) {
                prev = quadVertexPositions[0].xyz;
                position = quadVertexPositions[1].xyz;
                next = quadVertexPositions[2].xyz;
                tangent = vec4(normalize(position - prev), 1.0);
            } else if (quadVertexIndex == 2) {
                prev = quadVertexPositions[1].xyz;
                position = quadVertexPositions[2].xyz;
                next = quadVertexPositions[3].xyz;
                tangent = vec4(normalize(position - next), 1.0);
            } else {
                prev = quadVertexPositions[2].xyz;
                position = quadVertexPositions[3].xyz;
                next = quadVertexPositions[0].xyz;
                tangent = vec4(normalize(prev - position), 1.0);
            }
            normal = normalize(cross(next - position, prev - position));
        }
        """


getTriangleVertex : Glsl.Function
getTriangleVertex =
    Glsl.function { dependencies = [], constants = [] }
        """
        void getTriangleVertex(int triangleVertexIndex, mat4 triangleVertexPositions, out vec3 position, out vec3 normal) {
            vec3 p1 = triangleVertexPositions[0].xyz;
            vec3 p2 = triangleVertexPositions[1].xyz;
            vec3 p3 = triangleVertexPositions[2].xyz;
            normal = normalize(cross(p2 - p1, p3 - p2));
            float t1 = float(triangleVertexIndex == 0);
            float t2 = float(triangleVertexIndex == 1);
            float t3 = float(triangleVertexIndex == 2);
            position = t1 * p1 + t2 * p2 + t3 * p3;
        }
        """


shadowVertexPosition : Glsl.Function
shadowVertexPosition =
    Glsl.function
        { dependencies =
            [ getWorldPosition
            , getWorldNormal
            , getDirectionToLight
            ]
        , constants = []
        }
        """
        vec4 shadowVertexPosition(vec3 position, vec3 normal, mat4 shadowLight, vec4 modelScale, mat4 modelMatrix, mat4 viewMatrix, mat4 projectionMatrix, mat4 sceneProperties) {
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            vec3 worldNormal = getWorldNormal(normal, vec4(modelScale.xyz, 1.0), modelMatrix);
            vec4 xyz_type = shadowLight[0];
            vec4 rgb_parameter = shadowLight[1];
            vec3 directionToLight = getDirectionToLight(worldPosition.xyz, xyz_type, rgb_parameter);
            vec3 offset = vec3(0.0, 0.0, 0.0);
            float sceneDiameter = sceneProperties[3][1];
            if (dot(directionToLight, worldNormal) <= 0.0) {
                offset = -sceneDiameter * directionToLight;
            } else {
                offset = -0.001 * sceneDiameter * directionToLight;
            }
            vec4 offsetPosition = worldPosition + vec4(offset, 0.0);
            return projectionMatrix * (viewMatrix * offsetPosition);
        }
        """


perpendicularTo : Glsl.Function
perpendicularTo =
    Glsl.function { dependencies = [], constants = [] }
        """
        vec3 perpendicularTo(vec3 d) {
            float absX = abs(d.x);
            float absY = abs(d.y);
            float absZ = abs(d.z);
            if (absX <= absY) {
                if (absX <= absZ) {
                    float scale = 1.0 / length(d.zy);
                    return vec3(0.0, -d.z * scale, d.y * scale);
                } else {
                    float scale = 1.0 / length(d.xy);
                    return vec3(-d.y * scale, d.x * scale, 0.0);
                }
            } else {
                if (absY <= absZ) {
                    float scale = 1.0 / length(d.xz);
                    return vec3(d.z * scale, 0.0, -d.x * scale);
                } else {
                    float scale = 1.0 / length(d.xy);
                    return vec3(-d.y * scale, d.x * scale, 0.0);
                }
            }
        }
        """



---------- VERTEX SHADERS ----------


plainVertexShader : Glsl.Shader
plainVertexShader =
    Glsl.vertexShader "plainVertex"
        { attributes = [ position ]
        , uniforms = [ modelScale, modelMatrix, viewMatrix, projectionMatrix, sceneProperties ]
        , varyings = []
        , constants = []
        , functions = [ getWorldPosition ]
        }
        """
        void main () {
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
        }
        """


unlitVertexShader : Glsl.Shader
unlitVertexShader =
    Glsl.vertexShader "unlitVertex"
        { attributes = [ position, uv ]
        , uniforms = [ modelScale, modelMatrix, viewMatrix, projectionMatrix, sceneProperties ]
        , varyings = [ interpolatedUv ]
        , constants = []
        , functions = [ getWorldPosition ]
        }
        """
        void main() {
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedUv = uv;
        }
        """


uniformVertexShader : Glsl.Shader
uniformVertexShader =
    Glsl.vertexShader "uniformVertex"
        { attributes = [ position, normal ]
        , uniforms = [ modelScale, modelMatrix, viewMatrix, projectionMatrix, sceneProperties ]
        , varyings = [ interpolatedPosition, interpolatedNormal ]
        , constants = []
        , functions = [ getWorldPosition, getWorldNormal ]
        }
        """
        void main () {
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedPosition = worldPosition.xyz;
            interpolatedNormal = getWorldNormal(normal, modelScale, modelMatrix);
        }
        """


texturedVertexShader : Glsl.Shader
texturedVertexShader =
    Glsl.vertexShader "texturedVertex"
        { attributes = [ position, normal, uv ]
        , uniforms = [ modelScale, modelMatrix, viewMatrix, projectionMatrix, sceneProperties ]
        , varyings =
            [ interpolatedPosition
            , interpolatedNormal
            , interpolatedUv
            , interpolatedTangent
            ]
        , constants = []
        , functions = [ getWorldPosition, getWorldNormal ]
        }
        """
        void main () {
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedPosition = worldPosition.xyz;
            interpolatedNormal = getWorldNormal(normal, modelScale, modelMatrix);
            interpolatedUv = uv;
            interpolatedTangent = vec4(0.0, 0.0, 0.0, 0.0);
        }
        """


bumpyVertexShader : Glsl.Shader
bumpyVertexShader =
    Glsl.vertexShader "bumpyVertex"
        { attributes = [ position, normal, uv, tangent ]
        , uniforms = [ modelScale, modelMatrix, viewMatrix, projectionMatrix, sceneProperties ]
        , varyings =
            [ interpolatedPosition
            , interpolatedNormal
            , interpolatedUv
            , interpolatedTangent
            ]
        , constants = []
        , functions = [ getWorldPosition, getWorldNormal, getWorldTangent ]
        }
        """
        void main () {
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedPosition = worldPosition.xyz;
            interpolatedNormal = getWorldNormal(normal, modelScale, modelMatrix);
            interpolatedUv = uv;
            interpolatedTangent = getWorldTangent(tangent, modelScale, modelMatrix);
        }
        """


lineSegmentVertexShader : Glsl.Shader
lineSegmentVertexShader =
    Glsl.vertexShader "lineSegmentVertex"
        { attributes = [ lineSegmentVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , lineSegmentStartPoint
            , lineSegmentEndPoint
            ]
        , varyings = []
        , constants = []
        , functions = [ getWorldPosition ]
        }
        """
        void main() {
            vec3 position = (1.0 - lineSegmentVertex) * lineSegmentStartPoint + lineSegmentVertex * lineSegmentEndPoint;
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
        }
        """


plainTriangleVertexShader : Glsl.Shader
plainTriangleVertexShader =
    Glsl.vertexShader "plainTriangleVertex"
        { attributes = [ triangleVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , triangleVertexPositions
            ]
        , varyings = []
        , constants = []
        , functions = [ getTriangleVertex, getWorldPosition ]
        }
        """
        void main() {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            getTriangleVertex(int(triangleVertex), triangleVertexPositions, position, normal);
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
        }
        """


plainQuadVertexShader : Glsl.Shader
plainQuadVertexShader =
    Glsl.vertexShader "plainQuadVertex"
        { attributes = [ quadVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , quadVertexPositions
            ]
        , varyings = []
        , constants = []
        , functions = [ getQuadVertex, getWorldPosition ]
        }
        """
        void main() {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            vec4 tangent = vec4(0.0, 0.0, 0.0, 0.0);
            getQuadVertex(int(quadVertex.z), quadVertexPositions, position, normal, tangent);
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
        }
        """


unlitQuadVertexShader : Glsl.Shader
unlitQuadVertexShader =
    Glsl.vertexShader "unlitQuadVertex"
        { attributes = [ quadVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , quadVertexPositions
            ]
        , varyings = [ interpolatedUv ]
        , constants = []
        , functions = [ getQuadVertex, getWorldPosition ]
        }
        """
        void main() {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            vec4 tangent = vec4(0.0, 0.0, 0.0, 0.0);
            getQuadVertex(int(quadVertex.z), quadVertexPositions, position, normal, tangent);
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedUv = quadVertex.xy;
        }
        """


smoothTriangleVertexShader : Glsl.Shader
smoothTriangleVertexShader =
    Glsl.vertexShader "smoothTriangleVertex"
        { attributes = [ triangleVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , triangleVertexPositions
            ]
        , varyings = [ interpolatedPosition, interpolatedNormal ]
        , constants = []
        , functions = [ getTriangleVertex, getWorldPosition, getWorldNormal ]
        }
        """
        void main() {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            getTriangleVertex(int(triangleVertex), triangleVertexPositions, position, normal);
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedPosition = worldPosition.xyz;
            interpolatedNormal = getWorldNormal(normal, modelScale, modelMatrix);
        }
        """


smoothQuadVertexShader : Glsl.Shader
smoothQuadVertexShader =
    Glsl.vertexShader "smoothQuadVertex"
        { attributes = [ quadVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , quadVertexPositions
            ]
        , varyings = [ interpolatedPosition, interpolatedNormal ]
        , constants = []
        , functions = [ getQuadVertex, getWorldPosition, getWorldNormal ]
        }
        """
        void main() {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            vec4 tangent = vec4(0.0, 0.0, 0.0, 0.0);
            getQuadVertex(int(quadVertex.z), quadVertexPositions, position, normal, tangent);
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedPosition = worldPosition.xyz;
            interpolatedNormal = getWorldNormal(normal, modelScale, modelMatrix);
        }
        """


texturedQuadVertexShader : Glsl.Shader
texturedQuadVertexShader =
    Glsl.vertexShader "texturedQuadVertex"
        { attributes = [ quadVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , quadVertexPositions
            ]
        , varyings = [ interpolatedPosition, interpolatedNormal, interpolatedUv, interpolatedTangent ]
        , constants = []
        , functions = [ getQuadVertex, getWorldPosition, getWorldNormal ]
        }
        """
        void main() {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            vec4 tangent = vec4(0.0, 0.0, 0.0, 0.0);
            getQuadVertex(int(quadVertex.z), quadVertexPositions, position, normal, tangent);
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            interpolatedPosition = worldPosition.xyz;
            interpolatedNormal = getWorldNormal(normal, modelScale, modelMatrix);
            interpolatedUv = quadVertex.xy;
            interpolatedTangent = tangent;
        }
        """


singlePointVertexShader : Glsl.Shader
singlePointVertexShader =
    Glsl.vertexShader "singlePointVertex"
        { attributes = [ dummyAttribute ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , pointRadius
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , pointPosition
            ]
        , varyings = []
        , constants = []
        , functions = [ getWorldPosition ]
        }
        -- Note that we actually have to 'use' dummyAttribute here (it will
        -- always be 1). Otherwise Safari will notice that no mesh attributes
        -- are actually used, and as a result will skip some initialization
        -- steps that Elm's WebGL library depends on.
        """
        void main () {
            vec4 worldPosition = getWorldPosition(pointPosition, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            float supersampling = sceneProperties[3][0];
            gl_PointSize = 2.0 * pointRadius * supersampling * dummyAttribute + 2.0;
        }
        """


pointVertexShader : Glsl.Shader
pointVertexShader =
    Glsl.vertexShader "pointVertex"
        { attributes = [ position ]
        , uniforms = [ modelScale, modelMatrix, pointRadius, viewMatrix, projectionMatrix, sceneProperties ]
        , varyings = []
        , constants = []
        , functions = [ getWorldPosition ]
        }
        """
        void main () {
            vec4 worldPosition = getWorldPosition(position, modelScale, modelMatrix);
            gl_Position = projectionMatrix * (viewMatrix * worldPosition);
            float supersampling = sceneProperties[3][0];
            gl_PointSize = 2.0 * pointRadius * supersampling + 2.0;
        }
        """


shadowVertexShader : Glsl.Shader
shadowVertexShader =
    Glsl.vertexShader "shadowVertex"
        { attributes = [ position, normal ]
        , uniforms = [ modelScale, modelMatrix, viewMatrix, projectionMatrix, sceneProperties, shadowLight ]
        , varyings = []
        , constants = []
        , functions = [ shadowVertexPosition ]
        }
        """
        void main () {
            gl_Position = shadowVertexPosition(
                position,
                normal,
                shadowLight,
                modelScale,
                modelMatrix,
                viewMatrix,
                projectionMatrix,
                sceneProperties
            );
        }
        """


triangleShadowVertexShader : Glsl.Shader
triangleShadowVertexShader =
    Glsl.vertexShader "triangleShadowVertex"
        { attributes = [ triangleShadowVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , shadowLight
            , triangleVertexPositions
            ]
        , varyings = []
        , constants = []
        , functions = [ getTriangleVertex, shadowVertexPosition ]
        }
        """
        void main () {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            getTriangleVertex(int(triangleShadowVertex.x), triangleVertexPositions, position, normal);
            normal *= triangleShadowVertex.y;
            gl_Position = shadowVertexPosition(
                position,
                normal,
                shadowLight,
                modelScale,
                modelMatrix,
                viewMatrix,
                projectionMatrix,
                sceneProperties
            );
        }
        """


quadShadowVertexShader : Glsl.Shader
quadShadowVertexShader =
    Glsl.vertexShader "quadShadowVertex"
        { attributes = [ quadShadowVertex ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , shadowLight
            , quadVertexPositions
            ]
        , varyings = []
        , constants = []
        , functions = [ getQuadVertex, shadowVertexPosition ]
        }
        """
        void main () {
            vec3 position = vec3(0.0, 0.0, 0.0);
            vec3 normal = vec3(0.0, 0.0, 0.0);
            vec4 tangent = vec4(0.0, 0.0, 0.0, 0.0);
            getQuadVertex(int(quadShadowVertex.x), quadVertexPositions, position, normal, tangent);
            normal *= quadShadowVertex.y;
            gl_Position = shadowVertexPosition(
                position,
                normal,
                shadowLight,
                modelScale,
                modelMatrix,
                viewMatrix,
                projectionMatrix,
                sceneProperties
            );
        }
        """


sphereShadowVertexShader : Glsl.Shader
sphereShadowVertexShader =
    Glsl.vertexShader "sphereShadowVertex"
        { attributes = [ angle, offsetScale, radiusScale ]
        , uniforms =
            [ modelScale
            , modelMatrix
            , viewMatrix
            , projectionMatrix
            , sceneProperties
            , shadowLight
            ]
        , functions =
            [ getWorldPosition
            , getDirectionToLight
            , perpendicularTo
            ]
        , constants = [ kPerspectiveProjection ]
        , varyings = []
        }
        """
        void main () {
            vec4 worldCenter = getWorldPosition(vec3(0.0, 0.0, 0.0), modelScale, modelMatrix);
            vec4 xyz_type = shadowLight[0];
            vec4 rgb_parameter = shadowLight[1];
            vec3 zDirection = getDirectionToLight(worldCenter.xyz, xyz_type, rgb_parameter);
            vec3 xDirection = perpendicularTo(zDirection);
            vec3 yDirection = cross(zDirection, xDirection);
            float r = modelScale.x;
            float adjustedRadius = r;
            float zOffset = 0.0;
            if (xyz_type.w == kPointLight) {
                float distanceToLight = length(xyz_type.xyz - worldCenter.xyz);
                float rSquared = r * r;
                zOffset = rSquared / distanceToLight;
                float zSquared = zOffset * zOffset;
                adjustedRadius = sqrt(rSquared - zSquared) * radiusScale;
            }
            vec3 worldPosition =
                worldCenter.xyz
                    + zDirection * zOffset
                    + xDirection * adjustedRadius * cos(angle)
                    + yDirection * adjustedRadius * sin(angle);
            vec3 directionToLight = getDirectionToLight(worldPosition, xyz_type, rgb_parameter);
            float sceneDiameter = sceneProperties[3][1];
            vec3 offset = -sceneDiameter * offsetScale * directionToLight;
            vec4 offsetPosition = vec4(worldPosition + offset, 1.0);
            gl_Position = projectionMatrix * (viewMatrix * offsetPosition);
        }
        """



---------- FRAGMENT SHADERS ----------


shadowFragmentShader : Glsl.Shader
shadowFragmentShader =
    Glsl.fragmentShader "shadowFragment"
        { precision = Glsl.lowp
        , uniforms = []
        , varyings = []
        , constants = []
        , functions = []
        }
        """
        void main () {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
        """


constantFragmentShader : Glsl.Shader
constantFragmentShader =
    Glsl.fragmentShader "constantFragment"
        { precision = Glsl.lowp
        , uniforms = [ constantColor ]
        , constants = []
        , varyings = []
        , functions = []
        }
        """
        void main () {
            gl_FragColor = constantColor;
        }
        """


colorTextureFragmentShader : Glsl.Shader
colorTextureFragmentShader =
    Glsl.fragmentShader "colorTextureFragment"
        { precision = Glsl.mediump
        , uniforms = [ colorTexture ]
        , constants = []
        , varyings = [ interpolatedUv ]
        , functions = []
        }
        """
        void main () {
            gl_FragColor = texture2D(colorTexture, interpolatedUv);
        }
        """


constantPointFragmentShader : Glsl.Shader
constantPointFragmentShader =
    Glsl.fragmentShader "constantPointFragment"
        { precision = Glsl.lowp
        , uniforms = [ constantColor, pointRadius, sceneProperties ]
        , constants = []
        , varyings = []
        , functions = [ pointAlpha ]
        }
        """
        void main () {
            float supersampling = sceneProperties[3][0];
            float alpha = pointAlpha(pointRadius * supersampling, gl_PointCoord);
            gl_FragColor = constantColor * alpha;
        }
        """


emissiveFragmentShader : Glsl.Shader
emissiveFragmentShader =
    Glsl.fragmentShader "emissiveFragment"
        { precision = Glsl.mediump
        , uniforms = [ emissiveColor, sceneProperties ]
        , constants = []
        , varyings = []
        , functions = [ toSrgb ]
        }
        """
        void main () {
            gl_FragColor = toSrgb(emissiveColor, sceneProperties);
        }
        """


emissiveTextureFragmentShader : Glsl.Shader
emissiveTextureFragmentShader =
    Glsl.fragmentShader "emissiveTextureFragment"
        { precision = Glsl.mediump
        , uniforms = [ colorTexture, backlight, sceneProperties ]
        , varyings = [ interpolatedUv ]
        , constants = []
        , functions = [ fromSrgb, toSrgb ]
        }
        """
        void main () {
            vec4 linearTextureColor = fromSrgb(texture2D(colorTexture, interpolatedUv));
            vec4 emissiveColor = vec4(linearTextureColor.rgb * backlight, linearTextureColor.a);
            gl_FragColor = toSrgb(emissiveColor, sceneProperties);
        }
        """


emissivePointFragmentShader : Glsl.Shader
emissivePointFragmentShader =
    Glsl.fragmentShader "emissivePointFragment"
        { precision = Glsl.mediump
        , uniforms = [ emissiveColor, pointRadius, sceneProperties ]
        , varyings = []
        , functions = [ toSrgb, pointAlpha ]
        , constants = []
        }
        """
        void main () {
            vec4 color = toSrgb(emissiveColor, sceneProperties);
            float supersampling = sceneProperties[3][0];
            float alpha = pointAlpha(pointRadius * supersampling, gl_PointCoord);
            gl_FragColor = color * alpha;
        }
        """


lambertianFragmentShader : Glsl.Shader
lambertianFragmentShader =
    Glsl.fragmentShader "lambertianFragment"
        { precision = Glsl.highp
        , uniforms =
            [ sceneProperties
            , lights12
            , lights34
            , lights56
            , lights78
            , enabledLights
            , materialColor
            , ambientOcclusion
            , viewMatrix
            ]
        , varyings = [ interpolatedPosition, interpolatedNormal ]
        , constants = []
        , functions =
            [ getNormalSign
            , getDirectionToCamera
            , lambertianLighting
            , toSrgb
            ]
        }
        """
        void main() {
            vec3 normalDirection = normalize(interpolatedNormal) * getNormalSign();
            vec3 directionToCamera = getDirectionToCamera(interpolatedPosition, sceneProperties);

            vec3 linearColor = lambertianLighting(
                interpolatedPosition,
                normalDirection,
                materialColor.rgb,
                ambientOcclusion,
                lights12,
                lights34,
                lights56,
                lights78,
                enabledLights
            );

            gl_FragColor = toSrgb(vec4(linearColor, materialColor.a), sceneProperties);
        }
        """


lambertianTextureFragmentShader : Glsl.Shader
lambertianTextureFragmentShader =
    Glsl.fragmentShader "lambertianTextureFragment"
        { precision = Glsl.highp
        , uniforms =
            [ sceneProperties
            , lights12
            , lights34
            , lights56
            , lights78
            , enabledLights
            , materialColorTexture
            , constantMaterialColor
            , ambientOcclusionTexture
            , constantAmbientOcclusion
            , normalMapTexture
            , normalMapType
            , viewMatrix
            ]
        , varyings = [ interpolatedPosition, interpolatedNormal, interpolatedUv, interpolatedTangent ]
        , constants = []
        , functions =
            [ getLocalNormal
            , getNormalSign
            , getMappedNormal
            , getFloatValue
            , getDirectionToCamera
            , lambertianLighting
            , fromSrgb
            , toSrgb
            ]
        }
        """
        void main() {
            vec3 localNormal = getLocalNormal(normalMapTexture, normalMapType, interpolatedUv);
            float normalSign = getNormalSign();
            vec3 originalNormal = normalize(interpolatedNormal) * normalSign;
            vec3 normalDirection = getMappedNormal(originalNormal, interpolatedTangent, localNormal);
            float ambientOcclusion = getFloatValue(ambientOcclusionTexture, interpolatedUv, constantAmbientOcclusion);
            vec3 directionToCamera = getDirectionToCamera(interpolatedPosition, sceneProperties);
            float useConstantColor = float(sign(constantMaterialColor.a));  // 1.0 for color, 0.0 for texture
            vec4 materialColor = fromSrgb(texture2D(materialColorTexture, interpolatedUv)) * (1.0 - useConstantColor) + constantMaterialColor * useConstantColor;

            vec3 linearColor = lambertianLighting(
                interpolatedPosition,
                normalDirection,
                materialColor.rgb,
                ambientOcclusion,
                lights12,
                lights34,
                lights56,
                lights78,
                enabledLights
            );

            gl_FragColor = toSrgb(vec4(linearColor, materialColor.a), sceneProperties);
        }
        """


physicalFragmentShader : Glsl.Shader
physicalFragmentShader =
    Glsl.fragmentShader "physicalFragment"
        { precision = Glsl.highp
        , uniforms =
            [ sceneProperties
            , viewMatrix
            , lights12
            , lights34
            , lights56
            , lights78
            , enabledLights
            , baseColor
            , roughness
            , metallic
            , ambientOcclusion
            ]
        , varyings = [ interpolatedPosition, interpolatedNormal ]
        , functions =
            [ getNormalSign
            , getDirectionToCamera
            , physicalLighting
            , toSrgb
            ]
        , constants = []
        }
        """
        void main() {
            vec3 normalDirection = normalize(interpolatedNormal) * getNormalSign();
            vec3 directionToCamera = getDirectionToCamera(interpolatedPosition, sceneProperties);

            vec3 linearColor = physicalLighting(
                interpolatedPosition,
                normalDirection,
                baseColor.rgb,
                directionToCamera,
                viewMatrix,
                roughness,
                metallic,
                ambientOcclusion,
                lights12,
                lights34,
                lights56,
                lights78,
                enabledLights
            );

            gl_FragColor = toSrgb(vec4(linearColor, baseColor.a), sceneProperties);
        }
        """


physicalTexturesFragmentShader : Glsl.Shader
physicalTexturesFragmentShader =
    Glsl.fragmentShader "physicalTexturesFragment"
        { precision = Glsl.highp
        , uniforms =
            [ sceneProperties
            , viewMatrix
            , lights12
            , lights34
            , lights56
            , lights78
            , enabledLights
            , baseColorTexture
            , constantBaseColor
            , roughnessTexture
            , constantRoughness
            , metallicTexture
            , constantMetallic
            , ambientOcclusionTexture
            , constantAmbientOcclusion
            , normalMapTexture
            , normalMapType
            ]
        , varyings =
            [ interpolatedPosition
            , interpolatedNormal
            , interpolatedUv
            , interpolatedTangent
            ]
        , functions =
            [ getFloatValue
            , getLocalNormal
            , getNormalSign
            , getMappedNormal
            , getDirectionToCamera
            , physicalLighting
            , fromSrgb
            , toSrgb
            ]
        , constants = []
        }
        """
        void main() {
            float useConstantColor = float(sign(constantBaseColor.a));  // 1.0 for color, 0.0 for texture
            vec4 baseColor = fromSrgb(texture2D(baseColorTexture, interpolatedUv)) * (1.0 - useConstantColor) + constantBaseColor * useConstantColor;

            float roughness = getFloatValue(roughnessTexture, interpolatedUv, constantRoughness);
            float metallic = getFloatValue(metallicTexture, interpolatedUv, constantMetallic);
            float ambientOcclusion = getFloatValue(ambientOcclusionTexture, interpolatedUv, constantAmbientOcclusion);

            vec3 localNormal = getLocalNormal(normalMapTexture, normalMapType, interpolatedUv);
            float normalSign = getNormalSign();
            vec3 originalNormal = normalize(interpolatedNormal) * normalSign;
            vec3 normalDirection = getMappedNormal(originalNormal, interpolatedTangent, localNormal);
            vec3 directionToCamera = getDirectionToCamera(interpolatedPosition, sceneProperties);

            vec3 linearColor = physicalLighting(
                interpolatedPosition,
                normalDirection,
                baseColor.rgb,
                directionToCamera,
                viewMatrix,
                roughness,
                metallic,
                ambientOcclusion,
                lights12,
                lights34,
                lights56,
                lights78,
                enabledLights
            );

            gl_FragColor = toSrgb(vec4(linearColor, baseColor.a), sceneProperties);
        }
        """



---------- SCRIPT ----------


fixSource : String -> String
fixSource input =
    let
        doRegex =
            Regex.fromString "\\bdo\\b"
                |> Maybe.withDefault Regex.never

        ifRegex =
            Regex.fromString "\\bif\\b(?!\\()"
                |> Maybe.withDefault Regex.never

        inRegex =
            Regex.fromString "\\bin\\b"
                |> Maybe.withDefault Regex.never
    in
    input
        |> Regex.replace doRegex (always "do_")
        |> Regex.replace ifRegex (always "if_")
        |> Regex.replace inRegex (always "in_")


optimizeShader : Script.UserPrivileges -> Glsl.Shader -> Script String Glsl.Shader
optimizeShader userPrivileges givenShader =
    Directory.createTemporary
        |> Script.thenWith
            (\tempDirectory ->
                let
                    inputFile =
                        File.in_ tempDirectory "input.glsl"

                    outputFile =
                        File.in_ tempDirectory "output.glsl"

                    shaderTypeString =
                        case Glsl.shaderType givenShader of
                            Glsl.VertexShader ->
                                "vertex"

                            Glsl.FragmentShader ->
                                "fragment"
                in
                Script.printLine ("Optimizing " ++ Glsl.shaderName givenShader)
                    |> Script.andThen (File.writeTo inputFile (Glsl.shaderSource givenShader))
                    |> Script.andThen
                        (Script.executeWith userPrivileges
                            { command = "glsl-minifier.cmd"
                            , arguments =
                                [ "-i"
                                , File.name inputFile
                                , "-o"
                                , File.name outputFile
                                , "-sT"
                                , shaderTypeString
                                , "-sV"
                                , "2" -- WebGL 1
                                ]
                            , workingDirectory = tempDirectory
                            }
                            |> Script.ignoreResult
                        )
                    |> Script.andThen (File.read outputFile)
                    |> Script.map fixSource
                    |> Script.thenWith
                        (\optimizedSource ->
                            Script.succeed (givenShader |> Glsl.setShaderSource optimizedSource)
                        )
            )


writeToFile : File Writable -> String -> Directory Writable -> UserPrivileges -> List Glsl.Shader -> Script String ()
writeToFile outputFile moduleName workingDirectory userPrivileges shaders =
    let
        contents =
            "-- Generated by scripts/GenerateShaders.elm, please do not edit by hand\n"
                ++ Glsl.generateModule moduleName shaders
    in
    Script.printLine ("Writing " ++ File.name outputFile ++ "...")
        |> Script.andThen (File.write contents outputFile)
        |> Script.andThen (Script.printLine "Formatting output file with elm-format...")
        |> Script.andThen
            (Script.executeWith userPrivileges
                { command = "elm-format"
                , arguments = [ "--yes", File.path outputFile ]
                , workingDirectory = workingDirectory
                }
                |> Script.ignoreResult
                |> Script.onError (\_ -> Script.fail "Error when running elm-format")
            )
        |> Script.andThen (Script.printLine "Test compiling output file...")
        |> Script.andThen
            (Script.executeWith userPrivileges
                { command = "elm"
                , arguments = [ "make", "--output=/dev/null", File.path outputFile ]
                , workingDirectory = workingDirectory
                }
                |> Script.ignoreResult
                |> Script.onError (\_ -> Script.fail "Error when running 'elm make'")
            )
        |> Script.andThen (Script.printLine "Success!")


script : Script.Init -> Script String ()
script { workingDirectory, userPrivileges } =
    let
        optimizedOutputFile =
            File.writable userPrivileges "../src/Scene3d/OptimizedShaders.elm"

        unoptimizedOutputFile =
            File.writable userPrivileges "../src/Scene3d/UnoptimizedShaders.elm"

        shaders =
            [ plainVertexShader
            , unlitVertexShader
            , uniformVertexShader
            , texturedVertexShader
            , bumpyVertexShader
            , singlePointVertexShader
            , lineSegmentVertexShader
            , plainTriangleVertexShader
            , plainQuadVertexShader
            , unlitQuadVertexShader
            , smoothTriangleVertexShader
            , smoothQuadVertexShader
            , texturedQuadVertexShader
            , pointVertexShader
            , shadowVertexShader
            , triangleShadowVertexShader
            , quadShadowVertexShader
            , sphereShadowVertexShader
            , shadowFragmentShader
            , constantFragmentShader
            , colorTextureFragmentShader
            , constantPointFragmentShader
            , emissiveFragmentShader
            , emissiveTextureFragmentShader
            , emissivePointFragmentShader
            , lambertianFragmentShader
            , lambertianTextureFragmentShader
            , physicalFragmentShader
            , physicalTexturesFragmentShader
            ]
    in
    Script.printLine "Writing unoptimized shaders..."
        |> Script.andThen
            (writeToFile unoptimizedOutputFile
                "Scene3d.UnoptimizedShaders"
                workingDirectory
                userPrivileges
                shaders
            )


main : Script.Program
main =
    Script.program script
