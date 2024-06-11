using System;
using UnityEditor;
using UnityEngine;


namespace YLib.StyledEditor.StyledMaterial
{
    public static class MaterialEdiotrStateData
    {
        public enum Aligned
        {
            Default,
            Left,
            Right,
        };

        public class ShowState
        {
            private bool isShow = true;
            private bool canEdit = true;

            public bool IsShow
            {
                get { return isShow; }
                set { isShow = value; }
            }
            public bool CanEdit {
                get { return canEdit; }
                set { canEdit = value; }
            }

            public  ShowState()
            {
                isShow = true;
                canEdit = true;
            }

            public void ReState()
            {
                isShow = true;
                canEdit = true;
            }

            public void SetState(bool isShow, bool canEdit)
            {
                this.isShow = isShow;
                this.canEdit = canEdit;
            }
        }

        public static Aligned aligned = Aligned.Default;
        public static ShowState showState1 = new ShowState();
    }
}