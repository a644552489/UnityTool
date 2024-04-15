using UnityEngine;
using UnityEditor;

namespace YLib.StyledEditor.Constants
{
    public static class CONSTANT
    {
        public static Texture2D LogoImage
        {
            get
            {
                return Resources.Load("Logo") as Texture2D;
            }
        }

        public static Texture2D BannerImageBegin
        {
            get
            {
                return Resources.Load("BannerBegin") as Texture2D;
            }
        }

        public static Texture2D BannerImageMiddle
        {
            get
            {
                return Resources.Load("BannerMiddle") as Texture2D;
            }
        }

        public static Texture2D BannerImageEnd
        {
            get
            {
                return Resources.Load("BannerEnd") as Texture2D;
            }
        }

        public static Texture2D CategoryImageBegin
        {
            get
            {
                return Resources.Load("CategoryBegin") as Texture2D;
            }
        }

        public static Texture2D CategoryImageMiddle
        {
            get
            {
                return Resources.Load("CategoryMiddle") as Texture2D;
            }
        }

        public static Texture2D CategoryImageEnd
        {
            get
            {
                return Resources.Load("CategoryEnd") as Texture2D;
            }
        }

        public static Texture2D IconEdit
        {
            get
            {
                return Resources.Load("IconEdit") as Texture2D;
            }
        }

        public static Texture2D IconHelp
        {
            get
            {
                return Resources.Load("IconHelp") as Texture2D;
            }
        }

        public static Color ColorDarkGray
        {
            get
            {
                return new Color(0.27f, 0.27f, 0.27f);
            }
        }

        public static Color ColorLightGray
        {
            get
            {
                return new Color(0.83f, 0.83f, 0.83f);
            }
        }

        public static GUIStyle TitleStyle
        {
            get
            {
                GUIStyle guiStyle = new GUIStyle("label")
                {
                    richText = true,
                    alignment = TextAnchor.MiddleCenter
                };

                return guiStyle;
            }
        }
    }
}

