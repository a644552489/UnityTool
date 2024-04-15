using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyleSimpleLitDrawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            SimpleLitProperties properties = new SimpleLitProperties(prop.targets);

            EditorGUI.BeginChangeCheck();

            DoSpecularArea(properties, materialEditor);

            if (EditorGUI.EndChangeCheck())
            {
                foreach (Material item in prop.targets)
                {
                    SetKeyword(item);
                }
            }
        }

        private void DoSpecularArea(SimpleLitProperties properties, MaterialEditor materialEditor)
        {
            SpecularSource specSource = (SpecularSource)properties.specHighlights.floatValue;
            EditorGUI.BeginDisabledGroup(specSource == SpecularSource.NoSpecular);
            UnityEditor.BaseShaderGUI.TextureColorProps(materialEditor, Styles.specularMapText, properties.specGlossMap, properties.specColor, true);
            DoSmoothness(properties);
            EditorGUI.EndDisabledGroup();
        }

        private void DoSmoothness(SimpleLitProperties properties)
        {
            //var opaque = ((BaseShaderGUI.SurfaceType)material.GetFloat("_Surface") ==
            //              BaseShaderGUI.SurfaceType.Opaque);
            var opaque = properties.srcBlend.floatValue == 1.0f && properties.dstBlend.floatValue == 0.0f;

            EditorGUI.indentLevel += 2;

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = properties.smoothness.hasMixedValue;
            var smoothnessSource = (int)properties.smoothnessMapChannel.floatValue;
            var smoothness = properties.smoothness.floatValue;
            smoothness = EditorGUILayout.Slider(Styles.smoothnessText, smoothness, 0f, 1f);
            if (EditorGUI.EndChangeCheck())
            {
                properties.smoothness.floatValue = smoothness;
            }
            EditorGUI.showMixedValue = false;

            EditorGUI.indentLevel++;
            EditorGUI.BeginDisabledGroup(!opaque);
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = properties.smoothnessMapChannel.hasMixedValue;
            if (opaque)
                smoothnessSource = EditorGUILayout.Popup(Styles.smoothnessMapChannelText, smoothnessSource, System.Enum.GetNames(typeof(SmoothnessMapChannel)));
            else
                EditorGUILayout.Popup(Styles.smoothnessMapChannelText, 0, System.Enum.GetNames(typeof(SmoothnessMapChannel)));
            if (EditorGUI.EndChangeCheck())
                properties.smoothnessMapChannel.floatValue = smoothnessSource;
            EditorGUI.showMixedValue = false;
            EditorGUI.indentLevel -= 3;
            EditorGUI.EndDisabledGroup();
        }

        private void SetKeyword(Material material)
        {
            //var opaque = ((BaseShaderGUI.SurfaceType)material.GetFloat("_Surface") ==
            //              BaseShaderGUI.SurfaceType.Opaque);
            var opaque = material.GetFloat("_SrcBlend") == 1.0f && material.GetFloat("_DstBlend") == 0.0f;
            SpecularSource specSource = (SpecularSource)material.GetFloat("_SpecularHighlights");
            if (specSource == SpecularSource.NoSpecular)
            {
                MaterialUtil.SetKeyword(material, "_SPECGLOSSMAP", false);
                MaterialUtil.SetKeyword(material, "_SPECULAR_COLOR", false);
                MaterialUtil.SetKeyword(material, "_GLOSSINESS_FROM_BASE_ALPHA", false);
            }
            else
            {
                var smoothnessSource = (SmoothnessMapChannel)material.GetFloat("_SmoothnessSource");
                bool hasMap = material.GetTexture("_SpecGlossMap");
                MaterialUtil.SetKeyword(material, "_SPECGLOSSMAP", hasMap);
                MaterialUtil.SetKeyword(material, "_SPECULAR_COLOR", !hasMap);
                if (opaque)
                    MaterialUtil.SetKeyword(material, "_GLOSSINESS_FROM_BASE_ALPHA", smoothnessSource == SmoothnessMapChannel.AlbedoAlpha);
                else
                    MaterialUtil.SetKeyword(material, "_GLOSSINESS_FROM_BASE_ALPHA", false);

                string color;
                if (smoothnessSource != SmoothnessMapChannel.AlbedoAlpha || !opaque)
                    color = "_SpecColor";
                else
                    color = "_BaseColor";

                var col = material.GetColor(color);
                col.a = material.GetFloat("_Smoothness");
                material.SetColor(color, col);
            }
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
        public enum SpecularSource
        {
            SpecularTextureAndColor,
            NoSpecular,
        }

        public enum SmoothnessMapChannel
        {
            SpecularAlpha,
            AlbedoAlpha,
        }

        private struct SimpleLitProperties
        {

            public MaterialProperty srcBlend;
            public MaterialProperty dstBlend;

            public MaterialProperty specColor;
            public MaterialProperty specGlossMap;
            public MaterialProperty specHighlights;
            public MaterialProperty smoothnessMapChannel;
            public MaterialProperty smoothness;

            public SimpleLitProperties(Object[] objects)
            {
                srcBlend = MaterialEditor.GetMaterialProperty(objects, "_SrcBlend");
                dstBlend = MaterialEditor.GetMaterialProperty(objects, "_DstBlend");
                // Surface Input Props
                specColor = MaterialEditor.GetMaterialProperty(objects, "_SpecColor");
                specGlossMap = MaterialEditor.GetMaterialProperty(objects, "_SpecGlossMap");
                specHighlights = MaterialEditor.GetMaterialProperty(objects, "_SpecularHighlights");
                smoothnessMapChannel = MaterialEditor.GetMaterialProperty(objects, "_SmoothnessSource");
                smoothness = MaterialEditor.GetMaterialProperty(objects, "_Smoothness");
            }
        }

        private static class Styles
        {
            public static GUIContent specularMapText =
                new GUIContent("Specular Map", "Sets and configures a Specular map and color for your Material.");

            public static GUIContent smoothnessText = new GUIContent("Smoothness",
                "Controls the spread of highlights and reflections on the surface.");

            public static GUIContent smoothnessMapChannelText =
                new GUIContent("Source",
                    "Specifies where to sample a smoothness map from. By default, uses the alpha channel for your map.");

            public static GUIContent highlightsText = new GUIContent("Specular Highlights",
                "When enabled, the Material reflects the shine from direct lighting.");
        }
        #endregion
    }
}