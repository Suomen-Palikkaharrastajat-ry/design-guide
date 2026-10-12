{-# LANGUAGE OverloadedStrings #-}

{- | Generate a Tailwind v4 stylesheet fragment from 'DesignGuide'.

Consumers @import this file (dist/design-tokens.css) into their main CSS.
The file contains an @theme block and @utility blocks for the typography scale.
-}
module DesignTokensGen.CssGen (generateCss) where

import Data.Char (isSpace, isUpper)
import Data.List (sortOn)
import Data.Maybe (mapMaybe)
import Data.Text (Text)
import Data.Text qualified as T
import DesignTokensGen.Types
import Numeric (showFFloat)

-- | Generate the full Tailwind v4 CSS tokens fragment.
generateCss :: DesignGuide -> Text
generateCss dg =
    (<> "\n") . T.stripEnd . T.unlines $
        [ "/* Generated file, do not edit."
        , " * Source: design-guide content/*.toml"
        , " * Version: " <> metaVersion (dgMeta dg)
        , " */"
        , ""
        , "@theme {"
        ]
            ++ map indent (themeBody dg)
            ++ [ "}"
               , ""
               ]
            ++ concatMap utilityBlock (tcScale $ dgTypography dg)
  where
    indent l
        | T.null l = l
        | otherwise = "  " <> l

{- | Body of the @theme block.

Only namespaces the design guide owns are emitted. Border radii, shadows,
breakpoints and @--font-mono@ are deliberately left out: Tailwind ships
defaults under the same names (@--radius-md@, @--shadow-sm@,
@--breakpoint-sm@ ...), so emitting ours would silently restyle every
@rounded-*@, @shadow-*@ and responsive utility in every consumer. Those
tokens stay available in the JSON and Elm outputs.
-}
themeBody :: DesignGuide -> [Text]
themeBody dg =
    [ "/* ── Font ─────────────────────────────────────────────────────────────── */"
    , "--font-sans: " <> formatFontFamily (tcFontFamily $ dgTypography dg) <> ";"
    , ""
    , "/* ── Brand palette ────────────────────────────────────────────────────── */"
    ]
        ++ map (formatAlignedVar 28) (brandPaletteVars dg)
        ++ [ ""
           , "/* ── Semantic text ────────────────────────────────────────────────────── */"
           ]
        ++ map (formatAlignedVar 0) (semanticTextVars dg)
        ++ [ ""
           , "/* ── Semantic backgrounds ─────────────────────────────────────────────── */"
           ]
        ++ map (formatAlignedVar 20) (semanticBgVars dg)
        ++ [ ""
           , "/* ── Semantic borders ─────────────────────────────────────────────────── */"
           ]
        ++ map (formatAlignedVar 24) (semanticBorderVars dg)
        ++ [ ""
           , "/* ── Motion ──────────────────────────────────────────────────────────── */"
           ]
        ++ map formatDuration (mcDurations $ dgMotion dg)
        ++ map formatEasing (mcEasings $ dgMotion dg)

formatFontFamily :: [Text] -> Text
formatFontFamily = T.intercalate ", " . map quoteFont
  where
    quoteFont f
        | T.any isUpper f || T.any isSpace f = "\"" <> f <> "\""
        | otherwise = f

brandPaletteVars :: DesignGuide -> [(Text, Text)]
brandPaletteVars dg =
    sortOn (brandOrder . fst) (mapMaybe brandVar (dgBrandColors dg) ++ mapMaybe skinToneVar (dgSkinTones dg))
  where
    brandOrder :: Text -> Int
    brandOrder "--color-brand" = 1
    brandOrder "--color-brand-yellow" = 2
    brandOrder "--color-brand-red" = 3
    brandOrder "--color-brand-green" = 4
    brandOrder "--color-brand-nougat-light" = 5
    brandOrder "--color-brand-nougat" = 6
    brandOrder "--color-brand-nougat-dark" = 7
    brandOrder _ = 99

    brandVar bc = case bcId bc of
        "lego-black" -> Just ("--color-brand", hexText (bcHex bc))
        "lego-yellow" -> Just ("--color-brand-yellow", hexText (bcHex bc))
        "red" -> Just ("--color-brand-red", hexText (bcHex bc))
        "green" -> Just ("--color-brand-green", hexText (bcHex bc))
        "lego-white" -> Nothing
        other -> Just ("--color-brand-" <> other, hexText (bcHex bc))

    skinToneVar st = case stId st of
        "light-nougat" -> Just ("--color-brand-nougat-light", hexText (stHex st))
        "nougat" -> Just ("--color-brand-nougat", hexText (stHex st))
        "dark-nougat" -> Just ("--color-brand-nougat-dark", hexText (stHex st))
        _ -> Nothing

semanticTextVars :: DesignGuide -> [(Text, Text)]
semanticTextVars dg =
    mapMaybe textVar (dgSemanticColors dg)
  where
    textVar sc
        | "text-" `T.isPrefixOf` scId sc = Just ("--color-" <> scId sc, scHex sc)
        | otherwise = Nothing

semanticBgVars :: DesignGuide -> [(Text, Text)]
semanticBgVars dg =
    mapMaybe bgVar (dgSemanticColors dg)
  where
    bgVar sc
        | "background-" `T.isPrefixOf` scId sc =
            Just ("--color-bg-" <> T.drop 11 (scId sc), scHex sc)
        | otherwise = Nothing

semanticBorderVars :: DesignGuide -> [(Text, Text)]
semanticBorderVars dg =
    mapMaybe borderVar (dgSemanticColors dg)
  where
    borderVar sc
        | "border-" `T.isPrefixOf` scId sc = Just ("--color-" <> scId sc, scHex sc)
        | otherwise = Nothing

formatAlignedVar :: Int -> (Text, Text) -> Text
formatAlignedVar targetWidth (name, val) =
    let colon = name <> ":"
        spaces = T.replicate (max 1 (targetWidth - T.length colon)) " "
     in colon <> spaces <> val <> ";"

formatDuration :: MotionDuration -> Text
formatDuration md =
    mdCssVariable md <> ": " <> T.pack (show (mdMs md)) <> "ms;"

formatEasing :: MotionEasing -> Text
formatEasing me =
    let colon = "--ease-" <> meName me <> ":"
        spaces = T.replicate (max 1 (19 - T.length colon)) " "
     in colon
            <> spaces
            <> "cubic-bezier("
            <> formatCoord (meP1x me)
            <> ", "
            <> formatCoord (meP1y me)
            <> ", "
            <> formatCoord (meP2x me)
            <> ", "
            <> formatCoord (meP2y me)
            <> ");"

utilityBlock :: TypeScaleEntry -> [Text]
utilityBlock ts =
    [ "@utility " <> tseCssClass ts <> " {"
    , "  font-size: " <> formatSizeRem (tseSizeRem ts) <> "rem;"
    , "  font-weight: " <> T.pack (show (tseWeight ts)) <> ";"
    , "  line-height: " <> formatLineHeight (tseLineHeight ts) <> ";"
    ]
        ++ ["  font-family: " <> ff <> ";" | Just ff <- [tseFontFamily ts]]
        ++ ["  text-transform: " <> tt <> ";" | Just tt <- [tseTextTransform ts]]
        ++ [ "  letter-spacing: " <> formatLetterSpacing (tseLetterSpacingEm ts) <> "em;"
           | tseLetterSpacingEm ts /= 0.0
           ]
        ++ [ "}"
           , ""
           ]

formatSizeRem :: Double -> Text
formatSizeRem d
    | fromInteger (round d) == d = T.pack (show (round d :: Integer))
    | otherwise = T.pack (showFFloat Nothing d "")

formatLineHeight :: Double -> Text
formatLineHeight d
    | fromInteger (round d) == d = T.pack (show (round d :: Integer))
    | otherwise = T.pack (showFFloat Nothing d "")

formatLetterSpacing :: Double -> Text
formatLetterSpacing d = T.pack (showFFloat Nothing d "")

formatCoord :: Double -> Text
formatCoord d = T.pack (showFFloat (Just 1) d "")
