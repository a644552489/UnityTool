using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;

namespace Custom
{
    public class ActorHairGUI
    {
        public static class Styles
        {
            public static GUIContent ShiftMapText =
             new GUIContent("Shift Map");
            public static GUIContent primaryColorText =
                new GUIContent("Primary Color");
            public static GUIContent primaryGlossText =
               new GUIContent("Primary Range");
            public static GUIContent primaryShiftText =
                new GUIContent("Primary Pos");
            public static GUIContent secondaryColorText =
                  new GUIContent("Secondary Color");
            public static GUIContent secondaryGlossText =
               new GUIContent("Secondary Range");
            public static GUIContent secondaryShiftText =
                new GUIContent("Secondary Pos");

            public static GUIContent testAlphaStrengthText =
                new GUIContent("AlphaTest Alpha Strength");
            public static GUIContent blenderAlphaStrengthText =
                new GUIContent("AlphaBlender Alpha Strength");

            public static GUIContent fresnelPowText =
                new GUIContent("Fresnel Pow");
        }

        public struct ActorHairProperties
        {
            // Surface Input Props
            public MaterialProperty _ShiftMap;
            public MaterialProperty _PrimaryColor;
            public MaterialProperty _PrimaryGloss;
            public MaterialProperty _PrimaryShift;
            public MaterialProperty _SecondaryColor;
            public MaterialProperty _SecondaryGloss;
            public MaterialProperty _SecondaryShift;

            public MaterialProperty _TestAlphaStrength;
            public MaterialProperty _BlenderAlphaStrength;

            public MaterialProperty _FresnelPow;

            public ActorHairProperties(MaterialProperty[] properties)
            {
                _ShiftMap = BaseShaderGUI.FindProperty("_ShiftMap", properties, false);
                _PrimaryColor = BaseShaderGUI.FindProperty("_PrimaryColor", properties, false);
                _PrimaryGloss = BaseShaderGUI.FindProperty("_PrimaryGloss", properties, false);
                _PrimaryShift = BaseShaderGUI.FindProperty("_PrimaryShift", properties, false);
                _SecondaryColor = BaseShaderGUI.FindProperty("_SecondaryColor", properties, false);
                _SecondaryGloss = BaseShaderGUI.FindProperty("_SecondaryGloss", properties, false);
                _SecondaryShift = BaseShaderGUI.FindProperty("_SecondaryShift", properties, false);
                _TestAlphaStrength = BaseShaderGUI.FindProperty("_TestAlphaStrength", properties, false);
                _BlenderAlphaStrength = BaseShaderGUI.FindProperty("_BlenderAlphaStrength", properties, false);
                _FresnelPow = BaseShaderGUI.FindProperty("_FresnelPow", properties, false);
            }
        }

        public static void DrawHairArea(ActorHairProperties properties, MaterialEditor materialEditor, Material material)
        {
            EditorGUILayout.LabelField("Hair");
            //materialEditor.ShaderProperty(properties._3SColor, Styles._3SText);

            EditorGUI.indentLevel++;
            materialEditor.TexturePropertySingleLine(Styles.ShiftMapText, properties._ShiftMap);
            materialEditor.ShaderProperty(properties._PrimaryColor, Styles.primaryColorText);
            materialEditor.ShaderProperty(properties._PrimaryGloss, Styles.primaryGlossText);
            materialEditor.ShaderProperty(properties._PrimaryShift, Styles.primaryShiftText);
            materialEditor.ShaderProperty(properties._SecondaryColor, Styles.secondaryColorText);
            materialEditor.ShaderProperty(properties._SecondaryGloss, Styles.secondaryGlossText);
            materialEditor.ShaderProperty(properties._SecondaryShift, Styles.secondaryShiftText);

            materialEditor.ShaderProperty(properties._TestAlphaStrength, Styles.testAlphaStrengthText);
            materialEditor.ShaderProperty(properties._BlenderAlphaStrength, Styles.blenderAlphaStrengthText);

            materialEditor.ShaderProperty(properties._FresnelPow, Styles.fresnelPowText);
            EditorGUI.indentLevel--;
        }


        public static void SetMaterialKeywords(Material material)
        {
            
        }

    }
}
