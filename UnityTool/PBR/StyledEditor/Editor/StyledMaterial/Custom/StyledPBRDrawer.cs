using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledPBRDrawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            LitProperties properties = new LitProperties(prop.targets);

            EditorGUI.BeginChangeCheck();

            MaterialUtil.DoPopup(Styles.workflowModeText, properties.workflowMode, System.Enum.GetNames(typeof(WorkflowMode)), materialEditor);

            DoMetallicSpecularArea(properties, materialEditor );

            if (EditorGUI.EndChangeCheck())
            {
                foreach (Material item in prop.targets)
                {
                    SetKeyword(item);
                }
            }
        }

        private void DoMetallicSpecularArea(LitProperties properties, MaterialEditor materialEditor )
        {
            string[] smoothnessChannelNames;
            bool hasGlossMap = false;
            if (properties.workflowMode == null ||
                (WorkflowMode)properties.workflowMode.floatValue == WorkflowMode.Metallic)
            {
                hasGlossMap = properties.metallicGlossMap.textureValue != null;
                smoothnessChannelNames = Styles.metallicSmoothnessChannelNames;
                materialEditor.TexturePropertySingleLine(Styles.metallicMapText, properties.metallicGlossMap,
                    hasGlossMap ? null : properties.metallic);
            }
            else
            {
                hasGlossMap = properties.specGlossMap.textureValue != null;
                smoothnessChannelNames = Styles.specularSmoothnessChannelNames;
                UnityEditor.BaseShaderGUI.TextureColorProps(materialEditor, Styles.specularMapText, properties.specGlossMap,
                    hasGlossMap ? null : properties.specColor);
            }
            EditorGUI.indentLevel++;
            DoSmoothness(properties,  smoothnessChannelNames);
            EditorGUI.indentLevel--;
        }

        private void DoSmoothness(LitProperties properties,  string[] smoothnessChannelNames)
        {
            //var opaque = ((BaseShaderGUI.SurfaceType)material.GetFloat("_Surface") ==
            //              BaseShaderGUI.SurfaceType.Opaque);
            var opaque = properties.srcBlend.floatValue == 1.0f && properties.dstBlend.floatValue == 0.0f;

            EditorGUI.indentLevel++;
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = properties.smoothness.hasMixedValue;
            var smoothness = EditorGUILayout.Slider(Styles.smoothnessText, properties.smoothness.floatValue, 0f, 1f);
            if (EditorGUI.EndChangeCheck())
                properties.smoothness.floatValue = smoothness;
            EditorGUI.showMixedValue = false;

            if (properties.smoothnessMapChannel != null) // smoothness channel
            {
                EditorGUI.indentLevel++;
                EditorGUI.BeginDisabledGroup(!opaque);
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = properties.smoothnessMapChannel.hasMixedValue;
                var smoothnessSource = (int)properties.smoothnessMapChannel.floatValue;
                if (opaque)
                    smoothnessSource = EditorGUILayout.Popup(Styles.smoothnessMapChannelText, smoothnessSource,
                        smoothnessChannelNames);
                else
                    EditorGUILayout.Popup(Styles.smoothnessMapChannelText, 0, smoothnessChannelNames);
                if (EditorGUI.EndChangeCheck())
                    properties.smoothnessMapChannel.floatValue = smoothnessSource;
                EditorGUI.showMixedValue = false;
                EditorGUI.EndDisabledGroup();
                EditorGUI.indentLevel--;
            }
            EditorGUI.indentLevel--;
        }

        private SmoothnessMapChannel GetSmoothnessMapChannel(Material material)
        {
            int ch = (int)material.GetFloat("_SmoothnessTextureChannel");
            if (ch == (int)SmoothnessMapChannel.AlbedoAlpha)
                return SmoothnessMapChannel.AlbedoAlpha;

            return SmoothnessMapChannel.SpecularMetallicAlpha;
        }

        private void SetKeyword(Material material)
        {
            var hasGlossMap = false;
            var isSpecularWorkFlow = false;
            //var opaque = ((BaseShaderGUI.SurfaceType)material.GetFloat("_Surface") ==
            //              BaseShaderGUI.SurfaceType.Opaque);
            var opaque = material.GetFloat("_SrcBlend") == 1.0f && material.GetFloat("_DstBlend") == 0.0f;

            if (material.HasProperty("_WorkflowMode"))
            {
                isSpecularWorkFlow = (WorkflowMode)material.GetFloat("_WorkflowMode") == WorkflowMode.Specular;
                if (isSpecularWorkFlow)
                    hasGlossMap = material.GetTexture("_SpecGlossMap") != null;
                else
                    hasGlossMap = material.GetTexture("_MetallicGlossMap") != null;
            }
            else
            {
                hasGlossMap = material.GetTexture("_MetallicGlossMap") != null;
            }

            MaterialUtil.SetKeyword(material, "_SPECULAR_SETUP", isSpecularWorkFlow);

            MaterialUtil.SetKeyword(material, "_METALLICSPECGLOSSMAP", hasGlossMap);

            MaterialUtil.SetKeyword(material, "_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A",
                GetSmoothnessMapChannel(material) == SmoothnessMapChannel.AlbedoAlpha && opaque);
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);
        
            if (prop.hasMixedValue)
                return;

            foreach (Material item in prop.targets)
            {
                SetKeyword(item);
            }
        }


        #region Enum And Struct
        private enum WorkflowMode
        {
            Specular = 0,
            Metallic
        }

        private enum SmoothnessMapChannel
        {
            SpecularMetallicAlpha,
            AlbedoAlpha,
        }

        private struct LitProperties
        {
            
            public MaterialProperty srcBlend;
            public MaterialProperty dstBlend;

            public MaterialProperty workflowMode;
            public MaterialProperty smoothness;
            public MaterialProperty smoothnessMapChannel;
            public MaterialProperty metallic;
            public MaterialProperty metallicGlossMap;
            public MaterialProperty specColor;
            public MaterialProperty specGlossMap;

            public LitProperties(Object[] objects)
            {
                srcBlend = MaterialEditor.GetMaterialProperty(objects, "_SrcBlend");
                dstBlend = MaterialEditor.GetMaterialProperty(objects, "_DstBlend");

                workflowMode = MaterialEditor.GetMaterialProperty(objects, "_WorkflowMode");
                smoothness = MaterialEditor.GetMaterialProperty(objects, "_Smoothness");
                smoothnessMapChannel = MaterialEditor.GetMaterialProperty(objects, "_SmoothnessTextureChannel");
                metallic = MaterialEditor.GetMaterialProperty(objects, "_Metallic");
                metallicGlossMap = MaterialEditor.GetMaterialProperty(objects, "_MetallicGlossMap");
                specColor = MaterialEditor.GetMaterialProperty(objects, "_SpecColor");
                specGlossMap = MaterialEditor.GetMaterialProperty(objects, "_SpecGlossMap");
            }
        }

        private static class Styles
        {
            public static GUIContent workflowModeText = new GUIContent("Workflow Mode",
                "Select a workflow that fits your textures. Choose between Metallic or Specular.");

            public static GUIContent specularMapText =
                new GUIContent("Specular Map", "Sets and configures the map and color for the Specular workflow.");

            public static GUIContent metallicMapText =
                new GUIContent("Metallic Map", "Sets and configures the map for the Metallic workflow.");

            public static GUIContent smoothnessText = new GUIContent("Smoothness",
                "Controls the spread of highlights and reflections on the surface.");

            public static GUIContent smoothnessMapChannelText =
                new GUIContent("Source",
                    "Specifies where to sample a smoothness map from. By default, uses the alpha channel for your map.");

            public static readonly string[] metallicSmoothnessChannelNames = { "Metallic Alpha", "Albedo Alpha" };
            public static readonly string[] specularSmoothnessChannelNames = { "Specular Alpha", "Albedo Alpha" };
        }
        #endregion
    }
}