using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering.Universal;

namespace Custom
{
    public class ActorNewLitShader : BaseShaderGUI
    {
        // Properties
        private LitGUI.LitProperties litProperties;
        private ActorNewGUI.ActorProperties actorProperties;

        // collect properties from the material properties
        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            litProperties = new LitGUI.LitProperties(properties);
            actorProperties = new ActorNewGUI.ActorProperties(properties);
        }

        // material changed check
        public override void MaterialChanged(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            SetMaterialKeywords(material, LitGUI.SetMaterialKeywords, ActorNewGUI.SetMaterialKeywords);
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {
            materialEditor.ShaderProperty(actorProperties._ZWrite, "ZWrite");
            base.DrawSurfaceInputs(material);
        
            BaseShaderGUI.DrawNormalArea(materialEditor, litProperties.bumpMapProp, litProperties.bumpScaleProp);


            ActorNewGUI.DrawMSAProperties(actorProperties, materialEditor, material);
            //ActorNewGUI.DrawReflectProperties(actorProperties, materialEditor, material);
            
            DrawEmissionProperties(material, true);

            ActorNewGUI.DrawWaveProperties(actorProperties, materialEditor, material);

            DrawTileOffset(materialEditor, baseMapProp);

      
            //ActorNewGUI.DrawEdgeLightProperties(actorProperties, materialEditor, material);

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
            ActorNewGUI.DrawLaserController(actorProperties, materialEditor , material);

            base.DrawAdvancedOptions(material);
        }
    }
}
