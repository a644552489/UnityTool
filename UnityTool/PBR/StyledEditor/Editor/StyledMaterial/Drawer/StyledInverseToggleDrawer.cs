using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledInverseToggleDrawer : StyledBaseDrawer
    {
        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;
            bool enabled = EditorGUI.Toggle(position, prop.displayName, prop.floatValue == 0.0f);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = enabled ? 0.0f : 1.0f;
            EditorGUI.showMixedValue = false;
        }
    }
}

