using UnityEngine;
using UnityEditor;

////////****22.11.21****////////
////////****  ZZW   ****////////
namespace YLib.StyledEditor.StyledMaterial
{
        public class StyledSlideExplainDrawer : StyledBaseDrawer
    {
        private string m_explanText = null;
        private float minVar = 0.0f;
        private float maxVar = 1.0f;

        //public StyledSlideExplainDrawer(){}

        //public StyledSlideExplainDrawer(string explanText)
        //{
        //    this.m_explanText = explanText;
        //}
        public StyledSlideExplainDrawer(string explanText)
        {
            this.m_explanText = explanText;
        }
        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            EditorGUI.BeginChangeCheck();
            var propVar = prop.floatValue;
            GUIContent explanContent = new GUIContent(prop.displayName,m_explanText); 
            propVar = EditorGUILayout.Slider(explanContent,propVar,prop.rangeLimits.x,prop.rangeLimits.y);
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = propVar;
            }
        }
        
    }
}