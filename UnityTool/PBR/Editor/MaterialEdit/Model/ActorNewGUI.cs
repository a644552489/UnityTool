using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;

namespace Custom
{
    public class ActorNewGUI
    {
        public static class Styles
        {
            public static GUIContent emissionPowerText =
               new GUIContent("Emission Power", " ");
            public static GUIContent emissionIntensityText =
                new GUIContent("Emission Intensity", " ");

            public static GUIContent isEdgeLightText =
                new GUIContent("Is Edge Light", " ");
            public static GUIContent edgePowerText =
                new GUIContent("Edge Power", " ");
            public static GUIContent edgeColorText =
                new GUIContent("Edge Color", " ");

            public static GUIContent MSA_MapText =
                new GUIContent("M_S_A", " ");

            public static GUIContent Wave_MapText =
                new GUIContent("Wave Map", " ");
            public static GUIContent waveSpeedText =
                new GUIContent("Wave Speed", " ");
            public static GUIContent breatheSpeedText =
                new GUIContent("Breathe Speed", " ");

            public static GUIContent metaStrengthText =
                new GUIContent("Meta Strength", " ");
            public static GUIContent smoothnessStrengthText =
                new GUIContent("Smoothness Strength", " ");
            public static GUIContent aoStrengthText =
                new GUIContent("AO Strength", " ");

            public static GUIContent isCustomReflectText =
                new GUIContent("Is Custom Reflect", " ");
            public static GUIContent reflectCubeText =
                new GUIContent("Reflect Cube", " ");
            public static GUIContent reflectCompareValueText =
                new GUIContent("Reflect Compare Value", " ");
            public static GUIContent reflectInitialValueText =
                new GUIContent("Reflect Initial Value", " ");
            public static GUIContent reflectStrengthText =
                new GUIContent("Reflect Strength", " ");

            public static GUIContent laserControlText =
                new GUIContent("Laser Control", "");
            public static GUIContent bubbleMapText =
                new GUIContent("BubbleMap", "");
            
        }

        public struct ActorProperties
        {
            // Surface Input Props
            public MaterialProperty emissionPower;
            public MaterialProperty emissionIntensity;
            public MaterialProperty isEdgeLight;
            public MaterialProperty edgePower;
            public MaterialProperty edgeColor;

            public MaterialProperty msaMap;

            public MaterialProperty waveMap;
            public MaterialProperty waveSpeed;
            public MaterialProperty breatheSpeed;

            public MaterialProperty metaStrength;
            public MaterialProperty smoothnessStrength;
            public MaterialProperty aoStrength;

            public MaterialProperty isCustomReflect;
            public MaterialProperty reflectCube;
            public MaterialProperty reflectCompareValue;
            public MaterialProperty reflectInitialValue;
            public MaterialProperty reflectStrength;


            public MaterialProperty _isLaserControl;
            public MaterialProperty _LaserController;
            public MaterialProperty _LaserColor1;
            public MaterialProperty _LaserColor2;
            public MaterialProperty _Tile;
            public MaterialProperty _BubbleMap;
            public MaterialProperty _MaskRGB;

            public MaterialProperty _ZWrite;

            public ActorProperties(MaterialProperty[] properties)
            {
                emissionPower = BaseShaderGUI.FindProperty("_EmissionPower", properties, false);
                emissionIntensity = BaseShaderGUI.FindProperty("_EmissionIntensity", properties, false);
                isEdgeLight = BaseShaderGUI.FindProperty("_IsEdgeLight", properties, false);
                edgePower = BaseShaderGUI.FindProperty("_EdgePower", properties, false);
                edgeColor = BaseShaderGUI.FindProperty("_EdgeColor", properties, false);

                msaMap = BaseShaderGUI.FindProperty("_MSAMap", properties, false);
                //Add WaveMap
                waveMap = BaseShaderGUI.FindProperty("_WaveMap", properties, false);
                waveSpeed = BaseShaderGUI.FindProperty("_WaveSpeed", properties, false);
                breatheSpeed = BaseShaderGUI.FindProperty("_BreatheSpeed", properties, false);

                metaStrength = BaseShaderGUI.FindProperty("_MetaStrength", properties, false);
                smoothnessStrength = BaseShaderGUI.FindProperty("_SmoothnessStrength", properties, false);
                aoStrength = BaseShaderGUI.FindProperty("_AOStrength", properties, false);

                isCustomReflect = BaseShaderGUI.FindProperty("_IsCustomReflect", properties, false);
                reflectCube = BaseShaderGUI.FindProperty("_ReflectCube", properties, false);
                reflectCompareValue = BaseShaderGUI.FindProperty("_ReflectCompareValue", properties, false);
                reflectInitialValue = BaseShaderGUI.FindProperty("_ReflectInitialValue", properties, false);
                reflectStrength = BaseShaderGUI.FindProperty("_ReflectStrength", properties, false);

                _LaserController = BaseShaderGUI.FindProperty("_LaserController", properties, false);
                _LaserColor1 = BaseShaderGUI.FindProperty("_LaserColor1", properties, false);
                _LaserColor2 = BaseShaderGUI.FindProperty("_LaserColor2", properties, false);
                _Tile = BaseShaderGUI.FindProperty("_Tile", properties, false);
                _isLaserControl = BaseShaderGUI.FindProperty("_LaserControl", properties, false);
                _BubbleMap = BaseShaderGUI.FindProperty("_BubbleMap", properties, false);
                _MaskRGB = BaseShaderGUI.FindProperty("_MaskRGB", properties, false);
                _ZWrite = BaseShaderGUI.FindProperty("_ZWrite", properties, false);
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


                EditorGUI.indentLevel++;
                EditorGUI.BeginDisabledGroup(!isOn);
                {
                    materialEditor.ShaderProperty(properties.edgePower, Styles.edgePowerText);
                    materialEditor.ShaderProperty(properties.edgeColor, Styles.edgeColorText);
                }
                EditorGUI.EndDisabledGroup();
                EditorGUI.indentLevel--;
            }
        }

        public static void DrawMSAProperties(ActorProperties properties, MaterialEditor materialEditor, Material material)
        {
            materialEditor.TexturePropertySingleLine(Styles.MSA_MapText, properties.msaMap);

            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(properties.metaStrength, Styles.metaStrengthText);
            materialEditor.ShaderProperty(properties.smoothnessStrength, Styles.smoothnessStrengthText);
            materialEditor.ShaderProperty(properties.aoStrength, Styles.aoStrengthText);
            EditorGUI.indentLevel--;
        }

        public static void DrawWaveProperties(ActorProperties properties, MaterialEditor materialEditor, Material material)
        {
            materialEditor.TexturePropertySingleLine(Styles.Wave_MapText, properties.waveMap);
            materialEditor.ShaderProperty(properties.waveSpeed, Styles.waveSpeedText);
            materialEditor.ShaderProperty(properties.breatheSpeed, Styles.breatheSpeedText);
        }

        public static void DrawReflectProperties(ActorProperties properties, MaterialEditor materialEditor, Material material)
        {
            if (properties.isCustomReflect != null)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = properties.isCustomReflect.hasMixedValue;
                var isOn = EditorGUILayout.Toggle(Styles.isCustomReflectText, properties.isCustomReflect.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                    properties.isCustomReflect.floatValue = isOn ? 1.0f : 0.0f;
                EditorGUI.showMixedValue = false;


                EditorGUI.indentLevel++;
                EditorGUI.BeginDisabledGroup(!isOn);
                {
                    materialEditor.TexturePropertySingleLine(Styles.reflectCubeText, properties.reflectCube);
                    materialEditor.ShaderProperty(properties.reflectCompareValue, Styles.reflectCompareValueText);
                    materialEditor.ShaderProperty(properties.reflectInitialValue, Styles.reflectInitialValueText);
                    materialEditor.ShaderProperty(properties.reflectStrength, Styles.reflectStrengthText);
                }
                EditorGUI.EndDisabledGroup();
                EditorGUI.indentLevel--;
            }

            //EditorGUI.indentLevel++;
            //materialEditor.TexturePropertySingleLine(Styles.reflectCubeText, properties.reflectCube);
            //materialEditor.ShaderProperty(properties.reflectCompareValue, Styles.reflectCompareValueText);
            //materialEditor.ShaderProperty(properties.reflectInitialValue, Styles.reflectInitialValueText);
            //materialEditor.ShaderProperty(properties.reflectStrength, Styles.reflectStrengthText);
            //EditorGUI.indentLevel--;
        }
        public static void DrawLaserController(ActorProperties properties , MaterialEditor materialEditor , Material mat)
        {
            if (properties._isLaserControl != null)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = properties._isLaserControl.hasMixedValue;
                bool isON=  EditorGUILayout.Toggle(   Styles.laserControlText ,properties._isLaserControl.floatValue == 1.0f);
             
                    
                    if (EditorGUI.EndChangeCheck())
                        properties._isLaserControl.floatValue = isON ? 1.0f : 0.0f;
                    EditorGUI.showMixedValue = false;
                CoreUtils.SetKeyword(mat, "_LASERCONTROLLER_ON", isON);
                if (isON)
                {

               
                    EditorGUI.indentLevel++;
                    materialEditor.TexturePropertySingleLine(Styles.bubbleMapText, properties._BubbleMap);
                    materialEditor.TextureScaleOffsetProperty(properties._BubbleMap);
                    materialEditor.ShaderProperty(properties._MaskRGB, nameof(properties._MaskRGB));
                    EditorGUILayout.Space(20);
                    materialEditor.ShaderProperty(properties._LaserController, nameof(properties._LaserController));
                    materialEditor.ShaderProperty(properties._LaserColor1, nameof(properties._LaserColor1));
                    materialEditor.ShaderProperty(properties._LaserColor2, nameof(properties._LaserColor2));
                    materialEditor.ShaderProperty(properties._Tile, nameof(properties._Tile));

                    EditorGUI.indentLevel--;
                }
      
              
            }
        }

        public static void SetMaterialKeywords(Material material)
        {
            if (material.HasProperty("_IsEdgeLight"))
                CoreUtils.SetKeyword(material, "_EDGE_LIGHT_ON", material.GetFloat("_IsEdgeLight") == 1.0f);

            if (material.HasProperty("_WaveMap"))
            {
                if (material.GetTexture("_WaveMap") != null)
                {
                    CoreUtils.SetKeyword(material, "_EMISSION_DYNAMIC", true);
                }
            }
            //CoreUtils.SetKeyword(material, "_CUSTOM_REFLECT_ON", material.GetFloat("_IsCustomReflect") == 1.0f);
        }


    }
}
