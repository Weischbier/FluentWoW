--- WinUILib – Tokens/DefaultTheme.lua
-- Default dark theme token table. All color values are {r, g, b, a} in 0-1.
-------------------------------------------------------------------------------

local lib = WinUILib

local function c(r, g, b, a) return { r, g, b, a or 1 } end

-------------------------------------------------------------------------------
-- Raw colour palette
-------------------------------------------------------------------------------

local RAW = {
    Gray0   = c(0.07, 0.07, 0.08),
    Gray1   = c(0.10, 0.10, 0.11),
    Gray2   = c(0.13, 0.13, 0.14),
    Gray3   = c(0.17, 0.17, 0.19),
    Gray4   = c(0.22, 0.22, 0.24),
    Gray5   = c(0.28, 0.28, 0.32),
    Gray6   = c(0.36, 0.36, 0.40),
    Gray7   = c(0.50, 0.50, 0.55),
    Gray8   = c(0.68, 0.68, 0.72),
    Gray9   = c(0.85, 0.85, 0.88),
    Gray10  = c(0.95, 0.95, 0.97),
    White   = c(1.00, 1.00, 1.00),

    Accent0 = c(0.00, 0.45, 0.75),
    Accent1 = c(0.05, 0.55, 0.88),
    Accent2 = c(0.15, 0.65, 1.00),
    Accent3 = c(0.40, 0.78, 1.00),

    Green   = c(0.20, 0.80, 0.40),
    Yellow  = c(1.00, 0.80, 0.10),
    Orange  = c(1.00, 0.50, 0.10),
    Red     = c(0.90, 0.20, 0.20),
    RedHov  = c(1.00, 0.30, 0.30),
}

-------------------------------------------------------------------------------
-- Semantic token table
-------------------------------------------------------------------------------

local tokens = {
    Color = {
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
            Dialog = c(0, 0, 0, 0.60),
            Hover  = c(1, 1, 1, 0.06),
            Press  = c(1, 1, 1, 0.12),
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
