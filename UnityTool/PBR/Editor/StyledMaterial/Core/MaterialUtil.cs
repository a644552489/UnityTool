using System;
using UnityEditor;
using UnityEngine;


namespace YLib.StyledEditor.StyledMaterial
{
    public static class MaterialUtil
    {

        public const float PropertyHeight = -2;

        public static void SetKeyword(MaterialProperty prop, string keyword, bool enabled)
        {
            foreach (Material material in prop.targets)
            {
                SetKeyword(material, keyword, enabled);
            }
        }

        public static void SetKeyword(Material material, string keyword, bool enabled)
        {
            if (enabled)
                material.EnableKeyword(keyword);
            else
                material.DisableKeyword(keyword);
        }

        public static void DoPopup(GUIContent label, MaterialProperty property, string[] options, MaterialEditor materialEditor)
        {
            if (property == null)
                throw new ArgumentNullException("property");

            EditorGUI.showMixedValue = property.hasMixedValue;

            var mode = property.floatValue;
            EditorGUI.BeginChangeCheck();
            mode = EditorGUILayout.Popup(label, (int)mode, options);
            if (EditorGUI.EndChangeCheck())
            {
                materialEditor.RegisterPropertyChangeUndo(label.text);
                property.floatValue = mode;
            }

            EditorGUI.showMixedValue = false;
        }


        public static void test()
        {
            //UnityEngine.Rendering.CullMode.Off
        }
    }
}
