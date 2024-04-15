using UnityEngine;
using UnityEditor;
using System;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledPassOffDrawer : StyledBaseDrawer
    {
        public string passName;

        public StyledPassOffDrawer(string passName)
        {
            this.passName = passName;
        }

        static bool IsPropertyTypeSuitable(MaterialProperty prop)
        {
            return prop.type == MaterialProperty.PropType.Float || prop.type == MaterialProperty.PropType.Range;
        }

        public override void Draw(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            if (!IsPropertyTypeSuitable(prop))
            {
                EditorGUI.LabelField(position, "Toggle used on a non-float property: " + prop.name, EditorStyles.helpBox);
                return;
            }

            EditorGUI.BeginChangeCheck();

            EditorGUI.showMixedValue = prop.hasMixedValue;
            bool value = EditorGUI.Toggle(position, prop.displayName, prop.floatValue == 1.0f);
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = value ? 1.0f : 0.0f;
                SetPassOff(prop, value);
            }
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);
            if (!IsPropertyTypeSuitable(prop))
                return;

            if (prop.hasMixedValue)
                return;

            SetPassOff(prop, prop.floatValue == 1.0f);
        }

        void SetPassOff(MaterialProperty prop, bool off)
        {
            foreach (Material material in prop.targets)
            {
                material.SetShaderPassEnabled(passName, !off);
            }
        }
    }
}
