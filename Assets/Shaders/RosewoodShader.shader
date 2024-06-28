Shader "Custom/RosewoodShader"
{
    Properties
    {
        _MainTex ("Diffuse", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
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
            float4 _MainTex_ST;

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
                half4 roughnessTex = tex2D(_RoughnessMap, i.uv);

                // Convert the normal map from [0, 1] range to [-1, 1] range
                half3 normal = normalize(normalTex.rgb * 2.0 - 1.0);

                // Apply the normal map to the world normal
                normal = normalize(normal);

                // Calculate roughness factor
                half roughness = roughnessTex.r;

                // Simulate lighting (basic ambient + diffuse)
                half3 lightDir = normalize(float3(0.5, 0.5, -1.0));
                half3 ambient = half3(0.1, 0.1, 0.1);
                half3 diffuse = max(dot(normal, lightDir), 0.0) * half3(1.0, 1.0, 1.0);

                // Final color with roughness influencing the glossiness
                half3 color = albedo.rgb * (ambient + diffuse * (1.0 - roughness));

                return half4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
