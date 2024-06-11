using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledTextureSingleLineDrawer : StyledBaseDrawer
    {
        public string propName_1 = null;
        public string propName_2 = null;

        public StyledTextureSingleLineDrawer()
        {

        }

        public StyledTextureSingleLineDrawer(string propName_1)
        {
            this.propName_1 = propName_1;
        }

        public StyledTextureSingleLineDrawer(string propName_1, string propName_2)
        {
            this.propName_1 = propName_1;
            this.propName_2 = propName_2;
        }

        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            DrawTextureSingleLine(position, prop, label, materialEditor, true);
        }

        protected void DrawTextureSingleLine(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor, bool showExProp)
        {
            if (showExProp)
            {
                if (propName_1 != null && propName_2 != null)
                {
                    var prop_1 = MaterialEditor.GetMaterialProperty(prop.targets, propName_1);
                    var prop_2 = MaterialEditor.GetMaterialProperty(prop.targets, propName_2);
                    materialEditor.TexturePropertySingleLine(new GUIContent(prop.displayName), prop, prop_1, prop_2);
                    return;
                }
                else if (propName_1 != null)
                {
                    var prop_1 = MaterialEditor.GetMaterialProperty(prop.targets, propName_1);
                    materialEditor.TexturePropertySingleLine(new GUIContent(prop.displayName), prop, prop_1);
                    return;
                }
            }

            materialEditor.TexturePropertySingleLine(new GUIContent(prop.displayName), prop);
        }
    }

    public class StyledKeywordTextureSingleLineDrawer : StyledTextureSingleLineDrawer
    {
        public string keyword = null;

        public StyledKeywordTextureSingleLineDrawer(string keyword)
        {
            this.keyword = keyword;
        }

        public StyledKeywordTextureSingleLineDrawer(string keyword, string propName_1)
        {
            this.keyword = keyword;
            this.propName_1 = propName_1;
        }

        public StyledKeywordTextureSingleLineDrawer(string keyword, string propName_1, string propName_2)
        {
            this.keyword = keyword;
            this.propName_1 = propName_1;
            this.propName_2 = propName_2;
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            EditorGUI.BeginChangeCheck();

            DrawTextureSingleLine(position, prop, label, materialEditor, prop.textureValue != null);

            if (EditorGUI.EndChangeCheck() && !prop.hasMixedValue)
            {
                MaterialUtil.SetKeyword(prop, keyword, prop.textureValue != null);
            }
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);

            if (prop.hasMixedValue)
                return;

            MaterialUtil.SetKeyword(prop, keyword, prop.textureValue != null);
        }

    }

    public class StyledTextureSingleLineSTDrawer : StyledBaseDrawer
    {
        protected const float kSpace = 3;

        public StyledTextureSingleLineSTDrawer()
        {

        }

        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (EditorGUIUtility.wideMode)
            {
                return EditorGUIUtility.singleLineHeight;
            }
            else
            {
                return EditorGUIUtility.singleLineHeight + EditorGUIUtility.singleLineHeight + kSpace;
            }
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            DrawTextureSingleLine(position, prop, label, materialEditor, true);
        }

        protected void DrawTextureSingleLine(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor, bool showExProp)
        {

            if (EditorGUIUtility.wideMode)
            {
                materialEditor.TexturePropertyMiniThumbnail(position, prop, prop.displayName, string.Empty);

                position.x += EditorGUIUtility.labelWidth;
                position.width -= EditorGUIUtility.labelWidth;

                DrawST(position, prop, string.Empty);
            }
            else
            {
                position.height -= EditorGUIUtility.singleLineHeight + kSpace;
                materialEditor.TexturePropertyMiniThumbnail(position, prop, prop.displayName, string.Empty);
                position.height += EditorGUIUtility.singleLineHeight + kSpace;

                position.y += EditorGUIUtility.singleLineHeight + kSpace;

                EditorGUI.indentLevel++;
                DrawST(position, prop, string.Empty);
                EditorGUI.indentLevel--;
            }
        }

        protected void DrawST(Rect position, MaterialProperty prop, string label)
        {
            EditorGUI.BeginChangeCheck();

            var oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;

            Vector4 newValue = EditorGUI.Vector4Field(position, label, prop.textureScaleAndOffset);

            EditorGUIUtility.labelWidth = oldLabelWidth;

            if (EditorGUI.EndChangeCheck())
                prop.textureScaleAndOffset = newValue;
        }
    }

    public class StyledKeywordTextureSingleLineSTDrawer : StyledTextureSingleLineSTDrawer
    {
        public string keyword = null;

        public StyledKeywordTextureSingleLineSTDrawer(string keyword)
        {
            this.keyword = keyword;
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            EditorGUI.BeginChangeCheck();
            
            DrawTextureSingleLine(position, prop, label, materialEditor, true);

            if (EditorGUI.EndChangeCheck() && !prop.hasMixedValue)
            {
                MaterialUtil.SetKeyword(prop, keyword, prop.textureValue != null);
            }
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);

            if (prop.hasMixedValue)
                return;

            MaterialUtil.SetKeyword(prop, keyword, prop.textureValue != null);
        }
    }

}
