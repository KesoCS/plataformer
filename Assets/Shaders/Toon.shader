Shader "Custom/ToonShader2D_NoTexture"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1, 1, 1, 1) // Color principal del sprite
        _FillColor ("Fill Color", Color) = (1, 1, 1, 1) // Color del interior del sprite
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1) // Color del contorno
        _OutlineThickness ("Outline Thickness", Range(0.0, 0.1)) = 0.05 // Grosor del contorno
        _OutlineAlpha ("Outline Alpha", Range(0.0, 1.0)) = 1.0 // Transparencia del contorno
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        LOD 100

        Pass
        {
            Name "OUTLINE"
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite On
            ColorMask RGB
            Offset -1, -1

            CGPROGRAM
            #pragma vertex vertOutline
            #pragma fragment fragOutline
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 texcoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            fixed4 _OutlineColor;
            fixed4 _FillColor;
            float _OutlineThickness;
            float _OutlineAlpha;

            v2f vertOutline (appdata_t v)
            {
                v2f o;
                float4 pos = v.vertex;

                // Offset the position to create the outline effect
                pos.xy += _OutlineThickness * _OutlineAlpha * normalize(pos.xy);

                o.vertex = UnityObjectToClipPos(pos);
                o.texcoord = v.texcoord;
                o.color = _OutlineColor;
                return o;
            }

            fixed4 fragOutline (v2f i) : SV_Target
            {
                // Return the outline color with the specified alpha
                return _OutlineColor * _OutlineAlpha;
            }
            ENDCG
        }

        Pass
        {
            Name "FILL"
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 texcoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            fixed4 _FillColor;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                o.color = _FillColor;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
    FallBack "Sprites/Default"
}

