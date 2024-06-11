using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledTexSTDrawer : StyledBaseDrawer
    {
        public string propName = null;

        public StyledTexSTDrawer(string propName)
        {
            this.propName = propName;
        }

        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return EditorGUIUtility.singleLineHeight * 2;
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            var prop_1 = MaterialEditor.GetMaterialProperty(prop.targets, propName);
            materialEditor.TextureScaleOffsetProperty(position,prop_1);
        }
    }
}
