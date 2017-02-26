Shader "Custom/NewSurfaceShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf CustomStandard fullforwardshadows

		half4 LightingCustomStandard(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {

			half3 halfVector = normalize(lightDir + viewDir);
			half specular, geo;
			half diffuse;
			half dist;
			half NdotL = dot(s.Normal, halfVector);
			half4 c;
			
			//fresnel reflection
			//specular = max(_Metallic +(1 - _Metallic)* pow(saturate(1 - max(dot(s.Normal, halfVector), 0.0)), 5), 0.0);

			//Cook Torrance Geometry Function
//			geo = min(1, (2 * dot(s.Normal, halfVector) * dot(s.Normal, viewDir)) / dot(viewDir, halfVector));
//			geo = min(geo, (2 * dot(s.Normal, halfVector)*dot(s.Normal, lightDir)) / dot(viewDir, halfVector));

			//GGX normal distribution. how do you get micros without this?
			dist = GGXTerm(BlinnTerm(s.Normal, halfVector), s.Gloss);

			//lambertian BRDF
			//diffuse = (1 - specular * (_Metallic / UNITY_PI)) *atten * 0.1; //todo fix the 0.1, specular should use metal instead of albedo?

			//c.rgb = s.Albedo * diffuse + ((specular * geo * dist) / (4 * dot(s.Normal, lightDir) * dot(s.Normal, viewDir)));
			c.rgb = s.Albedo;
			c.a - s.Alpha;
			return c;
		}
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 viewDir;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			//o.Metallic = _Metallic;
			o.Gloss= _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
