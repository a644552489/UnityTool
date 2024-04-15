using System;
using UnityEditor;
using UnityEngine;


namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledIfShowDecorator : StyledBaseDecorator
    {
        public string propName = null;
        public float value = 1.0f;

        public StyledIfShowDecorator(string propName)
        {
            this.propName = propName;
        }

        public StyledIfShowDecorator(string propName, float value)
        {
            this.propName = propName;
            this.value = value;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            Logic(prop);

            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            
        }

        public void Logic(MaterialProperty prop)
        {
            var prop_1 = MaterialEditor.GetMaterialProperty(prop.targets, propName);

            bool isShow = true;
            bool canEdit = true;

            if (prop_1.hasMixedValue)
            {
                isShow = true;
                canEdit = false;
            }
            else
            {
                if(prop_1.type == MaterialProperty.PropType.Texture)
                {
                    if(prop_1.textureValue == null)
                    {
                        isShow = false;
                    }
                }
                else if (prop_1.type == MaterialProperty.PropType.Float)
                {
                    if (prop_1.floatValue != value)
                        isShow = false;
                }
                
            }

            MaterialEdiotrStateData.showState1.SetState(isShow, canEdit);
        }
    }

}
