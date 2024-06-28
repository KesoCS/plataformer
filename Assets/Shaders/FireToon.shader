Shader "Custom/FlameBorderShader"
{
    Properties
    {
        _BorderColor ("Border Color", Color) = (0,0,0,1)
        _FlameColor ("Flame Color", Color) = (1,0.5,0,1)
        _FlameSpeed ("Flame Speed", Range(0.1, 10)) = 1
        _FlameFrequency1 ("Flame Frequency 1", Range(1, 10)) = 1.5
        _FlameAmplitude1 ("Flame Amplitude 1", Range(0, 2)) = 2
        _FlameFrequency2 ("Flame Frequency 2", Range(1, 10)) = 4
        _FlameAmplitude2 ("Flame Amplitude 2", Range(0, 2)) = 1.5
        _FlameFrequency3 ("Flame Frequency 3", Range(1, 10)) = 8
        _FlameAmplitude3 ("Flame Amplitude 3", Range(0, 2)) = 1
        _BorderWidth ("Border Width", Range(0, 0.1)) = 0.01
        _DistortionStrength ("Distortion Strength", Range(0, 0.5)) = 0.1
        _DistortionSpeed ("Distortion Speed", Range(0.1, 10)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _BorderColor;
            float4 _FlameColor;
            float _FlameSpeed;
            float _FlameFrequency1;
            float _FlameAmplitude1;
            float _FlameFrequency2;
            float _FlameAmplitude2;
            float _FlameFrequency3;
            float _FlameAmplitude3;
            float _BorderWidth;
            float _DistortionStrength;
            float _DistortionSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time.y * _FlameSpeed;
                float flame1 = sin(i.uv.y * _FlameFrequency1 + time) * 0.5 + 0.5;
                float flame2 = sin(i.uv.y * _FlameFrequency2 + time) * 0.5 + 0.5;
                float flame3 = sin(i.uv.y * _FlameFrequency3 + time) * 0.5 + 0.5;
                float flame = max(max(flame1 * _FlameAmplitude1, flame2 * _FlameAmplitude2), flame3 * _FlameAmplitude3);
                float noise = sin(i.uv.x * _DistortionSpeed + time) * sin(i.uv.y * _DistortionSpeed + time) * _DistortionStrength;
                float distortedFlame = clamp(flame + noise, 0.0, 1.0);
                float border = step(_BorderWidth, fwidth(i.uv));
                float4 baseColor = _FlameColor * distortedFlame;
                float4 borderColor = _BorderColor * border;
                return lerp(baseColor, borderColor, border);
            }
            ENDCG
        }
    }
}
