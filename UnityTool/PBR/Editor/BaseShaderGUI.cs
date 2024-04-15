//┌──────────────────────────────────────────────────────────────┐
//│　描   述：
//│　作   者：SmallAnt
//└──────────────────────────────────────────────────────────────┘


using System;
using UnityEditor;
using UnityEngine;

namespace YLib.StyledEditor
{


    public class BaseShaderGUI : ShaderGUI
    {
        private string[] blendModekey = { "_BLENDMODE_DIFFUSE", "_BLENDMODE_TRANSPARENT" };
        private string[] blendModeName = { "Diffuse", "Transparent" };
        private int[] blendModeValues = { 0, 1 };

        protected MaterialEditor m_materialEditor;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            m_materialEditor = materialEditor;
            OnShaderGUI(properties);
        }

        protected virtual void OnShaderGUI(MaterialProperty[] properties)
        {

        }

        protected void DrawEnum(string label, MaterialProperty property, string[] names, int[] values,
            string[] keywords,
            Action<int> ab = null)
        {
            if (property == null) return;
            EditorGUI.BeginChangeCheck();
            string propName = property.displayName;
            bool hasMixedValue = property.hasMixedValue;
            if (hasMixedValue) EditorGUI.showMixedValue = true;
            int value = (int) property.floatValue;
            value = EditorGUILayout.IntPopup(label, value, names, values);
            if (EditorGUI.EndChangeCheck())
            {
                property.floatValue = value;
                ab?.Invoke(value);
                EnableKeywordEnum(keywords, value);
            }

            if (hasMixedValue) EditorGUI.showMixedValue = false;
        }

        protected void DrawEnum(string label, MaterialProperty property, string[] names, int[] values, float width,
            Action<int> ab = null)
        {
            if (property == null) return;
            string propName = property.displayName;
            bool hasMixedValue = property.hasMixedValue;
            if (hasMixedValue) EditorGUI.showMixedValue = true;
            int value = (int) property.floatValue;
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(label);
            value = EditorGUILayout.IntPopup(value, names, values, GUILayout.Width(width));
            EditorGUILayout.EndHorizontal();
            if (EditorGUI.EndChangeCheck())
            {
                property.floatValue = value;
                ab?.Invoke(value);
            }
        }

        protected void EnableKeywordEnum(string[] keywords, int index)
        {
            for (int i = 0; i < keywords.Length; i++)
            {
                if (index == i)
                {
                    foreach (var t in m_materialEditor.targets)
                    {
                        Material m = t as Material;
                        m.EnableKeyword(keywords[i]);
                    }
                }
                else
                {
                    foreach (var t in m_materialEditor.targets)
                    {
                        Material m = t as Material;
                        m.DisableKeyword(keywords[i]);
                    }
                }
            }
        }

        protected void EnableKeyword(string keywordName, bool value)
        {
            if (value)
            {
                foreach (var t in m_materialEditor.targets)
                {
                    Material m = t as Material;
                    m.EnableKeyword(keywordName);
                }
            }
            else
            {
                foreach (var t in m_materialEditor.targets)
                {
                    Material m = t as Material;
                    m.DisableKeyword(keywordName);
                }
            }
        }




    }
}
