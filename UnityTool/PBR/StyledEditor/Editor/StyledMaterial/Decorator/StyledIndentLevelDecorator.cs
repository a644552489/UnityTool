using UnityEngine;
using UnityEditor;
using System;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledIndentLevelAddDecorator : StyledBaseDecorator
    {
        public int value = 1;

        public StyledIndentLevelAddDecorator()
        {
        }

        public StyledIndentLevelAddDecorator(float value)
        {
            this.value = (int)value;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            EditorGUI.indentLevel += value;
        }
    }

    public class StyledIndentLevelSubDecorator : StyledBaseDecorator
    {
        public int value = 1;

        public StyledIndentLevelSubDecorator()
        {
        }

        public StyledIndentLevelSubDecorator(float value)
        {
            this.value = (int)value;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            EditorGUI.indentLevel -= value;
        }
    }
}

