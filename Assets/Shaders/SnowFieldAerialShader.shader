Shader "Custom/SnowFieldAerialShader"
{
    Properties
    {
        _MainTex ("Diffuse", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
        _DisplacementMap ("Displacement Map", 2D) = "white" {} // Mapa de Displacement
        _AORMMap ("AO/Rough/Metal", 2D) = "white" {} // Mapa combinado de AO, Roughness, Metalness
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _RoughnessMap;
            sampler2D _DisplacementMap; // Sampler para el mapa de Displacement
            sampler2D _AORMMap; // Sampler para el mapa combinado de AO/Roughness/Metalness

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Sample the textures
                half4 albedo = tex2D(_MainTex, i.uv);
                half4 normalTex = tex2D(_NormalMap, i.uv);
                half4 roughnessDisplacement = tex2D(_RoughnessMap, i.uv);
                half4 displacementMap = tex2D(_DisplacementMap, i.uv);
                half4 aormMap = tex2D(_AORMMap, i.uv); // Sample the combined AO, Roughness, Metalness map

                // Convert the normal map from [0, 1] range to [-1, 1] range
                half3 normal = normalize(normalTex.rgb * 2.0 - 1.0);

                // Apply the normal map to the world normal
                normal = normalize(normal);

                // Calculate roughness and displacement factors
                half roughness = roughnessDisplacement.r;
                half displacement = displacementMap.r; // Extract the displacement value
                half ao = aormMap.r; // Extract the AO value
                half metalness = aormMap.g; // Extract the Metalness value

                // Simulate lighting (basic ambient + diffuse)
                half3 lightDir = normalize(float3(0.5, 0.5, -1.0));
                half3 ambient = half3(0.1, 0.1, 0.1);
                half3 diffuse = max(dot(normal, lightDir), 0.0) * half3(1.0, 1.0, 1.0);

                // Final color with roughness influencing the glossiness
                half3 color = albedo.rgb * (ambient + diffuse * (1.0 - roughness));

                // Apply displacement to vertex position
                i.vertex.xyz += normal * displacement;

                return half4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

