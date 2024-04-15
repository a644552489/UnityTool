using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledFieldDrawer : StyledBaseDrawer
    {
        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            if (MaterialEdiotrStateData.aligned == MaterialEdiotrStateData.Aligned.Default)
            {
                materialEditor.DefaultShaderProperty(position, prop, prop.displayName);
                return;
            }

            EditorGUI.LabelField(new Rect(position.x, position.y, EditorGUIUtility.labelWidth, 20), prop.displayName);

            if (MaterialEdiotrStateData.aligned == MaterialEdiotrStateData.Aligned.Left)
            {
                position = MaterialEditor.GetLeftAlignedFieldRect(position);
            }
            else
            {
                position = MaterialEditor.GetRightAlignedFieldRect(position);
            }
            MaterialEdiotrStateData.aligned = MaterialEdiotrStateData.Aligned.Default;

            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0;
            materialEditor.DefaultShaderProperty(position, prop, string.Empty);
            EditorGUIUtility.labelWidth = oldLabelWidth;
            return;
        }
    }
}
