using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace YLib.StyledEditor.StyledMaterial
{
    public class MaterialCoreGUI : ShaderGUI
    {
        bool multiSelection = false;
        bool showAdvancedSetting = true;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            var material0 = materialEditor.target as Material;
            var materials = materialEditor.targets;

            if (materials.Length > 1)
                multiSelection = true;

            DrawDynamicInspector(material0, materialEditor, props);

        }

        void DrawDynamicInspector(Material material, MaterialEditor materialEditor, MaterialProperty[] props)
        {
            var customPropsList = new List<MaterialProperty>();

            var shaderName = material.shader.name;

            var bannerText = Path.GetFileNameWithoutExtension(shaderName);

            StyledGUI.StyledGUI.DrawInspectorBanner(bannerText);

            bool isShowByCategory = true;
            for (int i = 0; i < props.Length; i++)
            {
                var prop = props[i];

                if (((int)prop.flags & (int)MaterialProperty.PropFlags.HideInInspector) == 1)
                    continue;

                if (prop.name == "unity_Lightmaps")
                    continue;

                if (prop.name == "unity_LightmapsInd")
                    continue;

                if (prop.name == "unity_ShadowMasks")
                    continue;


                if (prop.name.StartsWith("_Category"))
                {
                    isShowByCategory = true;
                    if (prop.name.StartsWith("_Category_Colapsable"))
                    {
                        isShowByCategory = prop.floatValue == 1.0f;
                    }

                    customPropsList.Add(prop);
                }
                else
                {
                    if (isShowByCategory == true)
                    {
                        customPropsList.Add(prop);
                    }
                }
            }

            //Draw Custom GUI
            for (int i = 0; i < customPropsList.Count; i++)
            {
                var displayName = customPropsList[i].displayName;

                materialEditor.ShaderProperty(customPropsList[i], displayName);
            }

            //GUILayout.Space(3.5f);

            //showAdvancedSetting = YLib.StyledGUI.StyledGUI.DrawInspectorCategory("Advanced Settings", showAdvancedSetting, 10,7,true);

            if (isShowByCategory)
            {
                materialEditor.EnableInstancingField();

                materialEditor.RenderQueueField();

                materialEditor.DoubleSidedGIField();
            }
            //GUILayout.Space(10);


            //EditorGUI.indentLevel++;

        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            var renderQueue = material.renderQueue;

            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            material.renderQueue = renderQueue;
        }
    }

}
