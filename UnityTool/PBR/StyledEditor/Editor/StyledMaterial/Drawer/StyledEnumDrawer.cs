using UnityEngine;
using UnityEditor;
using System;
using System.Linq;
using NUnit.Framework.Internal;
using System.Reflection;

namespace YLib.StyledEditor.StyledMaterial
{
    public class StyledEnumDrawer : StyledBaseDrawer
    {
        private readonly GUIContent[] names;
        private readonly float[] values;

        // Single argument: enum type name; entry names & values fetched via reflection
        public StyledEnumDrawer(string enumName)
        {
            var loadedTypes = AppDomain.CurrentDomain.GetAssemblies().SelectMany(x => GetTypesFromAssembly(x)).ToArray();
            try
            {
                var enumType = loadedTypes.FirstOrDefault(
                    x => x.IsEnum && (x.Name == enumName || x.FullName == enumName)
                );
                var enumNames = Enum.GetNames(enumType);
                this.names = new GUIContent[enumNames.Length];
                for (int i = 0; i < enumNames.Length; ++i)
                    this.names[i] = new GUIContent(enumNames[i]);

                var enumVals = Enum.GetValues(enumType);
                values = new float[enumVals.Length];
                for (var i = 0; i < enumVals.Length; ++i)
                    values[i] = (int)enumVals.GetValue(i);
            }
            catch (Exception)
            {
                Debug.LogWarningFormat("Failed to create MaterialEnum, enum {0} not found", enumName);
                throw;
            }
        }

        // name,value,name,value,... pairs: explicit names & values
        public StyledEnumDrawer(string n1, float v1) : this(new[] { n1 }, new[] { v1 }) { }
        public StyledEnumDrawer(string n1, float v1, string n2, float v2) : this(new[] { n1, n2 }, new[] { v1, v2 }) { }
        public StyledEnumDrawer(string n1, float v1, string n2, float v2, string n3, float v3) : this(new[] { n1, n2, n3 }, new[] { v1, v2, v3 }) { }
        public StyledEnumDrawer(string n1, float v1, string n2, float v2, string n3, float v3, string n4, float v4) : this(new[] { n1, n2, n3, n4 }, new[] { v1, v2, v3, v4 }) { }
        public StyledEnumDrawer(string n1, float v1, string n2, float v2, string n3, float v3, string n4, float v4, string n5, float v5) : this(new[] { n1, n2, n3, n4, n5 }, new[] { v1, v2, v3, v4, v5 }) { }
        public StyledEnumDrawer(string n1, float v1, string n2, float v2, string n3, float v3, string n4, float v4, string n5, float v5, string n6, float v6) : this(new[] { n1, n2, n3, n4, n5, n6 }, new[] { v1, v2, v3, v4, v5, v6 }) { }
        public StyledEnumDrawer(string n1, float v1, string n2, float v2, string n3, float v3, string n4, float v4, string n5, float v5, string n6, float v6, string n7, float v7) : this(new[] { n1, n2, n3, n4, n5, n6, n7 }, new[] { v1, v2, v3, v4, v5, v6, v7 }) { }
        public StyledEnumDrawer(string[] enumNames, float[] vals)
        {
            this.names = new GUIContent[enumNames.Length];
            for (int i = 0; i < enumNames.Length; ++i)
                this.names[i] = new GUIContent(enumNames[i]);

            values = new float[vals.Length];
            for (int i = 0; i < vals.Length; ++i)
                values[i] = vals[i];
        }

        public override float GetHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (prop.type != MaterialProperty.PropType.Float && prop.type != MaterialProperty.PropType.Range)
            {
                return 18f * 2.5f;
            }
            return 18f;
        }

        public override void Draw(Rect position, MaterialProperty prop, String label, MaterialEditor editor)
        {
            if (prop.type != MaterialProperty.PropType.Float && prop.type != MaterialProperty.PropType.Range)
            {
                EditorGUI.LabelField(position, new GUIContent("Enum used on a non-float property: " + prop.name), EditorStyles.helpBox);
                return;
            }

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            var value = prop.floatValue;
            int selectedIndex = -1;
            for (var index = 0; index < values.Length; index++)
            {
                var i = values[index];
                if (i == value)
                {
                    selectedIndex = index;
                    break;
                }
            }

            var selIndex = EditorGUI.Popup(position, new GUIContent(label), selectedIndex, names);
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = values[selIndex];
            }
        }

        internal static Type[] GetTypesFromAssembly(Assembly assembly)
        {
            if (assembly == null)
                return new Type[] { };
            try
            {
                return assembly.GetTypes();
            }
            catch (ReflectionTypeLoadException)
            {
                return new Type[] { };
            }
        }
    }
}
