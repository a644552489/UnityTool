
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace CustomShader.Editor
{
    
    //自定义效果-单行显示图片
    internal class SingleLineDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            editor.TexturePropertySingleLine(label, prop);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
    }
    
    public class CustomShaderGUI : ShaderGUI
    {
        private MaterialEditor editor;
        private MaterialProperty[] props;
        private List<MaterialProperty> propsList=new List<MaterialProperty>();
        static Dictionary<string, MaterialProperty> s_MaterialProperty = new Dictionary<string, MaterialProperty>();
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            editor = materialEditor;
            props = properties;
            
            if(GetProperty("_ShaderMode")!=-1)
                Mode = (ShaderMode) EditorGUILayout.EnumPopup("ShaderMode",Mode);
            SetShadowCasterPass();
            SetPlanrShadowCasterPass();
            if (GetProperty("_DethPass") != -1)
            {
                    foreach (Material m in editor.targets)
                    {
                
                        m.SetShaderPassEnabled("DepthOnly",GetProperty("_DethPass") == 1);
                        
                    }
            }

            if (GetProperty("_IsEmission") == 1)
            {
                materialEditor.LightmapEmissionFlagsProperty(5,true,true);
            }

            SetProperty("_IsMAG", "_METALLICAOGLOSS_ON");
            SetProperty("_customLightMap", "CUSTOM_LIGHTMAP_ON");
            SetProperty("_ViewLighting", "_VIEWLIGHTING_ON");
            SetProperty("_IsEmission", "_EMISSION_ON");
            SetProperty("_IsNormal", "_NORMALMAP_ON");
            SetProperty("_IsMatCap", "_MATCAP_ON");
            SetProperty("_AddLighting", "_ADDLIGHTING_ON");
            SetProperty("_ReceiveShadows", "_RECEIVE_SHADOWS_ON");
            SetProperty("_UrpCustomPlanrOn", "CUSTOM_PLANE_ON");
            SetProperty("_TreeOn", "CUSTOM_TREE");
            
            ShowGUI(materialEditor);
        }
        void ShowGUI(MaterialEditor materialEditor)
        {
            
            
            Shader shader = (materialEditor.target as Material)?.shader;
            propsList.Clear();
            s_MaterialProperty.Clear();
            for (int i = 0; i < props.Length; i++)
            {
                var propertie = props[i];
                s_MaterialProperty[propertie.name] = propertie;
                propsList.Add(propertie);
                var attributes = shader.GetPropertyAttributes(i);
                foreach (var item in attributes)
                {
                    if (item.StartsWith("if"))
                    {
                        Match match = Regex.Match(item, @"(\w+)\s*\((.*)\)");
                        if (match.Success)
                        {
                            var name = match.Groups[2].Value.Trim();
                            if (s_MaterialProperty.TryGetValue(name, out var a))
                            {
                                 if (a.floatValue == 0f)
                                 {
                                      propsList.RemoveAt(propsList.Count-1);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
           editor.TextureScaleOffsetProperty(FindProperty("_MainTex", props));
            materialEditor.PropertiesDefaultGUI(propsList.ToArray());

        }


    
        void SetShadowCasterPass()
        {
            MaterialProperty shadows = FindProperty("_Shadows",props,false);
            if (shadows == null || shadows.hasMixedValue)
            {
                return;
            }

            foreach (Material m in editor.targets)
            {
                
                m.SetShaderPassEnabled("ShadowCaster",shadows.floatValue==1);
            }
        }
        //设置平面阴影
        void SetPlanrShadowCasterPass()
        {
            MaterialProperty shadows = FindProperty("_PlanrShadows",props,false);
            if (shadows == null || shadows.hasMixedValue)
            {
                return;
            }

            foreach (Material m in editor.targets)
            {
                
                m.SetShaderPassEnabled("SRPDefaultUnlit",shadows.floatValue==1);
            }
        }
        public enum ShaderMode
        {
            Qpaque,
            Cutoff,
            Fade,
            Transparent
        }
        private ShaderMode Mode
        {
            set
            {
                SetProperty("_ShaderMode", (int) value);
                switch (value)
                {
                    case ShaderMode.Qpaque:
                        Clipping = false;
                        PremultiplyAlpha = false;
                        SrcBlend = UnityEngine.Rendering.BlendMode.One;
                        DstBlend = UnityEngine.Rendering.BlendMode.Zero;
                        ZWrite = true;
                        RenderQueue = RenderQueue.Geometry;
                        break;
                    case ShaderMode.Cutoff:
                        Clipping = true;
                        PremultiplyAlpha = false;
                        SrcBlend = UnityEngine.Rendering.BlendMode.One;
                        DstBlend = UnityEngine.Rendering.BlendMode.Zero;
                        ZWrite = true;
                        RenderQueue = RenderQueue.AlphaTest;
                        break;
                    case ShaderMode.Fade:
                        Clipping = true;
                        PremultiplyAlpha = false;
                        SrcBlend = UnityEngine.Rendering.BlendMode.SrcAlpha;
                        DstBlend = UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha;
                        ZWrite = true;
                        RenderQueue = RenderQueue.Transparent;
                        break;
                    case ShaderMode.Transparent:
                        Clipping = true;
                        PremultiplyAlpha = true;
                        SrcBlend = UnityEngine.Rendering.BlendMode.One;
                        DstBlend = UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha;
                        ZWrite = true;
                        RenderQueue = RenderQueue.Transparent;
                        break;
                }
            }
            get { return (ShaderMode) GetProperty("_ShaderMode"); }
        }

    

        private bool Clipping
        {
            set => SetProperty("_Clipping","_CLIPPING_ON", value);
        }

        private bool PremultiplyAlpha
        {
            set => SetProperty("_PremulAlpha", "_PREMULTIPLY_ALPHA_ON", value);
        }

        private UnityEngine.Rendering.BlendMode SrcBlend
        {
            set => SetProperty("_SrcBlend", (float) value);
        }

        private UnityEngine.Rendering.BlendMode DstBlend
        {
            set => SetProperty("_DstBlend", (float) value);
        }

        private bool ZWrite
        {
            set => SetProperty("_ZWrite", value ? 1f : 0f);
        }

        RenderQueue RenderQueue
        {
            set
            {
                foreach (Material m in editor.targets)
                {
                    
                    m.renderQueue = (int) value;
                    
                   
                }
            }
        }

        float GetProperty(string name)
        {
            MaterialProperty prop = FindProperty(name, props, false);
            if(prop!=null)
                return FindProperty(name, props,false).floatValue;
            return -1;
        }

        bool SetProperty(string name, float value)
        {
            MaterialProperty prop = FindProperty(name, props, false);
            if (prop != null)
            {
                prop.floatValue = value;
                return true;
            }

            return false;
        }

        void SetProperty(string name, string keyword, bool value)
        {
            if(SetProperty(name, value ? 1f : 0f))
                SetKeyword(keyword, value);
        }
        void SetProperty(string name, string keyword)
        {
            MaterialProperty prop = FindProperty(name, props, false);
            if (prop != null)
            {
                SetKeyword(keyword, prop.floatValue==1);
            }

            
        }

        void SetKeyword(string keyword, bool enabled)
        {
            if (enabled)
            {
                foreach (Material m in editor.targets)
                    m.EnableKeyword(keyword);
            }
            else
            {
                foreach (Material m in editor.targets)
                    m.DisableKeyword(keyword);
            }
        }
    }
}
