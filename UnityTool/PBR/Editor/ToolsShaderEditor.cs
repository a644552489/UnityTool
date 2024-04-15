using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class ToolsShaderEditor : ShaderGUI
{
    private string[] blendModekey = {"_BLENDMODE_ADD", "_BLENDMODE_ALPHA", "_BLENDMODE_PRE"};
    private string[] blendModeName = {"Add", "Alpha", "Premultiply"};
    private int[] blendModeValues = {0, 1, 2};

    private string[] Costom_Modekey = {"", "", "", "", "", ""};
    private string[] Costom_ModeName = {"效果列表", "双纹理", "菲尼尔", "溶解", "扭曲1", "扭曲2", "遮罩"};
    private int[] Costom_ModeValues = {0, 1, 2, 3, 4, 5, 6};
    private string[] CullModeName => Enum.GetNames(typeof(UnityEngine.Rendering.CullMode));
    private int[] CullModeValues = {0, 1, 2};


    public string[] ZTestModeName =>Enum.GetNames(typeof(UnityEngine.Rendering.CompareFunction));
    private int[] ZTestModeValues = {0,1,2,3,4, 5,6,7,8};

    private string[] ZWriterName = {"ON", "OFF"};
    private int[] ZWriterValues = {1, 0};

    private string[] AlphaName = {"R", "RGBA"};
    private int[] AlphaValues = {1, 0};

    private string[] doublekey = {"DOUBLE1_ADD", "DOUBLE1_MUL"};
    private string[] doubleName = {"相加", "相乘"};
    private int[] doubleValues = {0, 1};

    private string[] Lightkey = {"VANISH_LIGHT", "VANISH_TRANS"};
    private string[] LightName = {"亮边溶解", "软溶解"};
    private int[] LightValues = {0, 1};

    private string[] Vectertkey = {"VECTER_ON", "VALUES_ON"};
    private string[] VecterName = {"粒子控制溶解", "数值控制溶解"};
    private int[] VecterValues = {0, 1};


    private string[] fresnelModekey = {"FRESNEL_OFF","FRESNEL_ON"};
    private string[] maskFresnelModekey = {"_MASKFRESNEL_OFF","_MASKFRESNEL_ON"};
    private string[] noise1Modekey = {"NOISE1_OFF","NOISE1_ON"};
    private string[] noise2Modekey = {"NOISE2_OFF","NOISE2_ON"};
    private string[] maskModekey = {"MASK1_OFF","MASK1_ON"};
    private string[] alphaModekey = {"ALPHA_A","ALPHA_R"};
    private string[] alphaDoublelModekey = {"ALPHADOUBLEL_A","ALPHADOUBLEL_R"};
    private string[] DoublelModekey = {"DOUBLE1_OFF","DOUBLE1_ON"};
    private string[] vanishModekey = {"VANISH_OFF","VANISH_ON"};


    private int[] ModeValues = {0, 1};
    private int IsValue;
    private bool Double1=true, Fresnel=true, Vanish=true, Noise1=true, Noise2=true, Mask1=true;

    private static Dictionary<string, string> NameDic = new Dictionary<string, string>()
    {
        {"Blend_Mode", "模式"},
        {"Cull_Mode", "双面模式"},
        {"ZWriter_Mode", "深度"},
        {"ZTest_Mode", "Z模式"},
        {"Tex_Fresne1", "纹理"},
        {"Scale_Fresne1", "缩放"},
        {"Power_Fresne1", "强度"},
        {"Color_Fresne1", "颜色"},
        {"uv_Fresne1", "纹理流动 ZW:扭曲强度"},
        {"Main_Tex", "主贴图"},
        {"Main_Color", "主颜色"},
        {"Main_UV", "主纹理流动"},
        {"NoiseTex_Noise1", "扭曲贴图"},
        {"NoiseUV_Noise1", "XY:流动 Z:扭曲强度"},
        {"NoiseTex_Noise2", "扭曲贴图"},
        {"NoiseUV_Noise2", "XY:流动 Z:扭曲强度"},
        {"MaskTex_Mask1", "遮罩贴图"},
        {"MaskUV_Mask1", "XY:流动 Z:强度 W:Pow"},
        {"Mul_Double1", "叠加模式"},
        {"Color_Double1", "颜色"},
        {"Tex_Double1", "纹理"},
        {"UV_Double1", "XY:流动 ZW:扭曲强度"},
        {"Light_Vanish", "溶解模式"},
        {"Color_Vanish", "边缘颜色"},
        {"Tex_Vanish", "纹理"}, {"Strength_Vanish", "软溶解强度"},
        {"Width_Vanish", "亮边宽度"},
        {"Length_Vanish", "溶解调节值"},
        {"uv_Vanish", "XY:流动 ZW:扭曲强度"},
        {"Vertex_Vanish", "控制模式"},
    };


    private MaterialEditor m_materialEditor;

    private MaterialProperty BlendModeKeyProperty;
    private MaterialProperty CullModePreoperty;
    private MaterialProperty ZwriterPreoperty;
    private MaterialProperty ZTestPreoperty;
    private MaterialProperty MainColorPreoperty;
    private MaterialProperty MainTexPreoperty;
    private MaterialProperty AlphaModePreoperty;
    private MaterialProperty MainUVPreoperty;
    private MaterialProperty AlphaDoublelModePreoperty;

    private List<MaterialProperty> listFresnel1 = new List<MaterialProperty>();
    private MaterialProperty ToggleFresnelProperty;
    private MaterialProperty IsMaskFresnelProperty;
    private List<MaterialProperty> listNoisel = new List<MaterialProperty>();
    private MaterialProperty ToggleNoiselProperty;
    private List<MaterialProperty> listNoise2 = new List<MaterialProperty>();
    private MaterialProperty ToggleNoise2Property;

    private List<MaterialProperty> listDoublel = new List<MaterialProperty>();
    private MaterialProperty ToggleDouble1Property;
    private MaterialProperty MulDoubleProperty;
    private MaterialProperty ColorDoubleProperty;


    private List<MaterialProperty> listVanish = new List<MaterialProperty>();
    private MaterialProperty ToggleVanishProperty;
    private MaterialProperty VanishColorProperty;
    private MaterialProperty VanishLightProperty;
    private MaterialProperty VanishWidthProperty;
    private MaterialProperty VanishLengthProperty;
    private MaterialProperty VanishUVProperty;
    private MaterialProperty vanishMinProperty;
    private MaterialProperty vanishMaxProperty;
    private MaterialProperty VecterProperty;

    private List<MaterialProperty> listMaskl = new List<MaterialProperty>();
    private MaterialProperty ToggleMask1Property;


    void SetProperty(MaterialProperty pro, string key, bool isbool = true)
    {
        pro.floatValue = 1;
        EnableKeyword(key, isbool);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        m_materialEditor = materialEditor;

        listFresnel1.Clear();
        listNoisel.Clear();
        listMaskl.Clear();
        listNoise2.Clear();
        listDoublel.Clear();
        listVanish.Clear();
        foreach (var p in properties)
        {

            string propName = p.displayName;
            if (propName.EndsWith("Mode"))
            {
                if (propName.StartsWith("Cull"))
                {
                    CullModePreoperty = p;
                }
                else if (propName.StartsWith("ZWriter"))
                {
                    ZwriterPreoperty = p;
                }
                else if (propName.StartsWith("Blend"))
                {
                    BlendModeKeyProperty = p;
                }
                else if (propName.StartsWith("Alpha"))
                {
                    AlphaModePreoperty = p;
                }
                else if (propName.StartsWith("ZTest"))
                {
                    ZTestPreoperty = p;
                }
                else if (propName.StartsWith("Dph"))
                {
                    AlphaDoublelModePreoperty = p;
                }
            }
            else if (propName.EndsWith("Color"))
            {
                MainColorPreoperty = p;
            }
            else if (propName.EndsWith("Tex"))
            {
                if (propName.StartsWith("Main"))
                {
                    MainTexPreoperty = p;
                }
            }
            else if (propName.EndsWith("Fresne1"))
            {
                if (propName.Contains("Toggle"))
                {
                    ToggleFresnelProperty = p;
                }
                else if (propName.Contains("IsMask"))
                {
                    IsMaskFresnelProperty = p;
                }
                else
                {
                    listFresnel1.Add(p);
                }
            }
            else if (propName.EndsWith("UV"))
            {
                if (propName.Contains("Main"))
                {
                    MainUVPreoperty = p;
                }
            }
            else if (propName.EndsWith("Noise1"))
            {
                if (propName.Contains("Toggle"))
                {
                    ToggleNoiselProperty = p;
                }
                else
                {
                    listNoisel.Add(p);
                }
            }
            else if (propName.EndsWith("Noise2"))
            {
                if (propName.Contains("Toggle"))
                {
                    ToggleNoise2Property = p;
                }
                else
                {
                    listNoise2.Add(p);
                }
            }
            else if (propName.EndsWith("Mask1"))
            {
                if (propName.Contains("Toggle"))
                {
                    ToggleMask1Property = p;
                }
                else
                {
                    listMaskl.Add(p);
                }
            }
            else if (propName.EndsWith("Double1"))
            {
                if (propName.Contains("Toggle"))
                {
                    ToggleDouble1Property = p;
                }
                else if (propName.Contains("Mul"))
                {
                    MulDoubleProperty = p;
                }
                else if (propName.Contains("Color"))
                {
                    ColorDoubleProperty = p;
                }
                else
                {
                    listDoublel.Add(p);
                }
            }
            else if (propName.EndsWith("Vanish"))
            {
                if (propName.Contains("Toggle"))
                {
                    ToggleVanishProperty = p;
                }
                else if (propName.Contains("Strength"))
                {
                    VanishLengthProperty = p;
                }
                else if (propName.Contains("Color"))
                {
                    VanishColorProperty = p;
                }
                else if (propName.Contains("Width"))
                {
                    VanishWidthProperty = p;
                }
                else if (propName.Contains("Light"))
                {
                    VanishLightProperty = p;
                }
                else if (propName.Contains("uv"))
                {
                    VanishUVProperty = p;
                }
                else if (propName.Contains("Min"))
                {
                    vanishMinProperty = p;
                }
                else if (propName.Contains("Max"))
                {
                    vanishMaxProperty = p;
                }
                else if (propName.Contains("Vertex"))
                {
                    VecterProperty = p;
                }
                else
                {
                    listVanish.Add(p);
                }
            }
        }

        DrawGUI();
    }

    void DrawGUI()
    {
        EditorGUI.BeginChangeCheck();
        {
            EditorGUILayout.BeginHorizontal();
            IsValue = EditorGUILayout.IntPopup("效果", IsValue, Costom_ModeName, Costom_ModeValues);

            EditorGUILayout.EndHorizontal();
            DrawEnum(BlendModeKeyProperty, blendModeName, blendModeValues, blendModekey, (t) =>
            {
                if (t == 0)
                {
                    foreach (var q in m_materialEditor.targets)
                    {
                        Material m = q as Material;
                        m.renderQueue = 3000;
                        m.SetOverrideTag("RenderType", "Transparent");
                        m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.One);
                        m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.One);
                    }
                }
                else if (t == 1)
                {
                    foreach (var q in m_materialEditor.targets)
                    {
                        Material m = q as Material;
                        m.renderQueue = 3000;
                        m.SetOverrideTag("RenderType", "Transparent");
                        m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                        m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    }
                }
                else if (t == 2)
                {
                    foreach (var q in m_materialEditor.targets)
                    {
                        Material m = q as Material;
                        m.renderQueue = 3000;
                        m.SetOverrideTag("RenderType", "Transparent");
                        m.SetInt("_BlendSrc", (int) UnityEngine.Rendering.BlendMode.One);
                        m.SetInt("_BlendDst", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    }
                }
            });
        }


        EditorGUILayout.BeginHorizontal();
        DrawProperty(MainColorPreoperty);
        if (BlendModeKeyProperty.floatValue == 1 || BlendModeKeyProperty.floatValue == 2)
            DrawToggle(AlphaModePreoperty, "R", alphaModekey);
        EditorGUILayout.EndHorizontal();
        DrawProperty(MainTexPreoperty);
        MainUVPreoperty.vectorValue =
            EditorGUILayout.Vector2Field(NameDic[MainUVPreoperty.displayName], MainUVPreoperty.vectorValue);
        if (EditorGUI.EndChangeCheck())
        {
            switch (IsValue)
            {
                case 0:
                    break;
                case 1:
                    SetProperty(ToggleDouble1Property, "DOUBLE1_ON");
                    break;
                case 2:
                    SetProperty(ToggleFresnelProperty, "FRESNEL_ON");
                    break;
                case 3:
                    SetProperty(ToggleVanishProperty, "VANISH_ON");
                    break;
                case 4:
                    SetProperty(ToggleNoiselProperty, "NOISE1_ON");
                    break;
                case 5:
                    SetProperty(ToggleNoise2Property, "NOISE2_ON");
                    break;
                case 6:
                    SetProperty(ToggleMask1Property, "MASK1_ON");
                    break;
            }

            m_materialEditor.PropertiesChanged();

            if (IsValue != 0)
            {
                IsValue = 0;
                return;
            }
        }

        //刷新
        if(ToggleDouble1Property!=null&& ToggleDouble1Property.floatValue==0)
            EnableKeyword(DoublelModekey[1],false);
        else
            EnableKeyword(DoublelModekey[1],true);

        if(IsMaskFresnelProperty!=null&& IsMaskFresnelProperty.floatValue==0)
            EnableKeyword(maskFresnelModekey[1],false);
        else
            EnableKeyword(maskFresnelModekey[1],true);

        if(ToggleFresnelProperty!=null&& ToggleFresnelProperty.floatValue==0)
            EnableKeyword(fresnelModekey[1],false);
        else
            EnableKeyword(fresnelModekey[1],true);

        if(ToggleNoiselProperty!=null&& ToggleNoiselProperty.floatValue==0)
            EnableKeyword(noise1Modekey[1],false);
        else
            EnableKeyword(noise1Modekey[1],true);

        if(ToggleNoise2Property!=null&& ToggleNoise2Property.floatValue==0)
            EnableKeyword(noise2Modekey[1],false);
        else
            EnableKeyword(noise2Modekey[1],true);

        if(ToggleMask1Property!=null&& ToggleMask1Property.floatValue==0)
            EnableKeyword(maskModekey[1],false);
        else
            EnableKeyword(maskModekey[1],true);

        if(ToggleVanishProperty!=null&& ToggleVanishProperty.floatValue==0)
            EnableKeyword(vanishModekey[1],false);
        else
            EnableKeyword(vanishModekey[1],true);

        if(AlphaModePreoperty!=null&& AlphaModePreoperty.floatValue==0)
            EnableKeyword(alphaModekey[1],false);
        else
            EnableKeyword(alphaModekey[1],true);

        if(AlphaDoublelModePreoperty!=null&& AlphaDoublelModePreoperty.floatValue==0)
            EnableKeyword(alphaDoublelModekey[1],false);
        else
            EnableKeyword(alphaDoublelModekey[1],true);

        if(ToggleDouble1Property!=null&& ToggleDouble1Property.floatValue==0)
            EnableKeyword(DoublelModekey[1],false);
        else
            EnableKeyword(DoublelModekey[1],true);

        if(VanishLightProperty!=null&& VanishLightProperty.floatValue==0)
            EnableKeywordEnum(Lightkey,(int)VanishLightProperty.floatValue);
        else
            EnableKeywordEnum(Lightkey,(int)VanishLightProperty.floatValue);


        if(MulDoubleProperty!=null&& MulDoubleProperty.floatValue==0)
            EnableKeywordEnum(doublekey,(int)MulDoubleProperty.floatValue);
        else
            EnableKeywordEnum(doublekey,(int)MulDoubleProperty.floatValue);

        if(VecterProperty!=null&& VecterProperty.floatValue==0)
            EnableKeywordEnum(Vectertkey,(int)VecterProperty.floatValue);
        else
            EnableKeywordEnum(Vectertkey,(int)VecterProperty.floatValue);

        if(BlendModeKeyProperty!=null&& BlendModeKeyProperty.floatValue==0)
            EnableKeywordEnum(blendModekey,(int)BlendModeKeyProperty.floatValue);
        else
            EnableKeywordEnum(blendModekey,(int)BlendModeKeyProperty.floatValue);


        if (ToggleDouble1Property.floatValue == 1)
        {
            DrawList(listDoublel, ToggleDouble1Property, "双纹理", DoublelModekey[1], ref Double1, () =>
            {
                if (BlendModeKeyProperty.floatValue == 1|| BlendModeKeyProperty.floatValue == 2 )
                {
                    DrawToggle(AlphaDoublelModePreoperty, "R通道",alphaDoublelModekey[1]);
                }

                DrawEnum(MulDoubleProperty, doubleName, doubleValues, doublekey, 70);
                if (MulDoubleProperty.floatValue == 0)
                {
                    DrawProperty(ColorDoubleProperty);
                }
            });
        }

        if (ToggleVanishProperty.floatValue == 1)
        {
            DrawList(listVanish, ToggleVanishProperty, "溶解    ", vanishModekey[1], ref Vanish, () =>
            {
                float min = vanishMinProperty.floatValue;
                float max = vanishMaxProperty.floatValue;

                EditorGUI.BeginChangeCheck();
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("溶解阕值：" + min.ToString("F"), GUILayout.Width(95));
                EditorGUILayout.MinMaxSlider(ref min, ref max, -1, 2);
                EditorGUILayout.LabelField("" + max.ToString("F"), GUILayout.Width(35));


                if (EditorGUI.EndChangeCheck())
                {
                    vanishMinProperty.floatValue = min;
                    vanishMaxProperty.floatValue = max;
                }
                if (GUILayout.Button("重置"))
                {
                    vanishMinProperty.floatValue = 0;
                    vanishMaxProperty.floatValue = 1;
                }
                EditorGUILayout.EndHorizontal();
                DrawEnum(VanishLightProperty, LightName, LightValues, Lightkey, 70);
                DrawEnum(VecterProperty, VecterName, VecterValues, Vectertkey, 70);
                if (VanishLightProperty.floatValue == 0)
                {
                    DrawProperty(VanishColorProperty);
                    DrawProperty(VanishWidthProperty);
                }
                else if (VanishLightProperty.floatValue == 1)
                {
                    DrawProperty(VanishLengthProperty);
                }
            }, () => { DrawProperty(VanishUVProperty); });
        }

        if (ToggleFresnelProperty.floatValue == 1)
        {
            DrawList(listFresnel1, ToggleFresnelProperty, "菲尼尔", fresnelModekey[1], ref Fresnel,
                () => { DrawToggle(IsMaskFresnelProperty, "启用MASK",maskFresnelModekey[1]); });
        }


        if (ToggleNoiselProperty.floatValue == 1)
        {
            DrawList(listNoisel, ToggleNoiselProperty, "扭曲1   ", noise1Modekey[1], ref Noise1);
        }

        if (ToggleNoise2Property.floatValue == 1)
            DrawList(listNoise2, ToggleNoise2Property, "扭曲2   ", noise2Modekey[1], ref Noise2);
        if (ToggleMask1Property.floatValue == 1)
            DrawList(listMaskl, ToggleMask1Property, "遮罩1   ", maskModekey[1], ref Mask1);

        DrawEnum(CullModePreoperty, CullModeName, CullModeValues, 70);
        DrawEnum(ZwriterPreoperty, ZWriterName, ZWriterValues, 70);

        DrawEnum(ZTestPreoperty, ZTestModeName, ZTestModeValues, 70);


        m_materialEditor.RenderQueueField();
    }


    private GUIStyle LineStyle => new GUIStyle("CN CountBadge");


    private void DrawList(List<MaterialProperty> properties, MaterialProperty LineProp, string toggleName,
        string keyword, ref bool isShow, Action ab = null, Action endAb = null)
    {
        bool isToggle = LineProp.floatValue == 1 ? true : false;
        EditorGUILayout.BeginHorizontal();
        EditorGUI.BeginChangeCheck();
        isToggle = EditorGUILayout.Toggle("", isToggle, GUILayout.Width(15));
        if (EditorGUI.EndChangeCheck())
        {
            LineProp.floatValue = isToggle ? 1 : 0;
            EnableKeyword(keyword,isToggle);
            //EnableKeyword(keyword, isToggle);
        }
        string str;
        if (isShow && isToggle)
        {
            str = "(O o O)";
        }
        else
        {
            str = "(～ o ～)";
        }

        if (GUILayout.Button(toggleName + " " + str))
            isShow = !isShow;

        EditorGUILayout.EndHorizontal();

        if (isToggle)
        {
            if (isShow)
            {
                ab?.Invoke();
                foreach (var prop in properties)
                {
                    DrawProperty(prop);
                }

                endAb?.Invoke();
            }
        }
        else
        {
            foreach (var prop in properties)
            {
                if (prop.type == MaterialProperty.PropType.Texture)
                {
                    prop.textureValue = null;
                }

            }
        }
    }

    private void DrawToggle(MaterialProperty LineProp, string toggleName,
        string[] keyword)
    {
        bool isToggle = LineProp.floatValue == 1 ? true : false;
        EditorGUI.BeginChangeCheck();
        isToggle = EditorGUILayout.ToggleLeft(toggleName, isToggle);
        if (EditorGUI.EndChangeCheck())
        {
            LineProp.floatValue = isToggle ? 1 : 0;

            EnableKeyword(keyword[0], isToggle);
            EnableKeyword(keyword[1], !isToggle);
        }
    }

    private void DrawToggle(MaterialProperty LineProp, string toggleName,
        string keyword)
    {
        bool isToggle = LineProp.floatValue == 1 ? true : false;
        EditorGUI.BeginChangeCheck();
        isToggle = EditorGUILayout.ToggleLeft(toggleName, isToggle);
        if (EditorGUI.EndChangeCheck())
        {
            LineProp.floatValue = isToggle ? 1 : 0;
            EnableKeyword(keyword, isToggle);
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

    private void DrawEnum(MaterialProperty property, string[] names, int[] values, float width, Action<int> ab = null)
    {
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


    private void DrawEnum(MaterialProperty property, string[] names, int[] values, string[] keywords, float width,
        Action<int> ab = null)
    {
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
            EnableKeywordEnum(keywords, value);
        }

        if (hasMixedValue) EditorGUI.showMixedValue = false;
    }

    private void DrawEnum(MaterialProperty property, string[] names, int[] values, string[] keywords,
        Action<int> ab = null)
    {
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
}