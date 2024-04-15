using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;

namespace Custom
{
    public class ActorSkinShader : BaseShaderGUI
    {
        // Properties
        private LitGUI.LitProperties litProperties;
        private ActorNewGUI.ActorProperties actorProperties;
        private ActorSkinGUI.ActorSkinProperties skinProperties;

        // collect properties from the material properties
        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            litProperties = new LitGUI.LitProperties(properties);
            actorProperties = new ActorNewGUI.ActorProperties(properties);
            skinProperties = new ActorSkinGUI.ActorSkinProperties(properties);
        }

        // material changed check
        public override void MaterialChanged(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            SetMaterialKeywords(material, (Material material1)=> {
                LitGUI.SetMaterialKeywords(material1);
                ActorNewGUI.SetMaterialKeywords(material1);
                ActorSkinGUI.SetMaterialKeywords(material1);
            });
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);

            BaseShaderGUI.DrawNormalArea(materialEditor, litProperties.bumpMapProp, litProperties.bumpScaleProp);

            ActorNewGUI.DrawMSAProperties(actorProperties, materialEditor, material);
            //ActorNewGUI.DrawReflectProperties(actorProperties, materialEditor, material);
            
            DrawEmissionProperties(material, true);
            DrawTileOffset(materialEditor, baseMapProp);

            //ActorNewGUI.DrawEdgeLightProperties(actorProperties, materialEditor, material);

            ActorSkinGUI.Draw3SArea(skinProperties, materialEditor, material);
            ActorSkinGUI.DrawDetailNormalArea(skinProperties, materialEditor, material);
            BaseShaderGUI.DrawTileOffset(materialEditor, skinProperties._DetailNormalMap);

        }

        // material main advanced options
        public override void DrawAdvancedOptions(Material material)
        {
            if (litProperties.reflections != null && litProperties.highlights != null)
            {
                EditorGUI.BeginChangeCheck();
                materialEditor.ShaderProperty(litProperties.highlights, LitGUI.Styles.highlightsText);
                materialEditor.ShaderProperty(litProperties.reflections, LitGUI.Styles.reflectionsText);
                if (EditorGUI.EndChangeCheck())
                {
                    MaterialChanged(material);
                }
            }

            base.DrawAdvancedOptions(material);
        }
    }
}
