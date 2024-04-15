using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class LitCustomEditor :YLib.StyledEditor.BaseShaderGUI
{
    private string[] ZTestModeName = Enum.GetNames(typeof(UnityEngine.Rendering.CompareFunction));
    private int[] ZTestModeValues = {2, 5, 6};

    private string[] ZWriterName = {"ON", "OFF"};
    private int[] ZWriterValues = {1, 0};
    private string[] CullModeName => Enum.GetNames(typeof(UnityEngine.Rendering.CullMode));
    private int[] CullModeValues = {0, 1, 2};
    private string[] blendModekey = {"_BLENDMODE_DIFFUSE", "_BLENDMODE_TRANSPARENT"};
    private string[] blendModeName = {"Diffuse", "Transparent"};
    private int[] blendModeValues = {0, 1};

    private string[] GIBakeModeName = {"受环境光影响", "不受环境光影响"};
    private int[] GIBakeModeValues = {0, 1};

    private MaterialProperty BlendModeProperty;
    private MaterialProperty ZTestPreoperty;
    private MaterialProperty ZwriterPreoperty;
    private MaterialProperty CullModePreoperty;
    private MaterialProperty MainColorPreoperty;
    private MaterialProperty MainTexPreoperty;
    private MaterialProperty MainTexTempPreoperty;
    private MaterialProperty AlphaClipPreoperty;
    private MaterialProperty SaturationPreoperty;

    private MaterialProperty NormalMapPreoperty;
    private MaterialProperty NormalScalePreoperty;

    private MaterialProperty MetallicMapPreoperty;
    private MaterialProperty MetallicPreoperty;
    private MaterialProperty OcclusionPreoperty;
    private MaterialProperty SmoothnessPreoperty;

    private MaterialProperty EmssionMapPreoperty;
    private MaterialProperty EmissionColorPreoperty;

    private MaterialProperty ShadowColorPreoperty;
    private MaterialProperty _isEmissionCameraLightPreoperty;


    private MaterialProperty _QueueOffsetPreoperty;
    
    
    
    private MaterialProperty _EnvironmentReflectionsPreoperty;
    private MaterialProperty _SpecularHighlightsPreoperty;
    private MaterialProperty _CustomLightMapPreoperty;
    
    
    private MaterialProperty _MainLightProperty;
    
    private MaterialProperty UnlockingPreoperty;
    private MaterialProperty UnlockingStrengthPreoperty;



    private MaterialProperty _FogPreoperty;
    private MaterialProperty _CustomShadowsSoftPreoperty;
    private MaterialProperty _ReceiveShadowsPreoperty;

    
    
    private MaterialProperty _AddLightVertexPreoperty;
    private string[] AddLightVertexModekey = {"","_CUSTOMADDITIONAL_LIGHTS_VERTEX", "_CUSTOMADDITIONAL_LIGHTS"};
    private string[] AddLightVertexModeName = {"关闭", "附加灯光顶点","附加灯光"};
    private int[] AddLightVertexModeValues = {0,1,2};
    
    
    private MaterialProperty _isReflectionProperty;
    private MaterialProperty _ReflectionColorProperty;
    private MaterialProperty _ReflectionMaskProperty;
    private MaterialProperty _ReflectionSmoothnessProperty;
    private MaterialProperty _ReflectionUVProperty;
    private MaterialProperty _ReflectionMainUVProperty;

    private MaterialProperty SSSCubeMapPreoperty;
    private MaterialProperty SSMaskMapPreoperty;
    private MaterialProperty SSSCubeMapColorPreoperty;

    private MaterialProperty _CustomMixedLighingSubPreoperty;
    private MaterialProperty _CustomMdirLightMapPreoperty;
    
    //#pragma shader_feature _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

    private MaterialProperty CubeMapPreoperty;
    
    private MaterialProperty CubeMapColorPreoperty;
    private MaterialProperty CubeMapStrengthPreoperty;
    private MaterialProperty BakedGIColorPreoperty;
    private MaterialProperty SturationMaskAndAlphaMapProperty;
    private MaterialProperty BakedGIProperty;
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
    float blendMode=-1;

    void SetRenderType(MaterialProperty Blend)
    {
        
        if(BlendModeProperty!=null)
            switch (BlendModeProperty.floatValue)
            {
                case 0:
                    foreach (var q in m_materialEditor.targets)
                    {
                        Material m = q as Material;
                      
                        if (m.renderQueue == 2800||m.renderQueue == 2000||m.renderQueue == 2450)
                            m.renderQueue = 2000;

                     
                        m.SetOverrideTag("RenderType", "Opaque");
                        m.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.One);
                        m.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
                        m.SetShaderPassEnabled("ShadowCaster", true);
                    }
                    break;
                case 1:
                    foreach (var q in m_materialEditor.targets)
                    {
                        Material m = q as Material;
                        m.SetOverrideTag("RenderType", "Transparent");
                        if (m.renderQueue == 2800||m.renderQueue == 2000||m.renderQueue == 2450)
                            m.renderQueue = 2800;
                        m.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                        m.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        m.SetShaderPassEnabled("ShadowCaster", true);
                    }
                    break;
                case 2:
                    foreach (var q in m_materialEditor.targets)
                    {
                        Material m = q as Material;
                        m.SetOverrideTag("RenderType", "AlphaTest");
                        if (m.renderQueue == 2800||m.renderQueue == 2000||m.renderQueue == 2450)
                            m.renderQueue = 2450;
                        m.SetInt("_SrcBlend", (int) UnityEngine.Rendering.BlendMode.SrcAlpha);
                        m.SetInt("_DstBlend", (int) UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    }
                    break;

            }
    }
    private void DrawShader()
    {
        DrawEnum("模式",BlendModeProperty, blendModeName, blendModeValues, blendModekey,(a)=>
        {
           SetRenderType(BlendModeProperty);
        });
        if (blendMode == -1)
        {
            SetRenderType(BlendModeProperty);
            blendMode = 1;
        }
        m_materialEditor.RangeProperty(AlphaClipPreoperty, "透明裁剪");
        if (AlphaClipPreoperty != null&&BlendModeProperty.floatValue==0)
        {
            
            if (AlphaClipPreoperty.floatValue > 0)
            {
                foreach (var q in m_materialEditor.targets)
                {
                    Material m = q as Material;
                    if (m.renderQueue < 2500)
                    {
                        m.renderQueue = 2500;
                    }
                }
               
            }
            else
            {
                foreach (var q in m_materialEditor.targets)
                {
                    Material m = q as Material;
                    if (m.renderQueue > 2450)
                    {
                        m.renderQueue = 2000;
                    }
                }
                
            }
        }
        m_materialEditor.TexturePropertySingleLine(new GUIContent("主纹理"), MainTexPreoperty, MainColorPreoperty);

        if (MainTexPreoperty != null && MainTexPreoperty.textureValue != null && MainTexTempPreoperty != null)
        {
            m_materialEditor.SetTexture("_MainTex", MainTexPreoperty.textureValue);

        }
        
        DrawMetallicAoGloss();
        DrawNormalMap(NormalMapPreoperty,NormalScalePreoperty,"法线纹理");
        m_materialEditor.RangeProperty(SaturationPreoperty, "AO加重");
        //m_materialEditor.TexturePropertySingleLine(new GUIContent("饱和度","R:饱和度遮罩,B:Alpha"),SturationMaskAndAlphaMapProperty,SaturationPreoperty);

        m_materialEditor.TexturePropertyWithHDRColor(new GUIContent("自发光纹理"), EmssionMapPreoperty, EmissionColorPreoperty,false);
        m_materialEditor.TextureScaleOffsetProperty(MainTexPreoperty);

        m_materialEditor.TexturePropertySingleLine(new GUIContent("反射纹理"), CubeMapPreoperty,CubeMapPreoperty.textureValue?CubeMapColorPreoperty:null,CubeMapPreoperty.textureValue?CubeMapStrengthPreoperty:null );
        if (SSMaskMapPreoperty != null)
        {
            m_materialEditor.TexturePropertySingleLine(new GUIContent("皮肤遮罩"),SSMaskMapPreoperty);
            if(SSSCubeMapPreoperty!=null)
            if (SSMaskMapPreoperty.textureValue!= null)
            {
                m_materialEditor.TexturePropertySingleLine(new GUIContent("皮肤反射纹理"), SSSCubeMapPreoperty,SSSCubeMapPreoperty.textureValue!=null?SSSCubeMapColorPreoperty:null);
           
            }
        }
        
        if(BakedGIProperty.floatValue==1)
            m_materialEditor.ColorProperty(BakedGIColorPreoperty,"环境光颜色");
        if(_ReceiveShadowsPreoperty.floatValue==0)
            m_materialEditor.ColorProperty(ShadowColorPreoperty,"接受阴影颜色");
        DrawEnum("摄像机灯光",_isEmissionCameraLightPreoperty,new []{"开启","关闭"},new []{1,0},70);
    
        if (SSMaskMapPreoperty!= null)
            EnableKeyword("_SSSMAP_ON",SSSCubeMapPreoperty.textureValue!=null); 
        
        EnableKeyword("_METALLICSPECGLOSSMAP",MetallicMapPreoperty.textureValue!=null); 
        EnableKeyword("_NORMALMAP",NormalMapPreoperty.textureValue!=null);
        EnableKeyword("_EMISSION",EmssionMapPreoperty.textureValue!=null);
        EnableKeyword("_CUBEMAP",CubeMapPreoperty.textureValue!=null);

        
       
        
//        EnableKeyword("_STURATIONMASKANDALPHA",SturationMaskAndAlphaMapProperty.textureValue!=null);
        
        
        
        //EnableKeyword("_ADDITIONAL_LIGHTS_VERTEX",false);
       // EnableKeyword("_ADDITIONAL_LIGHTS",false);
      

        // General Transparent Material Settings
        DrawEnum("环境光",BakedGIProperty, GIBakeModeName, GIBakeModeValues, 120);
        DrawEnum("双面模式",CullModePreoperty, CullModeName, CullModeValues, 70);
        DrawEnum("深度",ZwriterPreoperty, ZWriterName, ZWriterValues, 70);
        DrawEnum("Z模式",ZTestPreoperty, ZTestModeName, ZTestModeValues, 70);
        DrawEnum("解锁(Unlocking)",UnlockingPreoperty, new [] {"未解锁", "解锁"}, new [] {0, 1}, 70);
        m_materialEditor.FloatProperty(UnlockingStrengthPreoperty,"解锁(Unlocking)强度");
        
        m_materialEditor.RenderQueueField();
       m_materialEditor.EnableInstancingField();
        
        EditorGUILayout.Space(8);
        EditorGUILayout.LabelField("全局参数",new GUIStyle(){fontSize = 15});
        
        
        DrawEnum("雾效",_FogPreoperty, new []{"雾效开启","雾效关闭"},new []{1,0}, 140);
        DrawEnum("主光源",_MainLightProperty, new []{"主光源开启","主光源关闭"},new []{1,0}, 140);
        DrawEnum("附加灯光", _AddLightVertexPreoperty,AddLightVertexModeName,AddLightVertexModeValues,AddLightVertexModekey);
        DrawEnum("混合灯光", _CustomMixedLighingSubPreoperty,new []{"开启混合灯光","关闭混合灯光"},new []{1,0},140);
        
        DrawEnum("阴影边缘", _CustomShadowsSoftPreoperty,new []{"阴影柔边","阴影硬边"},new []{1,0},140);
        DrawEnum("接受阴影", _ReceiveShadowsPreoperty,new []{"接受阴影关闭","接受阴影开启"},new []{1,0},140);
        
        DrawEnum("烘焙贴图", _CustomLightMapPreoperty,new []{"开启烘焙贴图","关闭烘焙贴图"},new []{1,0},140);
        DrawEnum("光照贴图", _CustomMdirLightMapPreoperty,new []{"多方向光照贴图","单个方向光照贴图"},new []{1,0},140);
        if(_isReflectionProperty!=null)
            DrawEnum("反射(配合脚本)", _isReflectionProperty,new []{"开启反射","关闭反射"},new []{1,0},140);
        if(_isReflectionProperty!=null)
        if (_isReflectionProperty.floatValue == 1)
        {
            m_materialEditor.ShaderProperty(_ReflectionColorProperty, "反射颜色(配合脚本)");
            m_materialEditor.TexturePropertySingleLine(new GUIContent("反射遮罩", "RG>uv扰动,B:遮罩"), _ReflectionMaskProperty);
            m_materialEditor.VectorProperty(_ReflectionUVProperty,"xy>uv流动,z:tiling,w:扰动强度");
            m_materialEditor.VectorProperty(_ReflectionMainUVProperty,"xy>uv流动,z:tiling,w:扰动强度");
        }
        m_materialEditor.ShaderProperty(_SpecularHighlightsPreoperty, "镜面反射");
        m_materialEditor.ShaderProperty(_EnvironmentReflectionsPreoperty, "环境反射");
        
        
        KeyWordInt("_BakeGI_ON", BakedGIProperty);
        
        KeyWordInt("_SPECULARHIGHLIGHTS_OFF", _SpecularHighlightsPreoperty,0);
        KeyWordInt("_ENVIRONMENTREFLECTIONS_OFF", _EnvironmentReflectionsPreoperty,0);
        
        KeyWordInt("_CUSTOMADDITIONAL_LIGHTS_VERTEX", _AddLightVertexPreoperty);
        KeyWordInt("_CUSTOMADDITIONAL_LIGHTS", _AddLightVertexPreoperty,2);
        
        
        KeyWordInt("_ISREFLECTION_ON", _isReflectionProperty);
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
    private void DrawMetallicAoGloss()
    {
        m_materialEditor.TexturePropertySingleLine(new GUIContent("金属纹理","R:金属,G:AO,B:平滑度,A:皮肤SSS遮罩"),MetallicMapPreoperty , MetallicPreoperty);
 
        
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
    }

    public void UpdateMaterial(MaterialProperty[] p)
    {
        BlendModeProperty=FindProperty( "_Blend",p,false);
        CullModePreoperty=FindProperty( "_Cull",p,false);
        ZwriterPreoperty=FindProperty( "_ZWrite",p,false);
        ZTestPreoperty=FindProperty( "_ZTest",p,false);
        MainTexPreoperty = FindProperty("_BaseMap", p,false);
        MainTexTempPreoperty = FindProperty("_MainTex", p,false);
        MainColorPreoperty = FindProperty("_BaseColor", p,false);
        AlphaClipPreoperty = FindProperty("_Cutoff", p,false);
        NormalScalePreoperty = FindProperty("_BumpScale", p,false);
        NormalMapPreoperty = FindProperty("_BumpMap", p,false);
        OcclusionPreoperty = FindProperty("_OcclusionStrength", p,false);
        SmoothnessPreoperty = FindProperty("_Smoothness", p,false);
        MetallicPreoperty = FindProperty("_Metallic", p,false);
        MetallicMapPreoperty = FindProperty("_MetallicGlossMap", p,false);
        EmissionColorPreoperty = FindProperty("_EmissionColor", p,false);
        EmssionMapPreoperty = FindProperty("_EmissionMap", p,false);
        SaturationPreoperty = FindProperty("_Saturation", p,false);
        SturationMaskAndAlphaMapProperty = FindProperty("_SturationMaskAndAlphaMap", p,false);
        CubeMapPreoperty = FindProperty("_CubeMap", p,false);
        CubeMapStrengthPreoperty = FindProperty("_CubeMapStrength", p,false);
        BakedGIProperty = FindProperty("_BeakGI", p,false);
        BakedGIColorPreoperty = FindProperty("_BeakGIColor", p,false);
        CubeMapColorPreoperty = FindProperty("_CubeMapColor", p,false);
        ShadowColorPreoperty = FindProperty("_ShadowColor", p,false);
        _isEmissionCameraLightPreoperty = FindProperty("_isEmissionCameraLight", p,false);
        _FogPreoperty = FindProperty("_CustomFog", p,false);
        _AddLightVertexPreoperty = FindProperty("_AddLightVertex", p,false);
        _CustomShadowsSoftPreoperty = FindProperty("_CustomShadowsSoft", p,false);
        _ReceiveShadowsPreoperty=FindProperty("_ReceiveShadows", p,false);
        
        _SpecularHighlightsPreoperty = FindProperty("_SpecularHighlights", p);
        _EnvironmentReflectionsPreoperty = FindProperty("_EnvironmentReflections", p,false);
        _CustomLightMapPreoperty = FindProperty("_CustomLightMap", p,false);
        _CustomMixedLighingSubPreoperty = FindProperty("_CustomMixedLighingSub", p,false);
        _CustomMdirLightMapPreoperty = FindProperty("_CustomMdirLightMap", p,false);
        _isReflectionProperty = FindProperty("_isReflection", p,false);
        _ReflectionColorProperty = FindProperty("_ReflectionColor", p,false);
        _ReflectionMaskProperty = FindProperty("_ReflectionMask", p,false);
        _ReflectionUVProperty = FindProperty("_ReflectionUV", p,false);
        _ReflectionMainUVProperty = FindProperty("_ReflectionMainUV", p,false);
        _MainLightProperty = FindProperty("_MainLightOn", p,false);
        UnlockingPreoperty = FindProperty("_Unlocking", p,false);
        UnlockingStrengthPreoperty= FindProperty("_UnlockingStrength", p,false);
        _QueueOffsetPreoperty= FindProperty("_QueueOffset", p,false);
        SSSCubeMapColorPreoperty= FindProperty("_SSSCubeMapColor", p,false);
        SSSCubeMapPreoperty= FindProperty("_SSSCubeMap", p,false);
        SSMaskMapPreoperty= FindProperty("_SSSMask", p,false);
        
    }


}


