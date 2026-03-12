{-# LANGUAGE OverloadedStrings #-}
-- | Compose a brick-logo SVG with a subtitle text element below it.
--
-- No brand constants are hardcoded here; all text and colours are supplied
-- by the caller.
module Logo.Compose
    ( loadFont
    , composeLogoWith
    , composeLogoFrom
    ) where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as B64
import qualified Data.ByteString.Char8 as BC
import Data.Text (Text)
import qualified Data.Text as T

-- | Gap in SVG px between the brick grid and the subtitle text.
_GAP :: Int
_GAP = 24

-- | Padding below the subtitle text, in SVG px.
_BOTTOM_PAD :: Int
_BOTTOM_PAD = 20

-- | Parse width and height from SVG text.
parseSvgDimensions :: Text -> (Int, Int)
parseSvgDimensions t =
    let wStr = extract "width=\""
        hStr = extract "height=\""
     in (readI wStr, readI hStr)
  where
    extract attr =
        T.takeWhile (/= '"') $
            T.drop (T.length attr) $
                snd $ T.breakOn attr t
    readI s = case reads (T.unpack s) of
        [(n, _)] -> n
        _        -> 0

-- | Load a font file and return it as a @data:@ URI string.
loadFont :: FilePath -> IO String
loadFont fontPath = do
    fontBytes <- BS.readFile fontPath
    return $ "data:font/truetype;base64," ++ BC.unpack (B64.encode fontBytes)

-- | Compose a full logo from an in-memory brick SVG.
--
-- Pure variant: the caller supplies an already-loaded font data URI
-- (see 'loadFont').  'subtitleColor' should be a CSS colour value,
-- e.g. @\"#05131D\"@.
composeLogoWith
    :: String    -- ^ Font data URI (from 'loadFont')
    -> Text      -- ^ Subtitle text
    -> Text      -- ^ Subtitle CSS colour (e.g. @\"#05131D\"@)
    -> Text      -- ^ Input brick SVG text
    -> Int       -- ^ Font size in SVG units
    -> Text
composeLogoWith fontDataUri subtitleText subtitleColor srcText txtSize =
    let (brickW, brickH) = parseSvgDimensions srcText
        canvasW = brickW
        canvasH = brickH + _GAP + txtSize + _BOTTOM_PAD
    in buildFullSvg srcText canvasW canvasH brickH
                    txtSize subtitleColor fontDataUri subtitleText

-- | Convenience wrapper: load the font from disk then call 'composeLogoWith'.
composeLogoFrom
    :: FilePath  -- ^ Outfit variable-font path
    -> Text      -- ^ Subtitle text
    -> Text      -- ^ Subtitle CSS colour (e.g. @\"#05131D\"@)
    -> Text      -- ^ Input brick SVG text
    -> Int       -- ^ Font size in SVG units
    -> IO Text
composeLogoFrom fontPath subtitleText subtitleColor srcText txtSize = do
    fontDataUri <- loadFont fontPath
    return $ composeLogoWith fontDataUri subtitleText subtitleColor srcText txtSize

-- ── Internal SVG builder ─────────────────────────────────────────────────────

buildFullSvg
    :: Text   -- ^ brick SVG source
    -> Int    -- ^ canvasW
    -> Int    -- ^ canvasH
    -> Int    -- ^ brickH
    -> Int    -- ^ txtSize
    -> Text   -- ^ subtitle colour
    -> String -- ^ font data URI
    -> Text   -- ^ subtitle text
    -> Text
buildFullSvg srcText canvasW canvasH brickH txtSize subtitleColor fontDataUri subtitleText =
    T.concat
        [ "<?xml version='1.0' encoding='utf-8'?>\n"
        , "<svg"
        , " xmlns=\"http://www.w3.org/2000/svg\""
        , " width=\""   <> showI canvasW <> "\""
        , " height=\""  <> showI canvasH <> "\""
        , " viewBox=\"0 0 " <> showI canvasW <> " " <> showI canvasH <> "\""
        , ">\n"
        , defsElem
        , "<g>"
        , innerContent srcText
        , "</g>"
        , textElem
        , "</svg>"
        ]
  where
    showI = T.pack . show

    defsElem =
        "  <defs><style>"
            <> T.pack
                (  "@font-face { font-family: 'Outfit';"
                ++ " src: url('" ++ fontDataUri ++ "') format('truetype'); }"
                )
            <> "</style></defs>"

    -- y position: brick_h + GAP + font_size  (as a float, matching Python)
    yFloat = T.pack $ show (fromIntegral (brickH + _GAP + txtSize) :: Double)

    textElem =
        "<text"
            <> " x=\""           <> showI (canvasW `div` 2) <> "\""
            <> " y=\""           <> yFloat <> "\""
            <> " font-family=\"Outfit, sans-serif\""
            <> " font-size=\""   <> showI txtSize <> "\""
            <> " font-weight=\"400\""
            <> " text-anchor=\"middle\""
            <> " fill=\""        <> subtitleColor <> "\""
            <> ">"
            <> subtitleText
            <> "</text>"

    innerContent t =
        let noDecl   = snd $ T.breakOn "<svg" t
            afterOpen = T.drop 1 $ snd $ T.breakOn ">" noDecl
            s         = T.stripEnd afterOpen
            noClose   = if "</svg>" `T.isSuffixOf` s
                            then T.dropEnd (T.length "</svg>") s
                            else s
         in T.stripStart noClose
