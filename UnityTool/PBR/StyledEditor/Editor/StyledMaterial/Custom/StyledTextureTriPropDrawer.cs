using UnityEngine;
using UnityEditor;

////////****22.11.21****////////
////////****  ZZW   ****////////
namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledTextureTriPropDrawer : StyledBaseDrawer
    {
        public string propName_1 = null;
        public string propName_2 = null;
        public string propName_3 = null;
        string[] propNames;

        public StyledTextureTriPropDrawer()
        {

        }

        public StyledTextureTriPropDrawer(string propName_1)
        {
            this.propName_1 = propName_1;
        }

        public StyledTextureTriPropDrawer(string propName_1, string propName_2)
        {
            this.propName_1 = propName_1;
            this.propName_2 = propName_2;
        }
        public StyledTextureTriPropDrawer(string propName_1, string propName_2,string propName_3)
        {
            this.propName_1 = propName_1;
            this.propName_2 = propName_2;
            this.propName_3 = propName_3;
        }

        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void Draw(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor)
        {
            DrawTextureTriLine(position, prop, label, materialEditor, prop.textureValue != null);
        }

        protected void DrawTextureTriLine(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor, bool showExProp)
        {
            if(showExProp)
            {
                if (propName_1 != null && propName_2 != null&& propName_3 != null)
                {
                    propNames = new string[3];
                    propNames[0] = propName_1;
                    propNames[1] = propName_2;
                    propNames[2] = propName_3;
                    DrawTextureMulLine(position, prop, label, materialEditor,3);
                    return;
                }
                else if (propName_1 != null && propName_2 != null)
                {
                    propNames = new string[2];
                    propNames[0] = propName_1;
                    propNames[1] = propName_2;
                    DrawTextureMulLine(position, prop, label, materialEditor,2);
                    return;
                }
                else if(propName_1 != null)
                {
                    propNames = new string[1];
                    propNames[0] = propName_1;
                    DrawTextureMulLine(position, prop, label, materialEditor,1);
                    return;
                }

            }
            else
            {
                DrawTextureMulLine(position, prop, label, materialEditor,0);
                return;
            }
        }

        protected void DrawTextureMulLine(Rect position, MaterialProperty prop, string label, MaterialEditor materialEditor, int exProCount)
        {
            Rect textureRect;
            GUIContent Texlabel;
            Rect sliderRect;
            switch(exProCount)
            {

                case 0:
                    textureRect = EditorGUILayout.GetControlRect(true, 20f, EditorStyles.layerMaskField);
                    Texlabel = new GUIContent(prop.displayName);
                    materialEditor.TexturePropertyMiniThumbnail(textureRect, prop, Texlabel.text, Texlabel.tooltip);
                break;
                case 1:
                    textureRect = EditorGUILayout.GetControlRect(true, 20f, EditorStyles.layerMaskField);
                    Texlabel = new GUIContent(prop.displayName);
                    materialEditor.TexturePropertyMiniThumbnail(textureRect, prop, Texlabel.text, Texlabel.tooltip);
                    sliderRect = new Rect(textureRect.x + EditorGUIUtility.labelWidth,textureRect.y,textureRect.width - EditorGUIUtility.labelWidth,20);
                    EditorGUI.BeginChangeCheck();
                    var prop_1 = MaterialEditor.GetMaterialProperty(prop.targets,propNames[0]);
                    var prop_1_var = prop_1.floatValue;
                    GUIContent prop_1_Text = new GUIContent(propNames[0]);
                    EditorGUI.showMixedValue = prop_1.hasMixedValue;
                    float oldLabelWidth = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth =sliderRect.width - 300f;
                    prop_1_var = EditorGUI.Slider(sliderRect,prop_1_Text,prop_1_var,prop_1.rangeLimits.x,prop_1.rangeLimits.y);
                    EditorGUIUtility.labelWidth = oldLabelWidth;
                    if (EditorGUI.EndChangeCheck())
                    {
                        prop_1.floatValue = prop_1_var;
                    }
                break;
                case 2:
                    textureRect = EditorGUILayout.GetControlRect(true, 40f, EditorStyles.layerMaskField);
                    Rect textureRect_2t = new Rect(textureRect.x,textureRect.y+10,textureRect.width,20);
                    Texlabel = new GUIContent(prop.displayName);
                    materialEditor.TexturePropertyMiniThumbnail(textureRect_2t, prop, Texlabel.text, Texlabel.tooltip);
                    EditorGUI.BeginChangeCheck();
                    //prop 1
                    sliderRect = new Rect(textureRect.x + EditorGUIUtility.labelWidth,textureRect.y,textureRect.width - EditorGUIUtility.labelWidth,20);
                    var prop_21 = MaterialEditor.GetMaterialProperty(prop.targets,propNames[0]);
                    var prop_21_var = prop_21.floatValue;
                    GUIContent prop_21_Text = new GUIContent(propNames[0]);
                    EditorGUI.showMixedValue = prop_21.hasMixedValue;
                    float oldLabelWidth2 = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth =sliderRect.width - 300f;
                    prop_21_var = EditorGUI.Slider(sliderRect,prop_21_Text,prop_21_var,prop_21.rangeLimits.x,prop_21.rangeLimits.y);
                    EditorGUIUtility.labelWidth = oldLabelWidth2;
                    //prop 2
                    sliderRect = new Rect(textureRect.x + EditorGUIUtility.labelWidth,textureRect.y+20,textureRect.width - EditorGUIUtility.labelWidth,20);
                    var prop_22 = MaterialEditor.GetMaterialProperty(prop.targets,propNames[1]);
                    var prop_22_var = prop_22.floatValue;
                    GUIContent prop_22_Text = new GUIContent(propNames[1]);
                    EditorGUI.showMixedValue = prop_22.hasMixedValue;
                    oldLabelWidth2 = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth =sliderRect.width - 300f;
                    prop_22_var = EditorGUI.Slider(sliderRect,prop_22_Text,prop_22_var,prop_22.rangeLimits.x,prop_22.rangeLimits.y);
                    EditorGUIUtility.labelWidth = oldLabelWidth2;

                    if (EditorGUI.EndChangeCheck())
                    {
                        prop_21.floatValue = prop_21_var;
                        prop_22.floatValue = prop_22_var;
                    }
                break;
                case 3:
                    textureRect = EditorGUILayout.GetControlRect(true, 60f, EditorStyles.layerMaskField);
                    Rect textureRect_3t = new Rect(textureRect.x,textureRect.y+20,textureRect.width,20);
                    Texlabel = new GUIContent(prop.displayName);
                    materialEditor.TexturePropertyMiniThumbnail(textureRect_3t, prop, Texlabel.text, Texlabel.tooltip);
                    EditorGUI.BeginChangeCheck();
                    //prop 1
                    sliderRect = new Rect(textureRect.x + EditorGUIUtility.labelWidth,textureRect.y,textureRect.width - EditorGUIUtility.labelWidth,20);
                    var prop_31 = MaterialEditor.GetMaterialProperty(prop.targets,propNames[0]);
                    var prop_31_var = prop_31.floatValue;
                    GUIContent prop_31_Text = new GUIContent(propNames[0]);
                    EditorGUI.showMixedValue = prop_31.hasMixedValue;
                    float oldLabelWidth3 = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth =sliderRect.width - 300f;
                    prop_31_var = EditorGUI.Slider(sliderRect,prop_31_Text,prop_31_var,prop_31.rangeLimits.x,prop_31.rangeLimits.y);
                    EditorGUIUtility.labelWidth = oldLabelWidth3;
                    //prop 2
                    sliderRect = new Rect(textureRect.x + EditorGUIUtility.labelWidth,textureRect.y+20,textureRect.width - EditorGUIUtility.labelWidth,20);
                    var prop_32 = MaterialEditor.GetMaterialProperty(prop.targets,propNames[1]);
                    var prop_32_var = prop_32.floatValue;
                    GUIContent prop_32_Text = new GUIContent(propNames[1]);
                    EditorGUI.showMixedValue = prop_32.hasMixedValue;
                    oldLabelWidth2 = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth =sliderRect.width - 300f;
                    prop_32_var = EditorGUI.Slider(sliderRect,prop_32_Text,prop_32_var,prop_32.rangeLimits.x,prop_32.rangeLimits.y);
                    EditorGUIUtility.labelWidth = oldLabelWidth2;

                    //prop 3
                    sliderRect = new Rect(textureRect.x + EditorGUIUtility.labelWidth,textureRect.y+40,textureRect.width - EditorGUIUtility.labelWidth,20);
                    var prop_33 = MaterialEditor.GetMaterialProperty(prop.targets,propNames[2]);
                    var prop_33_var = prop_33.floatValue;
                    GUIContent prop_33_Text = new GUIContent(propNames[2]);
                    EditorGUI.showMixedValue = prop_33.hasMixedValue;
                    oldLabelWidth2 = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth =sliderRect.width - 300f;
                    prop_33_var = EditorGUI.Slider(sliderRect,prop_33_Text,prop_33_var,prop_33.rangeLimits.x,prop_33.rangeLimits.y);
                    EditorGUIUtility.labelWidth = oldLabelWidth2;

                    if (EditorGUI.EndChangeCheck())
                    {
                        prop_31.floatValue = prop_31_var;
                        prop_32.floatValue = prop_32_var;
                        prop_33.floatValue = prop_33_var;
                    }
                break;

            }
        }


    }
}