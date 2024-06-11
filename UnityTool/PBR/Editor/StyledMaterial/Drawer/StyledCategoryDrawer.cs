using UnityEngine;
using UnityEditor;
using System;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledCategoryDrawer : MaterialPropertyDrawer
    {
        public string category;
        public float top;
        public float down;
        public string colapsable;
        public bool begin;

        public StyledCategoryDrawer(string category)
        {
            this.category = category;
            this.colapsable = "false";
            this.top = 10;
            this.down = 10;
        }

        public StyledCategoryDrawer(string category, string colapsable)
        {
            this.category = category;
            this.colapsable = colapsable;
            this.top = 10;
            this.down = 10;
        }

        public StyledCategoryDrawer(string category, float top, float down)
        {
            this.category = category;
            this.colapsable = "false";
            this.top = top;
            this.down = down;
        }

        public StyledCategoryDrawer(string category, string colapsable, float top, float down)
        {
            this.category = category;
            this.colapsable = colapsable;
            this.top = top;
            this.down = down;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            GUI.enabled = true;
            EditorGUI.indentLevel = 0;

            bool isColapsable = false;
            if (colapsable == "true")
            {
                isColapsable = true;
            }

            bool isEnabled = true;
            if (prop.floatValue < 0.5f)
            {
                isEnabled = false;
            }

            isEnabled = YLib.StyledEditor.StyledGUI.StyledGUI.DrawInspectorCategory(category, isEnabled, top, down, isColapsable);

            if (isEnabled)
            {
                prop.floatValue = 1;
            }
            else
            {
                prop.floatValue = 0;
            }
        }



    }
}
