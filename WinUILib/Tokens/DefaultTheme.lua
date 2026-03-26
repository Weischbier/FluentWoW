--- WinUILib – Tokens/DefaultTheme.lua
-- Default dark theme token table. All color values are {r, g, b, a} in 0-1.
-------------------------------------------------------------------------------

local lib = WinUILib

local function c(r, g, b, a) return { r, g, b, a or 1 } end

-------------------------------------------------------------------------------
-- Raw colour palette
-------------------------------------------------------------------------------

local RAW = {
    Gray0   = c(0.03, 0.05, 0.08),
    Gray1   = c(0.06, 0.09, 0.13),
    Gray2   = c(0.09, 0.13, 0.19),
    Gray3   = c(0.13, 0.18, 0.26),
    Gray4   = c(0.20, 0.27, 0.38),
    Gray5   = c(0.30, 0.39, 0.52),
    Gray6   = c(0.43, 0.54, 0.68),
    Gray7   = c(0.57, 0.67, 0.79),
    Gray8   = c(0.74, 0.81, 0.90),
    Gray9   = c(0.89, 0.93, 0.98),
    Gray10  = c(0.96, 0.98, 1.00),
    White   = c(1.00, 1.00, 1.00),

    Accent0 = c(0.00, 0.32, 0.68),
    Accent1 = c(0.06, 0.49, 0.88),
    Accent2 = c(0.23, 0.66, 1.00),
    Accent3 = c(0.58, 0.80, 1.00),

    Green   = c(0.16, 0.74, 0.47),
    Yellow  = c(0.98, 0.74, 0.16),
    Orange  = c(0.96, 0.53, 0.14),
    Red     = c(0.89, 0.25, 0.27),
    RedHov  = c(0.96, 0.36, 0.36),
}

-------------------------------------------------------------------------------
-- Semantic token table
-------------------------------------------------------------------------------

local tokens = {
    Color = {
        Base = {
            White = RAW.White,
        },
        Surface = {
            Base     = RAW.Gray0,
            Raised   = RAW.Gray1,
            Overlay  = RAW.Gray2,
            Elevated = RAW.Gray3,
            Stroke   = RAW.Gray4,
        },
        Border = {
            Default = RAW.Gray4,
            Subtle  = RAW.Gray3,
            Focus   = RAW.Accent2,
            Error   = RAW.Red,
        },
        Text = {
            Primary   = RAW.Gray10,
            Secondary = RAW.Gray8,
            Disabled  = RAW.Gray6,
            OnAccent  = RAW.White,
            Error     = RAW.Red,
            Warning   = RAW.Yellow,
            Success   = RAW.Green,
        },
        Icon = {
            Default  = RAW.Gray9,
            Subtle   = RAW.Gray7,
            Disabled = RAW.Gray5,
            OnAccent = RAW.White,
        },
        Accent = {
            Primary = RAW.Accent1,
            Hover   = RAW.Accent2,
            Pressed = RAW.Accent0,
            Light   = RAW.Accent3,
        },
        Feedback = {
            Success    = RAW.Green,
            Warning    = RAW.Yellow,
            Error      = RAW.Red,
            ErrorHover = RAW.RedHov,
            Info       = RAW.Accent1,
        },
        Overlay = {
            Dialog = c(0, 0, 0, 0.72),
            Hover  = c(1, 1, 1, 0.08),
            Press  = c(1, 1, 1, 0.16),
        },
    },

    Spacing = {
        XS   = 2,
        SM   = 4,
        MD   = 8,
        LG   = 12,
        XL   = 16,
        XXL  = 24,
        XXXL = 32,
    },

    Typography = {
        Display  = { font = "Fonts\\MORPHEUS.ttf",  size = 28, flags = "" },
        Header   = { font = "Fonts\\FRIZQT__.TTF",  size = 20, flags = "" },
        Title    = { font = "Fonts\\FRIZQT__.TTF",  size = 16, flags = "" },
        Body     = { font = "Fonts\\ARIALN.TTF",    size = 13, flags = "" },
        BodyBold = { font = "Fonts\\ARIALN.TTF",    size = 13, flags = "OUTLINE" },
        Caption  = { font = "Fonts\\ARIALN.TTF",    size = 11, flags = "" },
        Mono     = { font = "Fonts\\ARIALN.TTF",    size = 11, flags = "" },
    },

    Radii = {
        None = 0,
        SM   = 2,
        MD   = 4,
        LG   = 8,
        Full = 999,
    },

    Motion = {
        Duration = {
            Instant  = 0,
            Fast     = 0.10,
            Normal   = 0.20,
            Slow     = 0.35,
            Entrance = 0.25,
            Exit     = 0.15,
        },
        Easing = {
            Standard   = "Smooth",
            Decelerate = "Smooth",
            Accelerate = "Linear",
            Linear     = "Linear",
        },
    },

    Opacity = {
        Disabled = 0.40,
        Overlay  = 0.60,
        Ghost    = 0.70,
    },

    Layer = {
        Base    = 1,
        Raised  = 2,
        Overlay = 3,
        Dialog  = 4,
        Toast   = 5,
    },

    Density = {
        Compact     = 0.75,
        Normal      = 1.00,
        Comfortable = 1.30,
    },

    Icon = {
        SM = 12,
        MD = 16,
        LG = 20,
    },
}

lib.Tokens:RegisterTheme("Default", tokens)
