using System;
using UnityEditor;
using UnityEngine;

namespace YLib.StyledEditor.StyledMaterial
{

    public class StyledToggleDrawer : StyledBaseDrawer
    {
        protected readonly string keyword;

        public StyledToggleDrawer()
        {
        }

        public StyledToggleDrawer(string keyword)
        {
            this.keyword = keyword;
        }

        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (!IsPropertyTypeSuitable(prop))
            {
                return 18f * 2.5f;
            }
            return 18f;
        }


        static bool IsPropertyTypeSuitable(MaterialProperty prop)
        {
            return prop.type == MaterialProperty.PropType.Float || prop.type == MaterialProperty.PropType.Range;
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            if (!IsPropertyTypeSuitable(prop))
            {
                EditorGUI.LabelField(position, new GUIContent("Enum used on a non-float property: " + prop.name), EditorStyles.helpBox);
                return;
            }

            EditorGUI.BeginChangeCheck();

            bool value = (Math.Abs(prop.floatValue) > 0.001f);
            EditorGUI.showMixedValue = prop.hasMixedValue;
            value = EditorGUI.Toggle(position, label, value);
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = value ? 1.0f : 0.0f;
                SetKeyword(prop, value);
            }
        }

        protected void SetKeyword(MaterialProperty prop, bool on)
        {
            SetKeywordInternal(prop, on, "_ON");
        }

        protected void SetKeywordInternal(MaterialProperty prop, bool on, string defaultKeywordSuffix)
        {
            // if no keyword is provided, use <uppercase property name> + defaultKeywordSuffix
            string kw = string.IsNullOrEmpty(keyword) ? prop.name.ToUpperInvariant() + defaultKeywordSuffix : keyword;
            // set or clear the keyword
            foreach (Material material in prop.targets)
            {
                if (on)
                    material.EnableKeyword(kw);
                else
                    material.DisableKeyword(kw);
            }
        }

        class StyledToggleOffDrawer : StyledToggleDrawer
        {
            public StyledToggleOffDrawer()
            {
            }

            public StyledToggleOffDrawer(string keyword) : base(keyword)
            {
            }

            protected new void SetKeyword(MaterialProperty prop, bool on)
            {
                SetKeywordInternal(prop, !on, "_OFF");
            }
        }

    }




}
