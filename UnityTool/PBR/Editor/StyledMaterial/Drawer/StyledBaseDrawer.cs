using UnityEngine;
using UnityEditor;
using System;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledBaseDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            if (MaterialEdiotrStateData.showState1.IsShow)
            {
                EditorGUI.BeginDisabledGroup(!MaterialEdiotrStateData.showState1.CanEdit);
                Draw(position, prop, label, materiaEditor);
                EditorGUI.EndDisabledGroup();
            }
            MaterialEdiotrStateData.showState1.ReState();
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (MaterialEdiotrStateData.showState1.IsShow)
            {
                return GetHeight(prop,label,editor);
            }
            else
            {
                return 0;
            }
        }

        public virtual void Draw(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {

        }

        public virtual float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return MaterialEditor.GetDefaultPropertyHeight(prop);
        }
    }
}
