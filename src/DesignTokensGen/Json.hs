{-# LANGUAGE OverloadedStrings #-}

{- | Generate W3C Design Tokens 2025.10 compliant JSON.

Output format follows the DTCG specification:
  - \$type, \$value, \$description on every token
  - Color: {colorSpace: "srgb", components: [r,g,b], hex: "#…"}
  - Dimension: "Npx" or "Nrem"
  - Duration: "Nms"
  - CubicBezier: [p1x, p1y, p2x, p2y]
  - FontFamily: ["Outfit", "system-ui", "sans-serif"]
-}
module DesignTokensGen.Json (generateTokensJson) where

import Data.Aeson (Value (..), object, (.=))
import Data.Aeson.Encode.Pretty (encodePretty)
import Data.Aeson.Key (Key)
import Data.Aeson.Key qualified as Key
import Data.ByteString.Lazy (ByteString)
import Data.Char (digitToInt, toLower)
import Data.Text (Text)
import Data.Text qualified as T
import DesignTokensGen.Types

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

generateTokensJson :: DesignGuide -> ByteString
generateTokensJson dg =
    encodePretty $
        object
            [ "color" .= colorGroup dg
            , "typography" .= typographyGroup dg
            , "spacing" .= spacingGroup dg
            , "motion" .= motionGroup dg
            , "effects" .= effectsGroup dg
            , "accessibility" .= accessibilityGroup dg
            , "opacity" .= opacityGroup dg
            , "component" .= componentGroup dg
            ]

-- ---------------------------------------------------------------------------
-- Color group
-- ---------------------------------------------------------------------------

colorGroup :: DesignGuide -> Value
colorGroup dg =
    object
        [ "brand" .= object (map brandToken $ dgBrandColors dg)
        , "skin-tone" .= object (map skinToneToken $ dgSkinTones dg)
        , "rainbow" .= object (map rainbowToken $ dgRainbowColors dg)
        , "semantic" .= object (map semanticToken $ dgSemanticColors dg)
        ]

brandToken :: BrandColor -> (Key, Value)
brandToken bc =
    ( Key.fromText (bcId bc)
    , object
        [ "$type" .= t "color"
        , "$value" .= colorValue (hexText $ bcHex bc)
        , "$description" .= bcDescription bc
        , "$extensions"
            .= object
                [ "fi.palikkaharrastajat.name" .= bcName bc
                , "fi.palikkaharrastajat.usage" .= bcUsage bc
                , "fi.palikkaharrastajat.wcag" .= map wcagValue (bcWcag bc)
                ]
        ]
    )
  where
    t :: Text -> Text
    t = id

skinToneToken :: SkinTone -> (Key, Value)
skinToneToken st =
    ( Key.fromText (stId st)
    , object
        [ "$type" .= t "color"
        , "$value" .= colorValue (hexText $ stHex st)
        , "$description" .= stDescription st
        , "$extensions"
            .= object
                [ "fi.palikkaharrastajat.name" .= stName st
                , "fi.palikkaharrastajat.wcag" .= map wcagValue (stWcag st)
                ]
        ]
    )
  where
    t :: Text -> Text
    t = id

rainbowToken :: RainbowColor -> (Key, Value)
rainbowToken rc =
    ( Key.fromText (rcId rc)
    , object
        [ "$type" .= t "color"
        , "$value" .= colorValue (hexText $ rcHex rc)
        , "$description" .= rcDescription rc
        , "$extensions"
            .= object ["fi.palikkaharrastajat.name" .= rcName rc]
        ]
    )
  where
    t :: Text -> Text
    t = id

semanticToken :: SemanticColor -> (Key, Value)
semanticToken sc =
    ( Key.fromText (scId sc)
    , object
        [ "$type" .= t "color"
        , "$value" .= colorValue (scHex sc)
        , "$description" .= scDescription sc
        ]
    )
  where
    t :: Text -> Text
    t = id

wcagValue :: WcagContrast -> Value
wcagValue w =
    object
        [ "on" .= wcagOn w
        , "ratio" .= wcagRatio w
        , "rating" .= wcagRating w
        ]

-- ---------------------------------------------------------------------------
-- Typography group
-- ---------------------------------------------------------------------------

typographyGroup :: DesignGuide -> Value
typographyGroup dg =
    let tc = dgTypography dg
     in object
            [ "font-family"
                .= object
                    [ "$type" .= t "fontFamily"
                    , "$value" .= tcFontFamily tc
                    ]
            , "scale" .= object (map scaleToken $ tcScale tc)
            ]
  where
    t :: Text -> Text
    t = id

scaleToken :: TypeScaleEntry -> (Key, Value)
scaleToken ts =
    ( Key.fromText (tseName ts)
    , object
        [ "$type" .= t "typography"
        , "$value"
            .= object
                [ "fontFamily" .= t "Outfit"
                , "fontWeight" .= tseWeight ts
                , "fontSize" .= (T.pack (show (tseSizeRem ts)) <> "rem")
                , "lineHeight" .= tseLineHeight ts
                , "letterSpacing" .= (T.pack (show (tseLetterSpacingEm ts)) <> "em")
                ]
        , "$description" .= tseDescription ts
        ]
    )
  where
    t :: Text -> Text
    t = id

-- ---------------------------------------------------------------------------
-- Spacing group
-- ---------------------------------------------------------------------------

spacingGroup :: DesignGuide -> Value
spacingGroup dg =
    let sp = dgSpacing dg
     in object
            [ "base-unit"
                .= object
                    [ "$type" .= t "dimension"
                    , "$value" .= (T.pack (show (spcBaseUnit sp)) <> "px")
                    ]
            , "scale" .= object (map spacingToken $ spcScale sp)
            , "breakpoint" .= object (map breakpointToken $ spcBreakpoints sp)
            , "border-radius" .= object (map borderRadiusToken $ spcBorderRadii sp)
            ]
  where
    t :: Text -> Text
    t = id

spacingToken :: SpacingStep -> (Key, Value)
spacingToken ss =
    ( Key.fromText (ssName ss)
    , object
        [ "$type" .= t "dimension"
        , "$value" .= (T.pack (show (ssPx ss)) <> "px")
        , "$description" .= ssDescription ss
        ]
    )
  where
    t :: Text -> Text
    t = id

breakpointToken :: Breakpoint -> (Key, Value)
breakpointToken bp =
    ( Key.fromText (bpName bp)
    , object
        [ "$type" .= t "dimension"
        , "$value" .= (T.pack (show (bpPx bp)) <> "px")
        ]
    )
  where
    t :: Text -> Text
    t = id

borderRadiusToken :: BorderRadius -> (Key, Value)
borderRadiusToken br =
    ( Key.fromText (brName br)
    , object
        [ "$type" .= t "dimension"
        , "$value" .= (T.pack (show (brPx br)) <> "px")
        ]
    )
  where
    t :: Text -> Text
    t = id

-- ---------------------------------------------------------------------------
-- Motion group
-- ---------------------------------------------------------------------------

motionGroup :: DesignGuide -> Value
motionGroup dg =
    let mc = dgMotion dg
     in object
            [ "duration" .= object (map durationToken $ mcDurations mc)
            , "easing" .= object (map easingToken $ mcEasings mc)
            ]

durationToken :: MotionDuration -> (Key, Value)
durationToken md =
    ( Key.fromText (mdName md)
    , object
        [ "$type" .= t "duration"
        , "$value" .= (T.pack (show (mdMs md)) <> "ms")
        , "$description" .= mdDescription md
        ]
    )
  where
    t :: Text -> Text
    t = id

easingToken :: MotionEasing -> (Key, Value)
easingToken me =
    ( Key.fromText (meName me)
    , object
        [ "$type" .= t "cubicBezier"
        , "$value" .= [meP1x me, meP1y me, meP2x me, meP2y me]
        , "$description" .= meDescription me
        ]
    )
  where
    t :: Text -> Text
    t = id

-- ---------------------------------------------------------------------------
-- Effects group
-- ---------------------------------------------------------------------------

effectsGroup :: DesignGuide -> Value
effectsGroup dg =
    object
        [ "shadow" .= object (map shadowToken $ ecShadows $ dgEffects dg)
        , "z-index" .= object (map zIndexToken $ ecZIndices $ dgEffects dg)
        ]

shadowToken :: Shadow -> (Key, Value)
shadowToken s =
    ( Key.fromText (shName s)
    , object
        [ "$type" .= t "shadow"
        , "$value" .= shValue s
        , "$description" .= shDescription s
        , "$extensions"
            .= object
                [ "fi.palikkaharrastajat.tailwind-class" .= shTailwindClass s
                ]
        ]
    )
  where
    t :: Text -> Text
    t = id

zIndexToken :: ZIndex -> (Key, Value)
zIndexToken z =
    ( Key.fromText (ziName z)
    , object
        [ "$type" .= t "number"
        , "$value" .= ziValue z
        , "$description" .= ziDescription z
        ]
    )
  where
    t :: Text -> Text
    t = id

-- ---------------------------------------------------------------------------
-- Accessibility group
-- ---------------------------------------------------------------------------

accessibilityGroup :: DesignGuide -> Value
accessibilityGroup dg =
    object
        [ "focus-ring" .= object (map focusRingToken $ acFocusRings $ dgAccessibility dg)
        ]

focusRingToken :: FocusRing -> (Key, Value)
focusRingToken fr =
    ( Key.fromText (frName fr)
    , object
        [ "$type" .= t "object"
        , "$value"
            .= object
                [ "width-px" .= frWidthPx fr
                , "offset-px" .= frOffsetPx fr
                , "color" .= colorValue (frColor fr)
                ]
        , "$description" .= frDescription fr
        , "$extensions"
            .= object
                [ "fi.palikkaharrastajat.tailwind-class" .= frTailwindClass fr
                ]
        ]
    )
  where
    t :: Text -> Text
    t = id

-- ---------------------------------------------------------------------------
-- Opacity group
-- ---------------------------------------------------------------------------

opacityGroup :: DesignGuide -> Value
opacityGroup dg =
    object (map opacityToken $ ocScale $ dgOpacity dg)

opacityToken :: OpacityStep -> (Key, Value)
opacityToken os =
    ( Key.fromText (osName os)
    , object
        [ "$type" .= t "number"
        , "$value" .= osValue os
        , "$description" .= osDescription os
        ]
    )
  where
    t :: Text -> Text
    t = id

-- ---------------------------------------------------------------------------
-- Component group
-- ---------------------------------------------------------------------------

componentGroup :: DesignGuide -> Value
componentGroup dg = object (map compToken $ dgComponents dg)

compToken :: ComponentSpec -> (Key, Value)
compToken cs =
    ( Key.fromText (csName cs)
    , object
        [ "$description" .= csDescription cs
        , "$extensions"
            .= object
                [ "fi.palikkaharrastajat.props" .= csProps cs
                , "fi.palikkaharrastajat.token-deps" .= csTokenDependencies cs
                ]
        ]
    )

-- ---------------------------------------------------------------------------
-- Hex → sRGB components
-- ---------------------------------------------------------------------------

colorValue :: Text -> Value
colorValue hex =
    let (r, g, b) = hexToRgb hex
     in object
            [ "colorSpace" .= t "srgb"
            , "components" .= [r, g, b]
            , "hex" .= hex
            ]
  where
    t :: Text -> Text
    t = id

hexToRgb :: Text -> (Double, Double, Double)
hexToRgb hex =
    let h = map toLower . T.unpack $ T.dropWhile (== '#') hex
        digits = case length h of
            6 -> h
            3 -> concatMap (\c -> [c, c]) h
            _ -> error $ "Invalid hex color: " ++ T.unpack hex
     in case digits of
            [r1, r2, g1, g2, b1, b2] -> (toD r1 r2, toD g1 g2, toD b1 b2)
            _ -> error $ "Invalid hex color: " ++ T.unpack hex
  where
    toD a b = fromIntegral (digitToInt a * 16 + digitToInt b) / 255.0
