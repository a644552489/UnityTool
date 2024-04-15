using System;
using UnityEditor;
using UnityEngine;


namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledAlignedLeftDecorator : StyledBaseDecorator
    {
        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            MaterialEdiotrStateData.aligned = MaterialEdiotrStateData.Aligned.Left;
        }
    }

    public class StyledAlignedRightDecorator : StyledBaseDecorator
    {
        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor materiaEditor)
        {
            MaterialEdiotrStateData.aligned = MaterialEdiotrStateData.Aligned.Right;
        }
    }
}
