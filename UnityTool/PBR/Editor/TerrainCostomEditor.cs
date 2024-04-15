using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class TerraionCostomEditor : YLib.StyledEditor.BaseShaderGUI
{
    private string[] ZTestModeName =Enum.GetNames(typeof(UnityEngine.Rendering.CompareFunction));
    private int[] ZTestModeValues = {2, 5, 6};

    private string[] ZWriterName = {"ON", "OFF"};
    private int[] ZWriterValues = {1, 0};
    private string[] CullModeName => Enum.GetNames(typeof(UnityEngine.Rendering.CullMode));
    private int[] CullModeValues = {0, 1, 2};
    private string[] blendModekey = {"TEX_1", "TEX_2", "TEX_3", "TEX_4", "TEX_5", "TEX_6", "TEX_7", "TEX_8"};
    private string[] blendModeName = {"纹理数 1", "纹理数 2", "纹理数 3", "纹理数 4", "纹理数 5", "纹理数 6", "纹理数 7", "纹理数 8"};
    private int[] blendModeValues = {0, 1, 2, 3, 4, 5, 6, 7};

    private string[] GIBakeModeName = {"受环境光影响", "不受环境光影响"};
    private int[] GIBakeModeValues = {0, 1};


    private MaterialProperty BlendModeProperty;
    private MaterialProperty ZTestPreoperty;
    private MaterialProperty ZwriterPreoperty;
    private MaterialProperty CullModePreoperty;
    private MaterialProperty MaskPreoperty;
    private MaterialProperty Mask1Preoperty;
    private MaterialProperty SaturationPreoperty;

    private MaterialProperty _MixedArrayMapPreoperty;
    //   private MaterialProperty _MixedNormalArrayMapPreoperty;

    private MaterialProperty ShadowColorPreoperty;

    private MaterialProperty _TerrainNormalPreoperty;
    private MaterialProperty _TerrainNormalSaclePreoperty;
    
    private MaterialProperty _MainLightProperty;
   // private MaterialProperty _isEmissionCameraLightPreoperty;
    
    private MaterialProperty _FogPreoperty;
    private MaterialProperty _CustomShadowsSoftPreoperty;
    private MaterialProperty _ReceiveShadowsPreoperty;
    
    private MaterialProperty _EnvironmentReflectionsPreoperty;
    private MaterialProperty _SpecularHighlightsPreoperty;
    private MaterialProperty _CustomLightMapPreoperty;
    
    private MaterialProperty _CustomMixedLighingSubPreoperty;
    private MaterialProperty _CustomMdirLightMapPreoperty;
    
    private MaterialProperty _AddLightVertexPreoperty;
    private string[] AddLightVertexModekey = {"","_CUSTOMADDITIONAL_LIGHTS_VERTEX", "_CUSTOMADDITIONAL_LIGHTS"};
    private string[] AddLightVertexModeName = {"关闭", "附加灯光顶点","附加灯光"};
    private int[] AddLightVertexModeValues = {0,1,2};


    // private MaterialProperty CubeMapPreoperty;
    // private MaterialProperty CubeMapColorPreoperty;
    // private MaterialProperty CubeMapStrengthPreoperty;
    //
    // private MaterialProperty BakedGIColorPreoperty;
    // private MaterialProperty SturationMaskAndAlphaMapProperty;
    // private MaterialProperty BakedGIProperty;

    protected override void OnShaderGUI(MaterialProperty[] properties)
    {
        UpdateMaterial(properties);
        ZTestModeValues = new int[ZTestModeName.Length];
        for (int i = 0; i < ZTestModeName.Length; i++)
        {
            ZTestModeValues[i] = i;
        }
        DrawShader();
    }

    float blendMode = -1;

    private void DrawShader()
    {
        DrawEnum("模式", BlendModeProperty, blendModeName, blendModeValues, blendModekey);

        m_materialEditor.TexturePropertySingleLine(new GUIContent("遮罩"), MaskPreoperty);
        if (BlendModeProperty.floatValue > 3)
        {
            //超过四张遮罩贴图
            m_materialEditor.TexturePropertySingleLine(new GUIContent("遮罩1"), Mask1Preoperty);
        }

        if (blendMode == -1)
        {
            int t = (int) BlendModeProperty.floatValue;
            EnableKeywordEnum(blendModekey,t);

            blendMode = 1;
        }

        m_materialEditor.TexturePropertySingleLine(new GUIContent("纹理图集", "地形所有纹理图集"),
            _MixedArrayMapPreoperty);
        //  m_materialEditor.TexturePropertySingleLine(new GUIContent("法线图集", "地形所有法线图集"),
        //      _MixedNormalArrayMapPreoperty);

        Texture2DArray array = (Texture2DArray) _MixedArrayMapPreoperty.textureValue;
        if (array != null)
        {
            Material = new Material(Shader.Find("Hidden/ArrayDraw"));
            for (int i = 0; i < BlendModeProperty.floatValue + 1; i++)
            {
                Material.SetFloat("_Index", i);
                if (BlendModeProperty.floatValue > 3)
                {
                    EditorGUI.DrawPreviewTexture(new Rect(85, 95+20+i*81, 50, 50), array, Material);
                }
                else
                {
                    EditorGUI.DrawPreviewTexture(new Rect(85, 75+20+i*81, 50, 50), array, Material);
                }
            }
        }
        for (int i = 0; i < BlendModeProperty.floatValue + 1; i++)
        {
            ShowMixed(i);
        }
      
        m_materialEditor.TexturePropertySingleLine(new GUIContent("地形法线"), _TerrainNormalPreoperty,
            _TerrainNormalPreoperty.textureValue != null ? _TerrainNormalSaclePreoperty : null);
        EnableKeyword("_TERRAINNORMAL_ON", _TerrainNormalPreoperty.textureValue != null);

        // General Transparent Material Settings
        //DrawEnum("双面模式",CullModePreoperty, CullModeName, CullModeValues, 70);
        // DrawEnum("深度",ZwriterPreoperty, ZWriterName, ZWriterValues, 70);
        //DrawEnum("Z模式",ZTestPreoperty, ZTestModeName, ZTestModeValues, 70);
        m_materialEditor.RenderQueueField();
        m_materialEditor.EnableInstancingField();
        
        
         EditorGUILayout.Space(8);
        EditorGUILayout.LabelField("全局参数",new GUIStyle(){fontSize = 15});
        
       // DrawEnum("摄像机灯光",_isEmissionCameraLightPreoperty,new []{"开启","关闭"},new []{1,0},70);
        DrawEnum("雾效",_FogPreoperty, new []{"雾效开启","雾效关闭"},new []{1,0}, 140);
        DrawEnum("主光源",_MainLightProperty, new []{"主光源开启","主光源关闭"},new []{1,0}, 140);
        DrawEnum("附加灯光", _AddLightVertexPreoperty,AddLightVertexModeName,AddLightVertexModeValues,AddLightVertexModekey);
        
        DrawEnum("接受阴影", _ReceiveShadowsPreoperty,new []{"接受阴影关闭","接受阴影开启"},new []{1,0},140);
        
        DrawEnum("烘焙贴图", _CustomLightMapPreoperty,new []{"开启烘焙贴图","关闭烘焙贴图"},new []{1,0},140);
        // if(_isReflectionProperty!=null)
        //     DrawEnum("反射(配合脚本)", _isReflectionProperty,new []{"开启反射","关闭反射"},new []{1,0},140);
        // if(_isReflectionProperty!=null)
        // if (_isReflectionProperty.floatValue == 1)
        // {
        //     m_materialEditor.ShaderProperty(_ReflectionColorProperty, "反射颜色(配合脚本)");
        //     m_materialEditor.TexturePropertySingleLine(new GUIContent("反射遮罩", "RG>uv扰动,B:遮罩"), _ReflectionMaskProperty);
        //     m_materialEditor.VectorProperty(_ReflectionUVProperty,"xy>uv流动,z:tiling,w:扰动强度");
        //     m_materialEditor.VectorProperty(_ReflectionMainUVProperty,"xy>uv流动,z:tiling,w:扰动强度");
        // }
      //  m_materialEditor.ShaderProperty(_SpecularHighlightsPreoperty, "镜面反射");
       // m_materialEditor.ShaderProperty(_EnvironmentReflectionsPreoperty, "环境反射");
        
        
        
        KeyWordInt("_SPECULARHIGHLIGHTS_OFF", _SpecularHighlightsPreoperty,0);
        KeyWordInt("_ENVIRONMENTREFLECTIONS_OFF", _EnvironmentReflectionsPreoperty,0);
        
        KeyWordInt("_CUSTOMADDITIONAL_LIGHTS_VERTEX", _AddLightVertexPreoperty);
        KeyWordInt("_CUSTOMADDITIONAL_LIGHTS", _AddLightVertexPreoperty,2);
        
        
     //   KeyWordInt("_ISREFLECTION_ON", _isReflectionProperty);
        KeyWordInt("_MAINLGIHT_ON", _MainLightProperty);
        
        
        KeyWordInt("_CUSTOMFOG_ON", _FogPreoperty);
        KeyWordInt("_CUSTOMLIGHTMAP_ON", _CustomLightMapPreoperty);

        //接受阴影
        KeyWordInt("_RECEIVE_SHADOWS_OFF", _ReceiveShadowsPreoperty);
        KeyWordInt("_CUSTOMMAIN_LIGHT_SHADOWS", _MainLightProperty);
       
        KeyWordInt("_SHADOWS_SOFT_ON", _CustomShadowsSoftPreoperty);
        KeyWordInt("_CUSTOMDIRLIGHTMAP_COMBINED", _CustomMdirLightMapPreoperty);
        KeyWordInt("_CUSTOMMIXED_LIGHTING_SUBTRACTIVE", _CustomMixedLighingSubPreoperty);
    }
    
    void KeyWordInt(string str, MaterialProperty property, int index=1)
    {
        if (property != null)
        {
            EnableKeyword(str,property.floatValue==index);
        }
        else
        {
            EnableKeyword(str,false);
        }       
    }

    private Material Material;

    private MixedIDType mixedIndex;
    private MixedIDType mixedNormalIndex;

    private class MixedIDType
    {
        public int[] mixedIndex;
        public string[] mixedName;
    }

    MixedIDType InitID(int index)
    {
        MixedIDType idtype = new MixedIDType();
        idtype.mixedIndex = new int[index];
        idtype.mixedName = new string[index];
        for (int i = 0; i < index; i++)
        {
            idtype.mixedIndex[i] = i;
            idtype.mixedName[i] = i + "";
        }

        return idtype;
    }

    void ShowMixed(int index)
    {
        MixedMapList mixed = MixedMapLists[index];
            GUILayout.Label(
                $"__混合纹理{index + 1}_______________________________________________________________________________________________________________________________________________________________________");

          
            mixed.MixedNroamlOffset.floatValue=EditorGUILayout.FloatField( "Tiling",mixed.MixedNroamlOffset.floatValue);
            m_materialEditor.RangeProperty(mixed.MixedSmoothness, "平滑度");
        m_materialEditor.TexturePropertySingleLine(new GUIContent("法线","法线图+纹理颜色+法线强度"), mixed.MixedNroamlMap,mixed.MixedMapColor,
            mixed.MixedNroamlMap != null ? mixed.MixedNroamlScale : null);
      
    }

    /// <summary>
    /// 法线显示
    /// </summary>
    private void DrawNormalMap(MaterialProperty mixed, MaterialProperty map, MaterialProperty mapScale, string Name)
    {
        EditorGUILayout.BeginHorizontal();
        m_materialEditor.TexturePropertySingleLine(new GUIContent(Name), mixed);
        m_materialEditor.TexturePropertySingleLine(new GUIContent("法线"), map,
            map.textureValue != null ? mapScale : null);

        EditorGUILayout.EndHorizontal();
        m_materialEditor.TextureScaleOffsetProperty(mixed);
    }

    struct MixedMapList
    {
        public MaterialProperty MixedNroamlMap;
        public MaterialProperty MixedNroamlScale;
        public MaterialProperty MixedNroamlOffset;
        public MaterialProperty MixedSmoothness;
        
        public MaterialProperty MixedMapColor;
    }

    private List<MixedMapList> MixedMapLists = new List<MixedMapList>();

    public void UpdateMaterial(MaterialProperty[] p)
    {
        BlendModeProperty = FindProperty("_Blend", p);
        CullModePreoperty = FindProperty("_Cull", p,false);
        ZwriterPreoperty = FindProperty("_ZWrite", p,false);
        ZTestPreoperty = FindProperty("_ZTest", p,false);
        MaskPreoperty = FindProperty("_MaskMap", p,false);
        Mask1Preoperty = FindProperty("_Mask1Map", p,false);
        _MixedArrayMapPreoperty = FindProperty("_MixedArrayMap", p);


        _TerrainNormalPreoperty = FindProperty("_TerrainNormal", p,false);
        _TerrainNormalSaclePreoperty = FindProperty("_TerrainNormalSacle", p,false);

        
        _FogPreoperty = FindProperty("_CustomFog", p,false);
        _AddLightVertexPreoperty = FindProperty("_AddLightVertex", p,false);
        _CustomShadowsSoftPreoperty = FindProperty("_CustomShadowsSoft", p,false);
        _ReceiveShadowsPreoperty=FindProperty("_ReceiveShadows", p,false);
        _SpecularHighlightsPreoperty = FindProperty("_SpecularHighlights", p,false);
        _EnvironmentReflectionsPreoperty = FindProperty("_EnvironmentReflections", p,false);
        _CustomLightMapPreoperty = FindProperty("_CustomLightMap", p,false);
        _CustomMixedLighingSubPreoperty = FindProperty("_CustomMixedLighingSub", p,false);
        _CustomMdirLightMapPreoperty = FindProperty("_CustomMdirLightMap", p,false);
        _MainLightProperty = FindProperty("_MainLightOn", p,false);


        MixedMapLists.Clear();
        for (int i = 1; i < 9; i++)
        {
            MixedMapList tempMap = new MixedMapList();
            tempMap.MixedNroamlMap = FindProperty("_MixedMapNormal" + i, p);
            tempMap.MixedNroamlScale = FindProperty("_MixedNormalScale" + i, p);
            tempMap.MixedNroamlOffset = FindProperty("_MixedMapOffset" + i, p);
            tempMap.MixedMapColor = FindProperty("_MixedMapColor" + i, p);
            tempMap.MixedSmoothness = FindProperty("_MixedSmoothness" + i, p,false);

            MixedMapLists.Add(tempMap);
        }
    }
}
