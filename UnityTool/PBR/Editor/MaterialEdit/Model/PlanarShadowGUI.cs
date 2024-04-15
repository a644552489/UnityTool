using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;
using UnityEngine.Scripting.APIUpdating;

namespace Custom
{
    public class PlanarShadowGUI
    {
        public struct Properties
        {
            // Surface Option Props
            public MaterialProperty _3DMax;

            // Surface Input Props
            public MaterialProperty HeightOffset;
            public MaterialProperty ShadowColor;
            public MaterialProperty ShadowFalloff;
            public MaterialProperty ShadowCutoff;

            public MaterialProperty DisablePlanarShadowPass;

            public Properties(MaterialProperty[] properties)
            {
                _3DMax = BaseShaderGUI.FindProperty("_3DMax", properties, false);
                HeightOffset = BaseShaderGUI.FindProperty("_HeightOffset", properties, false);
                ShadowColor = BaseShaderGUI.FindProperty("_ShadowColor", properties, false);
                ShadowFalloff = BaseShaderGUI.FindProperty("_ShadowFalloff", properties, false);
                ShadowCutoff = BaseShaderGUI.FindProperty("_ShadowCutoff", properties, false);
                DisablePlanarShadowPass = BaseShaderGUI.FindProperty("_DisablePlanarShadowPass", properties, false);
            }
        }

        public static void Inputs(Properties properties, MaterialEditor materialEditor, Material material)
        {
            if (properties._3DMax == null) return;

            //materialEditor.PropertiesDefaultGUI(properties);

            materialEditor.ShaderProperty(properties._3DMax, "3DMax");
            materialEditor.ShaderProperty(properties.HeightOffset, "HeightOffset");
            materialEditor.ShaderProperty(properties.ShadowColor, "ShadowColor");
            materialEditor.ShaderProperty(properties.ShadowFalloff, "ShadowFalloff");
            materialEditor.ShaderProperty(properties.ShadowCutoff, "ShadowCutoff");

            if(properties.DisablePlanarShadowPass != null)
            materialEditor.ShaderProperty(properties.DisablePlanarShadowPass, "DisablePlanarShadowPass");
        }

        public static void SetMaterialKeywords(Material material)
        {
            if (material.HasProperty("_3DMax"))
            {
                CoreUtils.SetKeyword(material, "_3DMAX_ON", material.GetFloat("_3DMax") == 1.0f);
            }

            if (material.HasProperty("_DisablePlanarShadowPass"))
            {
                material.SetShaderPassEnabled("PlanarShadowPass", material.GetFloat("_DisablePlanarShadowPass") != 1.0f);
            }
        }
    }
}
