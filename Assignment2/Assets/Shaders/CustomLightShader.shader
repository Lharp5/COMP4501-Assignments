// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/CumstomLightShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				half3 worldNormal : TEXCOORD1;
				half3 worldView: TEXCOORD2;
				
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			half _Glossiness;
			half _Metallic;
			
			v2f vert (appdata v)
			{
				v2f o;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				const float PI = 3.14159;
				half specular, geo;
				half diffuse;
				half dist;
				half fvalue;
				half3 lightDir = _WorldSpaceLightPos0.xyz;

				//for point light
				if (_WorldSpaceLightPos0.z == 1) {
					lightDir = normalize(i.vertex.xyz - _WorldSpaceLightPos0.xyz);
				}

				half3 halfVector = normalize(lightDir + i.worldView);

				//fresnel reflection
				specular = max(_Metallic + (1 - _Metallic)* pow(saturate(1 - max(dot(i.worldNormal, halfVector), 0.0)), 5), 0.0);

				//Cook Torrance Geometry Function
				geo = min(1, (2 * dot(i.worldNormal, halfVector) * dot(i.worldNormal, i.worldView)) / dot(i.worldView, halfVector));
				geo = min(geo, (2 * dot(i.worldNormal, halfVector)*dot(i.worldNormal, lightDir)) / dot(i.worldView, halfVector));

				//GGX normal distribution. Math taken from: https://gist.github.com/xDavidLeon/38b392700fbec56162ba
				half a = _Glossiness * _Glossiness;
				half a2 = a * a;
				half d = dot(i.worldNormal, halfVector) * dot(i.worldNormal, halfVector)* (a2 - 1.f) + 1.f;
				dist = a2 / (UNITY_PI * d * d);

				//lambertian BRDF
				diffuse = (1 - specular * (_Metallic / PI)); //todo fix the 0.1, specular should use metal instead of albedo?

				fvalue = diffuse + ((specular * geo * dist) / (4 * dot(i.worldNormal, lightDir) * dot(i.worldNormal, i.worldView)));

				

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;

				// ambient, diffuse, physics specular
				col = col*0.1 + dot(i.worldNormal, lightDir) * col  * _LightColor0 + fvalue * _LightColor0 * col;
				return col;
			}
			ENDCG
		}
	}
}
