using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;

namespace Custom
{
    public class ActorGUI
    {
        public static class Styles
        {
            public static GUIContent emissionPowerText = new GUIContent("Emission Power",
                   " ");

            public static GUIContent emissionIntensityText = new GUIContent("Emission Intensity",
                " ");

            public static GUIContent isEdgeLightText = new GUIContent("Is Edge Light",
                   " ");

            public static GUIContent edgePowerText = new GUIContent("Edge Power",
                " ");

            public static GUIContent edgeColorText = new GUIContent("Edge Color",
                " ");


            public static GUIContent deadDissolutionText = new GUIContent("Dead Dissolution",
                 " ");

            public static GUIContent dissolutionMapText = new GUIContent("Dissolution Map",
                 " ");

            public static GUIContent dissolutionMaskText = new GUIContent("Dissolution Mask",
                " ");

            public static GUIContent dissolutionOffsetText = new GUIContent("Dissolution Offset",
                   " ");

            public static GUIContent dissolutionHdrStrengthText = new GUIContent("Dissolution Hdr Strength",
                " ");

            public static GUIContent dissolutionColorText = new GUIContent("Dissolution Color",
                " ");

        }

        public struct ActorProperties
        {
            // Surface Input Props
            public MaterialProperty emissionPower;
            public MaterialProperty emissionIntensity;
            public MaterialProperty isEdgeLight;
            public MaterialProperty edgePower;
            public MaterialProperty edgeColor;

            public MaterialProperty deadDissolution;
            public MaterialProperty dissolutionMap;
            public MaterialProperty dissolutionMask;
            public MaterialProperty dissolutionOffset;
            public MaterialProperty dissolutionHdrStrength;
            public MaterialProperty dissolutionColor;

            public ActorProperties(MaterialProperty[] properties)
            {
                emissionPower = BaseShaderGUI.FindProperty("_EmissionPower", properties, false);
                emissionIntensity = BaseShaderGUI.FindProperty("_EmissionIntensity", properties, false);
                isEdgeLight = BaseShaderGUI.FindProperty("_IsEdgeLight", properties, false);
                edgePower = BaseShaderGUI.FindProperty("_EdgePower", properties, false);
                edgeColor = BaseShaderGUI.FindProperty("_EdgeColor", properties, false);

                deadDissolution = BaseShaderGUI.FindProperty("_DeadDissolution", properties, false);
                dissolutionMap = BaseShaderGUI.FindProperty("_DissolutionMap", properties, false);
                dissolutionMask = BaseShaderGUI.FindProperty("_DissolutionMask", properties, false);
                dissolutionOffset = BaseShaderGUI.FindProperty("_DissolutionOffset", properties, false);
                dissolutionHdrStrength = BaseShaderGUI.FindProperty("_DissolutionHdrStrength", properties, false);
                dissolutionColor = BaseShaderGUI.FindProperty("_DissolutionColor", properties, false);
            }
        }

        public static void DoEmissionAdditionArea(ActorProperties properties, MaterialEditor materialEditor, Material material)
        {
            if (properties.emissionIntensity != null && properties.emissionPower != null)
            {
                EditorGUI.BeginChangeCheck();
                var emissionPower = properties.emissionPower.floatValue;
                var emissionIntensity = properties.emissionIntensity.floatValue;
                emissionPower = EditorGUILayout.Slider(Styles.emissionPowerText, emissionPower, 0f, 3f);
                emissionIntensity = EditorGUILayout.Slider(Styles.emissionIntensityText, emissionIntensity, 0f, 5f);
                if (EditorGUI.EndChangeCheck())
                {
                    properties.emissionPower.floatValue = emissionPower;
                    properties.emissionIntensity.floatValue = emissionIntensity;
                }
            }
        }

        public static void DrawEdgeLightProperties(ActorProperties properties, MaterialEditor materialEditor, Material material)
        {
            if (properties.isEdgeLight != null)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = properties.isEdgeLight.hasMixedValue;
                var isOn = EditorGUILayout.Toggle(Styles.isEdgeLightText, properties.isEdgeLight.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                    properties.isEdgeLight.floatValue = isOn ? 1.0f : 0.0f;
                EditorGUI.showMixedValue = false;

                EditorGUI.BeginDisabledGroup(!isOn);
                {
                    materialEditor.ShaderProperty(properties.edgePower, Styles.edgePowerText);
                    materialEditor.ShaderProperty(properties.edgeColor, Styles.edgeColorText);
                }
                EditorGUI.EndDisabledGroup();
            }
        }

        public static void DrawDeadDissolution(ActorProperties properties, MaterialEditor materialEditor, Material material)
        {
            if (properties.deadDissolution != null)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = properties.deadDissolution.hasMixedValue;
                var isOn = EditorGUILayout.Toggle(Styles.deadDissolutionText, properties.deadDissolution.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                    properties.deadDissolution.floatValue = isOn ? 1.0f : 0.0f;
                EditorGUI.showMixedValue = false;

                EditorGUI.BeginDisabledGroup(!isOn);
                {
                    materialEditor.ShaderProperty(properties.dissolutionMap, Styles.dissolutionMapText);
                    materialEditor.ShaderProperty(properties.dissolutionMask, Styles.dissolutionMaskText);
                    materialEditor.ShaderProperty(properties.dissolutionOffset, Styles.dissolutionOffsetText);
                    materialEditor.ShaderProperty(properties.dissolutionHdrStrength, Styles.dissolutionHdrStrengthText);
                    materialEditor.ShaderProperty(properties.dissolutionColor, Styles.dissolutionColorText);
                }
                EditorGUI.EndDisabledGroup();
            }
        }

        public static void SetMaterialKeywords(Material material)
        {
            if (material.HasProperty("_DeadDissolution"))
            {
                CoreUtils.SetKeyword(material, "_DEAD_DISSOLUTION_ON", material.GetFloat("_DeadDissolution") == 1.0f);
            }
        }
    }
}
