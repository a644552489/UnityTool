using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;

namespace Custom
{
    public class ActorSkinGUI
    {
        public static class Styles
        {
            public static GUIContent _3SText =
                new GUIContent("S_S_S");
            public static GUIContent _3SFrontMaskText =
               new GUIContent("Front Mask");
            public static GUIContent _3SBackMaskText =
                new GUIContent("Back Mask");
            public static GUIContent _3SStrengthText =
                new GUIContent("Strength");
            public static GUIContent _3SRampMapText =
                new GUIContent("Ramp Map");

            public static GUIContent detailNormalMapText =
                new GUIContent("Detail Normal Map");
            public static GUIContent detailNormalStrengthText =
                new GUIContent("Detail Normal Strength");
        }

        public struct ActorSkinProperties
        {
            // Surface Input Props
            public MaterialProperty _3SFrontMask;
            public MaterialProperty _3SBackMask;
            public MaterialProperty _3SColor;
            public MaterialProperty _3SStrength;
            public MaterialProperty _3SRampMap;

            public MaterialProperty _DetailNormalMapScale;
            public MaterialProperty _DetailNormalMap;

            public ActorSkinProperties(MaterialProperty[] properties)
            {
                _3SFrontMask = BaseShaderGUI.FindProperty("_3SFrontMask", properties, false);
                _3SBackMask = BaseShaderGUI.FindProperty("_3SBackMask", properties, false);
                _3SColor = BaseShaderGUI.FindProperty("_3SColor", properties, false);
                _3SStrength = BaseShaderGUI.FindProperty("_3SStrength", properties, false);
                _3SRampMap = BaseShaderGUI.FindProperty("_3SRampMap", properties, false);

                _DetailNormalMapScale = BaseShaderGUI.FindProperty("_DetailNormalMapScale", properties, false);
                _DetailNormalMap = BaseShaderGUI.FindProperty("_DetailNormalMap", properties, false);
            }
        }

        public static void Draw3SArea(ActorSkinProperties properties, MaterialEditor materialEditor, Material material)
        {
            //EditorGUILayout.LabelField("S_S_S");
            materialEditor.ShaderProperty(properties._3SColor, Styles._3SText);

            EditorGUI.indentLevel++;
            materialEditor.TexturePropertySingleLine(Styles._3SRampMapText, properties._3SRampMap);
            materialEditor.ShaderProperty(properties._3SFrontMask, Styles._3SFrontMaskText);
            materialEditor.ShaderProperty(properties._3SBackMask, Styles._3SBackMaskText);
            materialEditor.ShaderProperty(properties._3SStrength, Styles._3SStrengthText);
            EditorGUI.indentLevel--;
        }

        public static void DrawDetailNormalArea(ActorSkinProperties properties, MaterialEditor materialEditor, Material material)
        {
            materialEditor.TexturePropertySingleLine(Styles.detailNormalMapText, properties._DetailNormalMap, properties._DetailNormalMapScale);
        }

        public static void SetMaterialKeywords(Material material)
        {
            
        }

    }
}
