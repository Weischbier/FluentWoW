--- FluentWoW – Tokens/LightTheme.lua
-- WinUI-inspired light theme token table. All color values are {r, g, b, a} in 0-1.
-- Only Color tokens live here — spacing, typography, radii, motion, opacity,
-- layer, density, and icon sizes are hardcoded design constants in Registry.lua.
-------------------------------------------------------------------------------

local lib = FluentWoW

local function c(r, g, b, a) return { r, g, b, a or 1 } end

-------------------------------------------------------------------------------
-- Raw colour palette (light mode)
-------------------------------------------------------------------------------

local RAW = {
    -- Surface / background grays — lightest to darkest
    Gray0   = c(1.00, 1.00, 1.00),       -- pure white (base surface)
    Gray1   = c(0.98, 0.98, 0.99),       -- near-white
    Gray2   = c(0.95, 0.95, 0.97),       -- very light gray
    Gray3   = c(0.91, 0.91, 0.93),       -- light gray
    Gray4   = c(0.85, 0.85, 0.87),       -- medium-light gray
    Gray5   = c(0.74, 0.74, 0.77),       -- medium gray
    Gray6   = c(0.58, 0.58, 0.62),       -- medium-dark gray
    Gray7   = c(0.42, 0.42, 0.46),       -- dark gray
    Gray8   = c(0.26, 0.26, 0.30),       -- very dark gray
    Gray9   = c(0.14, 0.14, 0.16),       -- near-black
    Gray10  = c(0.08, 0.08, 0.10),       -- darkest text

    White   = c(1.00, 1.00, 1.00),
    Black   = c(0.00, 0.00, 0.00),

    -- Accent blues — slightly deeper for contrast on light backgrounds
    Accent0 = c(0.00, 0.28, 0.60),
    Accent1 = c(0.00, 0.38, 0.78),
    Accent2 = c(0.06, 0.49, 0.88),
    Accent3 = c(0.44, 0.72, 1.00),

    -- Feedback colours — slightly muted for light surfaces
    Green   = c(0.11, 0.60, 0.38),
    Yellow  = c(0.80, 0.58, 0.00),
    Orange  = c(0.78, 0.38, 0.00),
    Red     = c(0.75, 0.16, 0.16),
    RedHov  = c(0.84, 0.24, 0.24),
}

-------------------------------------------------------------------------------
-- Semantic token table
-------------------------------------------------------------------------------

local tokens = {
    Color = {
        Base = {
            White = RAW.White,
            Black = RAW.Black,
        },
        Surface = {
            Base     = RAW.Gray0,         -- white background
            Raised   = RAW.Gray1,         -- cards on white
            Overlay  = RAW.Gray2,         -- drop-downs, flyouts
            Elevated = RAW.Gray3,         -- elevated elements
            Stroke   = RAW.Gray4,         -- surface dividers
        },
        Border = {
            Default = RAW.Gray4,
            Subtle  = RAW.Gray3,
            Focus   = RAW.Accent1,
            Error   = RAW.Red,
        },
        Text = {
            Primary   = RAW.Gray10,       -- near-black on white
            Secondary = RAW.Gray7,
            Tertiary  = RAW.Gray6,
            Disabled  = RAW.Gray5,
            OnAccent  = RAW.White,        -- white text on accent fill
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
            Dialog = c(0, 0, 0, 0.40),   -- lighter scrim on light theme
            Hover  = c(0, 0, 0, 0.04),   -- subtle dark overlay on light bg
            Press  = c(0, 0, 0, 0.08),   -- press overlay
        },
    },
}

lib.Tokens:RegisterTheme("Light", tokens)
