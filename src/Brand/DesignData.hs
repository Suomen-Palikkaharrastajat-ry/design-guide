{-# LANGUAGE OverloadedStrings #-}
-- | Single source of truth for all design token constants shared between
-- Brand.Json (design-guide.json generation) and Brand.ElmGen (Tokens.elm
-- generation). Modify this file to change any value in BOTH outputs.
module Brand.DesignData where

import Brand.Colors
import Data.Text (Text)

-- ---------------------------------------------------------------------------
-- Typography
-- ---------------------------------------------------------------------------

-- | (name, weight, sizeRem, sizePx, lineHeight, letterSpacingEm, cssClass, description)
type TypeScaleRow = (Text, Int, Double, Int, Double, Double, Text, Text)

typeScale :: [TypeScaleRow]
typeScale =
    [ ("Display",   700, 3.0,   48, 1.1,  (-0.02), "text-5xl font-bold",                           "Hero headlines and landing-page titles only.")
    , ("Heading1",  700, 1.875, 30, 1.2,  (-0.01), "text-3xl font-bold",                           "Page-level headings (one per page).")
    , ("Heading2",  700, 1.5,   24, 1.3,  0.0,     "text-2xl font-bold",                           "Section headings.")
    , ("Heading3",  600, 1.25,  20, 1.35, 0.0,     "text-xl font-semibold",                        "Sub-section headings.")
    , ("Body",      400, 1.0,   16, 1.6,  0.0,     "text-base",                                    "Default body copy. Minimum size for accessible reading.")
    , ("BodySmall", 500, 0.875, 14, 1.5,  0.0,     "text-sm font-medium",                          "Secondary labels, UI controls, and form hints.")
    , ("Caption",   400, 0.875, 14, 1.4,  0.02,    "text-sm",                                      "Image captions, footnotes, and metadata.")
    , ("Mono",      400, 0.875, 14, 1.6,  0.0,     "font-mono text-sm",                            "Hex values, IDs, and code snippets.")
    , ("Overline",  600, 0.75,  12, 1.4,  0.08,    "text-xs font-semibold uppercase tracking-wider","Section category labels. Always uppercase.")
    ]

typographyUsageRules :: [Text]
typographyUsageRules =
    [ "Use the Outfit font exclusively; never substitute a system font in designed output."
    , "Minimum body text size is 16px (1rem) at weight 400."
    , "Minimum caption/label text size is 14px (0.875rem); use weight 500 or higher for readability."
    , "Maximum recommended line length is 75 characters for body text."
    , "Heading hierarchy must descend: Display > H1 > H2 > H3. Do not skip levels."
    , "Code and monospace content should use font-family: monospace as a fallback."
    ]

-- ---------------------------------------------------------------------------
-- Spacing
-- ---------------------------------------------------------------------------

-- | (name, multiplier, px, rem, tailwindClass, description)
type SpacingRow = (Text, Int, Int, Double, Text, Text)

spacingScale :: [SpacingRow]
spacingScale =
    [ ("space-1",  1,  4,  0.25, "p-1 / m-1",   "Tight: icon padding, inline gaps.")
    , ("space-2",  2,  8,  0.5,  "p-2 / m-2",   "Compact: button padding, tag gaps.")
    , ("space-3",  3,  12, 0.75, "p-3 / m-3",   "Small: input padding, list item gaps.")
    , ("space-4",  4,  16, 1.0,  "p-4 / m-4",   "Base: card padding, form field gaps.")
    , ("space-6",  6,  24, 1.5,  "p-6 / m-6",   "Medium: section sub-divisions.")
    , ("space-8",  8,  32, 2.0,  "p-8 / m-8",   "Large: card body padding, section gaps.")
    , ("space-12", 12, 48, 3.0,  "p-12 / m-12", "XL: page section vertical margins.")
    , ("space-16", 16, 64, 4.0,  "p-16 / m-16", "2XL: hero and feature block spacing.")
    ]

-- ---------------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------------

-- | (name, ms, description)
motionDurationData :: [(Text, Int, Text)]
motionDurationData =
    [ ("fast",      150,   "Hover states, focus rings, button fills.")
    , ("base",      300,   "Default: card lift, menu open, accordion expand.")
    , ("slow",      500,   "Page-level transitions, large content reveals.")
    , ("logoFrame", 10000, "Animated logo frame hold — do not modify without regenerating assets.")
    ]

-- | (name, cssValue, description)
motionEasingData :: [(Text, Text, Text)]
motionEasingData =
    [ ("standard",   "cubic-bezier(0.4, 0, 0.2, 1)", "Default easing for elements that both enter and exit.")
    , ("decelerate", "cubic-bezier(0, 0, 0.2, 1)",   "Elements entering the screen.")
    , ("accelerate", "cubic-bezier(0.4, 0, 1, 1)",   "Elements leaving the screen.")
    ]

motionUsageRules :: [Text]
motionUsageRules =
    [ "Always provide a prefers-reduced-motion alternative."
    , "Animate transform and opacity only; never animate layout properties."
    , "The animated logo must not autoplay when prefers-reduced-motion: reduce is set."
    , "Use duration.fast for hover/focus, duration.base for reveals, duration.slow for page transitions."
    ]

-- ---------------------------------------------------------------------------
-- Semantic colors
-- ---------------------------------------------------------------------------

-- | (elmConstName, jsonPath, hexValue, cssTailwindClass, description)
type SemanticColorRow = (Text, Text, Text, Text, Text)

semanticColors :: [SemanticColorRow]
semanticColors =
    [ ("colorTextPrimary",   "text.primary",       hexText subtitleOnLight, "text-brand",        "Primary body text; use on white or light-gray backgrounds.")
    , ("colorTextOnDark",    "text.onDark",         hexText subtitleOnDark,  "text-white",        "Text on dark or brand-colored backgrounds.")
    , ("colorTextMuted",     "text.muted",          "#6B7280",               "text-gray-500",     "Secondary labels, captions, helper text on light backgrounds.")
    , ("colorTextSubtle",    "text.subtle",         "#9CA3AF",               "text-gray-400",     "De-emphasised metadata; use only for large text.")
    , ("colorBgPage",        "background.page",     "#FFFFFF",               "bg-white",          "Default page/document background.")
    , ("colorBgDark",        "background.dark",     hexText darkBg,          "bg-brand",          "Dark section backgrounds. Pair with colorTextOnDark.")
    , ("colorBgSubtle",      "background.subtle",   "#F9FAFB",               "bg-gray-50",        "Light card and section backgrounds.")
    , ("colorBgAccent",      "background.accent",   "#F2CD37",               "bg-brand-yellow",   "Brand accent CTA color. Always pair with colorTextPrimary.")
    , ("colorBorderDefault", "border.default",      "#E5E7EB",               "border-gray-200",   "Standard card and section divider borders.")
    , ("colorBorderBrand",   "border.brand",        hexText darkBg,          "border-brand",      "Brand-colored borders, left-accent rules, focus rings.")
    ]

-- ---------------------------------------------------------------------------
-- Layout constants
-- ---------------------------------------------------------------------------

contentWidthPx :: Int
contentWidthPx = 1024

contentWidthTailwind :: Text
contentWidthTailwind = "max-w-5xl"

pagePaddingXPx :: Int
pagePaddingXPx = 16

pagePaddingXTailwind :: Text
pagePaddingXTailwind = "px-4"

pageWrapperClass :: Text
pageWrapperClass = "max-w-5xl mx-auto px-4"

breakpoints :: [(Text, Int)]
breakpoints =
    [ ("sm", 640)
    , ("md", 768)
    , ("lg", 1024)
    , ("xl", 1280)
    ]

borderRadii :: [(Text, Text, Text)]
borderRadii =
    [ ("sm",   "4px",    "rounded")
    , ("md",   "8px",    "rounded-lg")
    , ("lg",   "12px",   "rounded-xl")
    , ("full", "9999px", "rounded-full")
    ]
