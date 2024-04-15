using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledVectorDrawer : StyledBaseDrawer
    {
        private float type = 4.0f;

        public StyledVectorDrawer()
        {

        }

        public StyledVectorDrawer(float type)
        {
            this.type = type;
        }

        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (EditorGUIUtility.wideMode)
            {
                return EditorGUIUtility.singleLineHeight;
            }
            else
            {
                return EditorGUIUtility.singleLineHeight + EditorGUIUtility.singleLineHeight + 3;
            }
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            DrawVectorProperty(position, prop, label);
        }

        public Vector4 DrawVectorProperty(Rect position, MaterialProperty prop, string label)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            var oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;

            Vector4 newValue;
            if (type == 2.0f)
            {
                newValue = EditorGUI.Vector2Field(position, label, prop.vectorValue);
            }
            else if (type == 3.0f)
            {
                newValue = EditorGUI.Vector3Field(position, label, prop.vectorValue);
            }
            else
            {
                newValue = EditorGUI.Vector4Field(position, label, prop.vectorValue);
            }

            EditorGUIUtility.labelWidth = oldLabelWidth;

            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
                prop.vectorValue = newValue;

            return prop.vectorValue;
        }
    }
}
