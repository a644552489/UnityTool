using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShaderUIEditor
{
    public class UnitDiffuseEditor : ShaderGUI
    {
        private string[] blendModekey = {"_BLENDMODE_DIFFUSE", "_BLENDMODE_TRANSPARENT"};
        private string[] blendModeName = {"Diffuse", "Transparent"};
        private int[] blendModeValues = {0, 1};

        private string[] ZTestModeName = {"Off", "NotEqual", "Always"};
        private int[] ZTestModeValues = {2, 5, 6};

        private string[] ZWriterName = {"ON", "OFF"};
        private int[] ZWriterValues = {1, 0};
        private string[] CullModeName => Enum.GetNames(typeof(UnityEngine.Rendering.CullMode));
        private int[] CullModeValues = {0, 1, 2};


        private MaterialEditor m_materialEditor;

        private static Dictionary<string, string> NameDic = new Dictionary<string, string>()
        {
            {"Blend_Mode", "模式"},
            {"Cull_Mode", "双面模式"},
            {"ZWriter_Mode", "深度"},
            {"ZTest_Mode", "Z模式"},
            {"Color", "主颜色"},
            {"ClipAlpha", "透明裁剪"},
            {"MianTex", "主贴图"}
        };


        private MaterialProperty BlendModeProperty;
        private MaterialProperty ZTestPreoperty;
        private MaterialProperty ZwriterPreoperty;
        private MaterialProperty CullModePreoperty;
        private MaterialProperty MainColorPreoperty;
        private MaterialProperty MainTexPreoperty;
        private MaterialProperty AlphaClipPreoperty;
        private MaterialProperty AlphaShadowClipPreoperty;

        private MaterialProperty NormalMapPreoperty;
        private MaterialProperty NormalScalePreoperty;

        private MaterialProperty MetallicMapPreoperty;
        private MaterialProperty MetallicPreoperty;
        private MaterialProperty OcclusionPreoperty;
        private MaterialProperty SmoothnessPreoperty;

        private MaterialProperty EmssionMapPreoperty;
        private MaterialProperty EmissionColorPreoperty;




        private MaterialProperty CubeMapPreoperty;
        private MaterialProperty CubeMapStrengthPreoperty;
        private MaterialProperty BakedGIColorPreoperty;




        public void GetProperty(MaterialProperty p)
        {
            GetProperty(p, "Blend_Mode", ref BlendModeProperty);
            GetProperty(p, "Cull_Mode", ref CullModePreoperty);
            GetProperty(p, "ZTest_Mode", ref ZTestPreoperty);
            GetProperty(p, "ZWriter_Mode", ref ZwriterPreoperty);
            GetProperty(p, "Color", ref MainColorPreoperty);
            GetProperty(p, "MianTex", ref MainTexPreoperty);
            GetProperty(p, "ClipAlpha", ref AlphaClipPreoperty);
            GetProperty(p, "NormalMap", ref NormalMapPreoperty);
            GetProperty(p, "NormalScale", ref NormalScalePreoperty);
            GetProperty(p, "MetallicAOGloss", ref MetallicMapPreoperty);
            GetProperty(p, "Metallic", ref MetallicPreoperty);
            GetProperty(p, "Occlusion", ref OcclusionPreoperty);
            GetProperty(p, "Smoothness", ref SmoothnessPreoperty);
            GetProperty(p, "EmissionColor", ref EmissionColorPreoperty);
            GetProperty(p, "EmssionMap", ref EmssionMapPreoperty);
            GetProperty(p, "CubeMap", ref CubeMapPreoperty);
            GetProperty(p, "CubeMapStrength", ref CubeMapStrengthPreoperty);
            GetProperty(p, "BakedGIColor", ref BakedGIColorPreoperty);
            GetProperty(p, "ClipShadowAlpha", ref AlphaShadowClipPreoperty);
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            m_materialEditor = materialEditor;


            foreach (MaterialProperty property in properties)
            {
                GetProperty(property);
            }

            DrawGUI();

            m_materialEditor.RenderQueueField();
        }
        float blendMode=-1;
        void DrawGUI()
        {
            DrawEnum(BlendModeProperty, blendModeName, blendModeValues, blendModekey,(a)=>
            {
                switch (a)
                {
                    case 0:
                        foreach (var q in m_materialEditor.targets)
                        {
                            Material m = q as Material;
                            m.renderQueue = 2000;
                            m.SetOverrideTag("RenderType", "Geometry");
                            m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.One);
                            m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.Zero);
                        }
                        break;
                    case 1:
                        foreach (var q in m_materialEditor.targets)
                        {
                            Material m = q as Material;
                            m.renderQueue = 3000;
                            m.SetOverrideTag("RenderType", "Transparent");
                            m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                            m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        }
                        break;
                    case 2:
                        foreach (var q in m_materialEditor.targets)
                        {
                            Material m = q as Material;
                            m.renderQueue = 2450;
                            m.SetOverrideTag("RenderType", "AlphaTest");
                            m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                            m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        }
                        break;

                }
            });
            if (blendMode == -1)
            {
                switch (BlendModeProperty.floatValue)
                {
                    case 0:
                        foreach (var q in m_materialEditor.targets)
                        {
                            Material m = q as Material;
                            m.renderQueue = 2000;
                            m.SetOverrideTag("RenderType", "Geometry");
                            m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.One);
                            m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.Zero);
                        }
                        break;
                    case 1:
                        foreach (var q in m_materialEditor.targets)
                        {
                            Material m = q as Material;
                            m.renderQueue = 2800;
                            m.SetOverrideTag("RenderType", "Transparent");
                            m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                            m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        }
                        break;
                    case 2:
                        foreach (var q in m_materialEditor.targets)
                        {
                            Material m = q as Material;
                            m.renderQueue = 2450;
                            m.SetOverrideTag("RenderType", "AlphaTest");
                            m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                            m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        }
                        break;

                }
                blendMode = 1;
            }

            m_materialEditor.RangeProperty(AlphaClipPreoperty, "透明裁剪");
            m_materialEditor.RangeProperty(AlphaShadowClipPreoperty, "阴影裁剪");


            m_materialEditor.TexturePropertySingleLine(new GUIContent("主纹理"), MainTexPreoperty, MainColorPreoperty);
            DrawMetallicAoGloss();
            DrawNormalMap(NormalMapPreoperty,NormalScalePreoperty,"法线纹理");
            m_materialEditor.TexturePropertyWithHDRColor(new GUIContent("自发光纹理"), EmssionMapPreoperty, EmissionColorPreoperty,false);
            m_materialEditor.TextureScaleOffsetProperty(MainTexPreoperty);
            m_materialEditor.TexturePropertySingleLine(new GUIContent("自定义反射","反射贴图,数值：反射强度,颜色：背光颜色"), CubeMapPreoperty,CubeMapStrengthPreoperty,BakedGIColorPreoperty);
            DrawEnum(CullModePreoperty, CullModeName, CullModeValues, 70);
            DrawEnum(ZwriterPreoperty, ZWriterName, ZWriterValues, 70);
            DrawEnum(ZTestPreoperty, ZTestModeName, ZTestModeValues, 70);


        }

        private void DrawMetallicAoGloss()
        {
            m_materialEditor.TexturePropertySingleLine(new GUIContent("金属纹理","R:金属,G:AO,B:平滑度"),MetallicMapPreoperty , MetallicPreoperty);
            EditorGUI.indentLevel += 2;
            m_materialEditor.RangeProperty(OcclusionPreoperty, "AO");
            m_materialEditor.RangeProperty(SmoothnessPreoperty, "平滑度");
            EditorGUI.indentLevel -= 2;
        }

        /// <summary>
        /// 法线显示
        /// </summary>
        private void DrawNormalMap(MaterialProperty map, MaterialProperty mapScale, string Name)
        {
            m_materialEditor.TexturePropertySingleLine(new GUIContent(Name), map,
                map.textureValue != null ? mapScale : null);
            if (map.textureValue != null )
            {
                Texture normal = map.textureValue;
                TextureImporter textImporter = (TextureImporter) AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(normal));
                if (textImporter.textureType != TextureImporterType.NormalMap)
                {
                    if (m_materialEditor.HelpBoxWithButton(new GUIContent("当前不是法线贴图请转换成法线贴图"),
                        new GUIContent("转换")))
                    {
                        textImporter.textureType = TextureImporterType.NormalMap;
                        textImporter.SaveAndReimport();
                    }
                }
            }

        }


        private void DrawEnum(MaterialProperty property, string[] names, int[] values, string[] keywords,
            Action<int> ab = null)
        {
            if (property == null) return;
            EditorGUI.BeginChangeCheck();
            string propName = property.displayName;
            bool hasMixedValue = property.hasMixedValue;
            if (hasMixedValue) EditorGUI.showMixedValue = true;
            int value = (int) property.floatValue;
            value = EditorGUILayout.IntPopup(NameDic[propName], value, names, values);
            if (EditorGUI.EndChangeCheck())
            {
                property.floatValue = value;
                ab?.Invoke(value);
                EnableKeywordEnum(keywords, value);
            }

            if (hasMixedValue) EditorGUI.showMixedValue = false;
        }

        private void DrawEnum(MaterialProperty property, string[] names, int[] values, float width,
            Action<int> ab = null)
        {
            if (property == null) return;
            string propName = property.displayName;
            bool hasMixedValue = property.hasMixedValue;
            if (hasMixedValue) EditorGUI.showMixedValue = true;
            int value = (int) property.floatValue;
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(NameDic[propName]);
            value = EditorGUILayout.IntPopup(value, names, values, GUILayout.Width(width));
            EditorGUILayout.EndHorizontal();
            if (EditorGUI.EndChangeCheck())
            {
                property.floatValue = value;
                ab?.Invoke(value);
            }
        }

        private void EnableKeywordEnum(string[] keywords, int index)
        {
            for (int i = 0; i < keywords.Length; i++)
            {
                if (index == i)
                {
                    foreach (var t in m_materialEditor.targets)
                    {
                        Material m = t as Material;
                        m.EnableKeyword(keywords[i]);
                    }
                }
                else
                {
                    foreach (var t in m_materialEditor.targets)
                    {
                        Material m = t as Material;
                        m.DisableKeyword(keywords[i]);
                    }
                }
            }
        }

        private void EnableKeyword(string keywordName, bool value)
        {
            if (value)
            {
                foreach (var t in m_materialEditor.targets)
                {
                    Material m = t as Material;
                    m.EnableKeyword(keywordName);
                }
            }
            else
            {
                foreach (var t in m_materialEditor.targets)
                {
                    Material m = t as Material;
                    m.DisableKeyword(keywordName);
                }
            }
        }

        private void DrawProperty(MaterialProperty property)
        {
            string propName = property.displayName;
            switch (property.type)
            {
                case MaterialProperty.PropType.Color:
                    m_materialEditor.ColorProperty(property, NameDic[propName]);
                    break;
                case MaterialProperty.PropType.Float:
                    m_materialEditor.FloatProperty(property, NameDic[propName]);
                    break;
                case MaterialProperty.PropType.Range:
                    m_materialEditor.RangeProperty(property, NameDic[propName]);
                    break;
                case MaterialProperty.PropType.Texture:
                    //m_materialEditor.TextureProperty(property, NameDic[propName]);
                    m_materialEditor.TexturePropertySingleLine(new GUIContent(NameDic[propName]), property);
                    if (!property.flags.HasFlag((System.Enum) MaterialProperty.PropFlags.NoScaleOffset))
                    {
                        m_materialEditor.TextureScaleOffsetProperty(property);
                    }

                    break;
                case MaterialProperty.PropType.Vector:
                    m_materialEditor.VectorProperty(property, NameDic[propName]);
                    break;
            }
        }

        void SetProperty(MaterialProperty pro, string key, bool isbool = true)
        {
            pro.floatValue = 1;
            EnableKeyword(key, isbool);
        }

        void GetProperty(MaterialProperty self, string keyName, ref MaterialProperty p)
        {
            if (keyName == self.displayName)
            {
                p = self;
            }
        }
    }
}