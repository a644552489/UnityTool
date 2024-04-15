using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;
using UnityEditor;

namespace Custom
{
    public abstract class BaseShaderGUI : UnityEditor.BaseShaderGUI
    {
        #region EnumsAndClasses

        protected class Styles : UnityEditor.BaseShaderGUI.Styles
        {
            public static readonly GUIContent disableDepthOnlyPassText = new GUIContent("Disable Depth Only",
                "");

            public static readonly GUIContent disableShadowCasterPassText = new GUIContent("Disable Shadow Caster",
                "");

            public static readonly GUIContent vertexMoveText = new GUIContent("Open Vertex Move",
                "");

            public static readonly GUIContent vertexMoveDistText = new GUIContent("Vertex Move Dist",
                "");

            public static readonly GUIContent vertexMoveSpeedText = new GUIContent("Vertex Move Speed",
                "");

            public static readonly GUIContent vertexMoveSpeedOffsetText = new GUIContent("Vertex Move Speed Offset",
                "");
        }

        #endregion

        #region Variables

        protected MaterialProperty disableDepthOnlyPassProp { get; set; }
        protected MaterialProperty disableShadowCasterPassProp { get; set; }

        protected MaterialProperty vertexMoveProp { get; set; }
        protected MaterialProperty vertexMoveDistProp { get; set; }
        protected MaterialProperty vertexMoveSpeedProp { get; set; }
        protected MaterialProperty vertexMoveSpeedOffsetProp { get; set; }
        #endregion

        ////////////////////////////////////
        // General Functions              //
        ////////////////////////////////////
        #region GeneralFunctions

        //public abstract void MaterialChanged(Material material);

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            disableDepthOnlyPassProp = FindProperty("_DisableDepthOnly", properties, false);
            disableShadowCasterPassProp = FindProperty("_DisableShadowCaster", properties, false);

            vertexMoveProp = FindProperty("_VertexMove", properties, false);
            vertexMoveDistProp = FindProperty("_VertexMoveDist", properties, false);
            vertexMoveSpeedProp = FindProperty("_VertexMoveSpeed", properties, false);
            vertexMoveSpeedOffsetProp = FindProperty("_VertexMoveSpeedOffset", properties, false);
        }

        #endregion
        ////////////////////////////////////
        // Drawing Functions              //
        ////////////////////////////////////
        #region DrawingFunctions

        public override void DrawSurfaceOptions(Material material)
        {
            base.DrawSurfaceOptions(material);

            if (disableShadowCasterPassProp != null)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = disableShadowCasterPassProp.hasMixedValue;
                var disableShadowCasterPass =
                    EditorGUILayout.Toggle(Styles.disableShadowCasterPassText, disableShadowCasterPassProp.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                    disableShadowCasterPassProp.floatValue = disableShadowCasterPass ? 1.0f : 0.0f;
                EditorGUI.showMixedValue = false;
            }

            if (disableDepthOnlyPassProp != null)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = disableDepthOnlyPassProp.hasMixedValue;
                var disableDepthOnlyPass =
                    EditorGUILayout.Toggle(Styles.disableDepthOnlyPassText, disableDepthOnlyPassProp.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                    disableDepthOnlyPassProp.floatValue = disableDepthOnlyPass ? 1.0f : 0.0f;
                EditorGUI.showMixedValue = false;
            }
        }

        public void DrawVertexMoveProperties(Material material)
        {
            if (vertexMoveProp != null)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = vertexMoveProp.hasMixedValue;
                var isVertexMoveOn = EditorGUILayout.Toggle(Styles.vertexMoveText, vertexMoveProp.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                    vertexMoveProp.floatValue = isVertexMoveOn ? 1.0f : 0.0f;
                EditorGUI.showMixedValue = false;

                EditorGUI.BeginDisabledGroup(!isVertexMoveOn);
                {
                    EditorGUI.BeginChangeCheck();
                    materialEditor.ShaderProperty(vertexMoveDistProp, Styles.vertexMoveDistText);
                    materialEditor.ShaderProperty(vertexMoveSpeedProp, Styles.vertexMoveSpeedText);
                    materialEditor.ShaderProperty(vertexMoveSpeedOffsetProp, Styles.vertexMoveSpeedOffsetText);
                    if (EditorGUI.EndChangeCheck())
                    {
                        MaterialChanged(material);
                    }
                }
                EditorGUI.EndDisabledGroup();
            }
        }

        #endregion
        ////////////////////////////////////
        // Material Data Functions        //
        ////////////////////////////////////
        #region MaterialDataFunctions

        public static new void SetMaterialKeywords(Material material, Action<Material> shadingModelFunc = null, Action<Material> shaderFunc = null)
        {
            // Clear all keywords for fresh start
            material.shaderKeywords = null;

            // Setup blending - consistent across all Universal RP shaders
            SetupMaterialBlendMode(material);

            // Receive Shadows
            if(material.HasProperty("_ReceiveShadows"))
                CoreUtils.SetKeyword(material, "_RECEIVE_SHADOWS_OFF", material.GetFloat("_ReceiveShadows") == 0.0f);

            // Emission
            if (material.HasProperty("_EmissionColor"))
                MaterialEditor.FixupEmissiveFlag(material);
            bool shouldEmissionBeEnabled =
                (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == 0;
            if (material.HasProperty("_EmissionEnabled") && !shouldEmissionBeEnabled)
                shouldEmissionBeEnabled = material.GetFloat("_EmissionEnabled") >= 0.5f;
            CoreUtils.SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);

            // Normal Map
            if (material.HasProperty("_BumpMap"))
                CoreUtils.SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));

            // Disable Shadow Caster
            if (material.HasProperty("_DisableShadowCaster"))
            {
                material.SetShaderPassEnabled("ShadowCaster", (int)material.GetFloat("_DisableShadowCaster") != 1);
            }

            // Disable Depth Pass
            if (material.HasProperty("_DisableDepthOnly")) {
                material.SetShaderPassEnabled("DepthOnly", (int)material.GetFloat("_DisableDepthOnly") != 1 );
            }

            // 顶点位移
            if (material.HasProperty("_VertexMove"))
            {
                CoreUtils.SetKeyword(material, "_VERTEX_MOVE_ON", material.GetFloat("_VertexMove") == 1.0f);
            }

            // Shader specific keyword functions
            shadingModelFunc?.Invoke(material);
            shaderFunc?.Invoke(material);
        }

        public static new void SetupMaterialBlendMode(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            bool alphaClip = false;
            if (material.HasProperty("_AlphaClip"))
                alphaClip = material.GetFloat("_AlphaClip") >= 0.5;

            if (alphaClip)
            {
                material.EnableKeyword("_ALPHATEST_ON");
            }
            else
            {
                material.DisableKeyword("_ALPHATEST_ON");
            }

            if (material.HasProperty("_Surface"))
            {
                SurfaceType surfaceType = (SurfaceType)material.GetFloat("_Surface");
                if (surfaceType == SurfaceType.Opaque)
                {
                    if (alphaClip)
                    {
                        material.renderQueue = (int)RenderQueue.AlphaTest;
                        material.SetOverrideTag("RenderType", "TransparentCutout");
                    }
                    else
                    {
                        material.renderQueue = (int)RenderQueue.Geometry;
                        material.SetOverrideTag("RenderType", "Opaque");
                    }

                    material.renderQueue += material.HasProperty("_QueueOffset") ? (int)material.GetFloat("_QueueOffset") : 0;
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");

                    if (material.HasProperty("_DisableShadowCaster"))
                    {
                        material.SetShaderPassEnabled("ShadowCaster", (int)material.GetFloat("_DisableShadowCaster") != 1);
                    }
                    else
                    {
                        material.SetShaderPassEnabled("ShadowCaster", true);
                    }
                }
                else
                {
                    BlendMode blendMode = (BlendMode)material.GetFloat("_Blend");

                    // Specific Transparent Mode Settings
                    switch (blendMode)
                    {
                        case BlendMode.Alpha:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                            break;
                        case BlendMode.Premultiply:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                            material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                            break;
                        case BlendMode.Additive:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                            break;
                        case BlendMode.Multiply:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                            material.EnableKeyword("_ALPHAMODULATE_ON");
                            break;
                    }

                    // General Transparent Material Settings
                    material.SetOverrideTag("RenderType", "Transparent");
                //    material.SetInt("_ZWrite", 0);
                    material.renderQueue = (int)RenderQueue.Transparent;
                    material.renderQueue += material.HasProperty("_QueueOffset") ? (int)material.GetFloat("_QueueOffset") : 0;
                    material.SetShaderPassEnabled("ShadowCaster", false);
                }
            }
        }

        #endregion

    }
}
