{-# LANGUAGE OverloadedStrings #-}
module Brand.Json (generateDesignGuide) where

import Brand.Colors
import Brand.DesignData
import qualified Data.Aeson as A
import Data.Aeson ((.=))
import Data.Aeson.Types (Pair)
import qualified Data.Aeson.Encode.Pretty as AP
import qualified Data.ByteString.Lazy as BSL
import Data.Text (Text)
import qualified Data.Aeson.Key as AK
import qualified Data.Text as T

baseUrl :: Text
baseUrl = "https://logo.palikkaharrastajat.fi"

asset :: Text -> A.Value
asset path = A.object ["file" .= path, "url" .= (baseUrl <> "/" <> path)]

assetWith :: Text -> [Pair] -> A.Value
assetWith path extra = A.object $ ["file" .= path, "url" .= (baseUrl <> "/" <> path)] ++ extra

-- ---------------------------------------------------------------------------
-- Colors
-- ---------------------------------------------------------------------------

buildColors :: A.Value
buildColors =
    A.object
        [ "brand" .= A.toJSON
            [ A.object
                [ "hex" .= ("#05131D" :: Text)
                , "id" .= ("lego-black" :: Text)
                , "name" .= ("Black" :: Text)
                , "$description" .= ("Primary brand color. Never hard-code this hex — use Brand.Colors in Haskell or Brand.Tokens in Elm." :: Text)
                , "usage" .= (["features", "text", "dark background"] :: [Text])
                , "wcag" .= A.object ["onWhite" .= (17.3 :: Double), "onWhiteRating" .= ("AAA" :: Text), "onYellow" .= (11.5 :: Double), "onYellowRating" .= ("AAA" :: Text)]
                ]
            , A.object
                [ "hex" .= ("#FFFFFF" :: Text)
                , "id" .= ("lego-white" :: Text)
                , "name" .= ("White" :: Text)
                , "$description" .= ("Use for eye highlights and text on dark/brand-colored backgrounds." :: Text)
                , "usage" .= (["eye highlights", "text on dark background"] :: [Text])
                , "wcag" .= A.object ["onBrand" .= (17.3 :: Double), "onBrandRating" .= ("AAA" :: Text)]
                ]
            , A.object
                [ "hex" .= ("#C91A09" :: Text)
                , "id" .= ("red" :: Text)
                , "name" .= ("Red" :: Text)
                , "$description" .= ("Accent colour from the Blacktron series. Use for highlights, danger states, and emphasis." :: Text)
                , "usage" .= (["accent", "danger", "highlights"] :: [Text])
                , "wcag" .= A.object ["onWhite" .= (5.0 :: Double), "onWhiteRating" .= ("AA" :: Text), "onBlack" .= (4.2 :: Double), "onBlackRating" .= ("AA" :: Text)]
                ]
            ]
        , "skinTones" .= A.toJSON
            [ A.object
                [ "hex" .= hexText h, "id" .= sid, "name" .= sname
                , "$description" .= sdesc, "description" .= sdesc
                , "wcag" .= wcagObj sid
                ]
            | (sid, sname, h, sdesc) <- skinTonesWithDesc
            ]
        , "rainbow" .= A.toJSON
            [ A.object
                [ "hex" .= hexText h, "name" .= rname
                , "$description" .= ("Decorative use only. Do not use as text color on light backgrounds." :: Text)
                , "description" .= rdesc, "decorativeOnly" .= True
                ]
            | (_, rname, h, rdesc) <- rainbowColors
            ]
        , "text" .= A.object ["onLight" .= hexText subtitleOnLight, "onDark" .= hexText subtitleOnDark]
        , "darkBackground" .= hexText darkBg
        , "semantic" .= buildSemanticColors
        ]
  where
    skinTonesWithDesc :: [(Text, Text, Hex, Text)]
    skinTonesWithDesc =
        [ ("yellow",       "Yellow",       Hex "#F2CD37", "Classic LEGO minifig yellow. Brand accent color.")
        , ("light-nougat", "Light Nougat", Hex "#F6D7B3", "Light skin tone. Contrast on white: 1.4:1 — decorative only.")
        , ("nougat",       "Nougat",       Hex "#D09168", "Medium skin tone. Contrast on black: 6.7:1 (AA).")
        , ("dark-nougat",  "Dark Nougat",  Hex "#AD6140", "Dark skin tone. Contrast on white: 4.4:1 (AA large text).")
        ]
    wcagObj sid = case sid of
        "yellow"       -> A.object ["onWhite" .= (1.5 :: Double), "onWhiteRating" .= ("fail" :: Text), "onBlack" .= (11.5 :: Double), "onBlackRating" .= ("AAA" :: Text)]
        "light-nougat" -> A.object ["onWhite" .= (1.4 :: Double), "onWhiteRating" .= ("fail" :: Text), "onBlack" .= (12.4 :: Double), "onBlackRating" .= ("AAA" :: Text)]
        "nougat"       -> A.object ["onWhite" .= (2.6 :: Double), "onWhiteRating" .= ("fail" :: Text), "onBlack" .= (6.7 :: Double),  "onBlackRating" .= ("AA" :: Text)]
        "dark-nougat"  -> A.object ["onWhite" .= (4.4 :: Double), "onWhiteRating" .= ("AA" :: Text),   "onBlack" .= (4.0 :: Double),  "onBlackRating" .= ("AA" :: Text)]
        _              -> A.object []

buildSemanticColors :: A.Value
buildSemanticColors =
    A.object
        [ "text" .= A.object
            [ "primary" .= tok "text.primary"
            , "onDark"  .= tok "text.onDark"
            , "muted"   .= tok "text.muted"
            , "subtle"  .= tok "text.subtle"
            ]
        , "background" .= A.object
            [ "page"   .= tok "background.page"
            , "dark"   .= tok "background.dark"
            , "subtle" .= tok "background.subtle"
            , "accent" .= tok "background.accent"
            ]
        , "border" .= A.object
            [ "default" .= tok "border.default"
            , "brand"   .= tok "border.brand"
            ]
        ]
  where
    tok path =
        case [ (val, tw, desc) | (_, p, val, tw, desc) <- semanticColors, p == path ] of
            ((val, tw, desc) : _) ->
                A.object ["$value" .= val, "$type" .= ("color" :: Text), "tailwind" .= tw, "$description" .= desc]
            [] -> A.Null

-- ---------------------------------------------------------------------------
-- Typography
-- ---------------------------------------------------------------------------

buildTypography :: A.Value
buildTypography =
    A.object
        [ "primaryFont" .= A.object
            [ "family" .= ("Outfit" :: Text)
            , "style" .= ("variable" :: Text)
            , "axes" .= A.toJSON [A.object ["tag" .= ("wght" :: Text), "min" .= (100 :: Int), "max" .= (900 :: Int)]]
            , "files" .= A.object ["variableTTF" .= asset "fonts/Outfit-VariableFont_wght.ttf"]
            , "license" .= ("OFL-1.1" :: Text)
            , "licenseFile" .= asset "fonts/OFL.txt"
            , "$description" .= ("Self-hosted Outfit variable font. Weight range 100–900. License OFL-1.1." :: Text)
            ]
        , "scale" .= A.toJSON
            [ A.object
                [ "name" .= name, "$type" .= ("typography" :: Text), "$description" .= desc
                , "fontFamily" .= ("Outfit, system-ui, sans-serif" :: Text)
                , "fontWeight" .= weight, "fontSizeRem" .= sizeRem, "fontSizePx" .= sizePx
                , "lineHeight" .= lh, "letterSpacingEm" .= ls, "cssClass" .= cssClass
                ]
            | (name, weight, sizeRem, sizePx, lh, ls, cssClass, desc) <- typeScale
            ]
        , "usageRules" .= A.toJSON typographyUsageRules
        ]

-- ---------------------------------------------------------------------------
-- Spacing
-- ---------------------------------------------------------------------------

buildSpacing :: A.Value
buildSpacing =
    A.object
        [ "baseUnit" .= A.object ["$value" .= (4 :: Int), "$type" .= ("dimension" :: Text), "unit" .= ("px" :: Text), "$description" .= ("All spacing values are multiples of 4px." :: Text)]
        , "scale" .= A.toJSON
            [ A.object
                [ "name" .= name, "$type" .= ("dimension" :: Text)
                , "multiplier" .= mult, "px" .= px, "rem" .= rem_
                , "tailwindClass" .= tw, "$description" .= desc
                ]
            | (name, mult, px, rem_, tw, desc) <- spacingScale
            ]
        , "layout" .= A.object
            [ "contentWidth" .= A.object ["$value" .= contentWidthPx, "$type" .= ("dimension" :: Text), "unit" .= ("px" :: Text), "tailwindClass" .= contentWidthTailwind, "$description" .= ("Maximum content column width." :: Text)]
            , "pagePaddingX" .= A.object ["$value" .= pagePaddingXPx, "$type" .= ("dimension" :: Text), "unit" .= ("px" :: Text), "tailwindClass" .= pagePaddingXTailwind]
            , "pageWrapper" .= A.object ["tailwindClass" .= pageWrapperClass, "$description" .= ("Apply to every page-level container." :: Text)]
            , "breakpoints" .= A.object [AK.fromText bp .= A.object ["px" .= bpx] | (bp, bpx) <- breakpoints]
            , "borderRadius" .= A.object [AK.fromText name .= A.object ["$value" .= val, "tailwindClass" .= tw] | (name, val, tw) <- borderRadii]
            ]
        ]

-- ---------------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------------

buildMotion :: A.Value
buildMotion =
    A.object
        [ "$description" .= ("All animations must respect prefers-reduced-motion." :: Text)
        , "duration" .= A.object
            [ AK.fromText name .= A.object ["$value" .= ms, "$type" .= ("duration" :: Text), "unit" .= ("ms" :: Text), "$description" .= desc]
            | (name, ms, desc) <- motionDurationData
            ]
        , "easing" .= A.object
            [ AK.fromText name .= A.object ["$value" .= val, "$type" .= ("cubicBezier" :: Text), "$description" .= desc]
            | (name, val, desc) <- motionEasingData
            ]
        , "usageRules" .= A.toJSON motionUsageRules
        ]

-- ---------------------------------------------------------------------------
-- Logos
-- ---------------------------------------------------------------------------

sqVariant :: Text -> Text -> Text -> A.Value
sqVariant stem skinToneId description =
    A.object
        [ "id" .= stem, "description" .= description, "skinTone" .= skinToneId
        , "animated" .= False, "theme" .= ("light" :: Text)
        , "svg" .= asset ("logo/square/svg/" <> stem <> ".svg")
        , "png" .= asset ("logo/square/png/" <> stem <> ".png")
        , "webp" .= asset ("logo/square/png/" <> stem <> ".webp")
        ]

hzStatic :: Text -> Text -> Text -> Bool -> A.Value
hzStatic stem description theme withText =
    A.object
        [ "id" .= stem, "description" .= description, "withText" .= withText
        , "animated" .= False, "theme" .= theme
        , "svg" .= asset ("logo/horizontal/svg/" <> stem <> ".svg")
        , "png" .= asset ("logo/horizontal/png/" <> stem <> ".png")
        , "webp" .= asset ("logo/horizontal/png/" <> stem <> ".webp")
        ]

hzAnimated :: Text -> Text -> Text -> Bool -> [Pair] -> A.Value
hzAnimated stem description theme withText extra =
    A.object $
        [ "id" .= stem, "description" .= description, "withText" .= withText
        , "animated" .= True, "theme" .= theme, "frameDurationMs" .= (10000 :: Int)
        ] ++ extra ++
        [ "gif" .= asset ("logo/horizontal/png/" <> stem <> ".gif")
        , "webp" .= asset ("logo/horizontal/png/" <> stem <> ".webp")
        ]

buildLogoUsageRules :: A.Value
buildLogoUsageRules =
    A.object
        [ "clearSpace" .= A.object ["$value" .= (0.25 :: Double), "unit" .= ("fraction of logo width" :: Text), "$description" .= ("Min 25% of logo width clear space on all four sides." :: Text)]
        , "minimumSize" .= A.object
            [ "digital" .= A.object ["widthPx" .= (80 :: Int), "$description" .= ("Square: min 80px; horizontal: min 200px wide." :: Text)]
            , "print"   .= A.object ["widthMm" .= (20 :: Int), "$description" .= ("Do not print below 20mm wide." :: Text)]
            ]
        , "preferredFormat" .= A.object
            [ "web"   .= ("SVG first; WebP with PNG fallback; GIF only for clients that don't support animated WebP." :: Text)
            , "email" .= ("PNG at 2x resolution; no animated logos in transactional email." :: Text)
            , "print" .= ("SVG or high-resolution PNG (300dpi minimum)." :: Text)
            ]
        , "themeSelection" .= A.object
            [ "lightBackground" .= ("Use any non-dark variant. Default: square (yellow) or horizontal-full." :: Text)
            , "darkBackground"  .= ("Use the -dark theme variant. Never place light-theme logo on dark background." :: Text)
            ]
        , "prohibitions" .= A.toJSON
            [ "Do not stretch, squash, or distort the logo's aspect ratio."
            , "Do not recolor logo elements. Use only the provided variants."
            , "Do not place the logo on a busy photographic or patterned background."
            , "Do not apply drop shadows, glows, or outer strokes."
            , "Do not apply opacity below 100% to the logo mark."
            , "Do not use the animated logo in print, PDF, or static email contexts."
            , "Do not display the animated logo when prefers-reduced-motion is active."
            :: Text
            ]
        ]

buildLogos :: A.Value
buildLogos =
    A.object
        [ "primaryLogo" .= ("square/square" :: Text)
        , "usageRules" .= buildLogoUsageRules
        , "square" .= A.object
            [ "description" .= ("Square minifig-head logo mark" :: Text)
            , "aspectRatio" .= ("1:1" :: Text)
            , "variants" .= A.toJSON
                [ sqVariant "square" "yellow" "Yellow, classic minifig"
                , sqVariant "square-light-nougat" "light-nougat" "Light Nougat skin tone"
                , sqVariant "square-nougat" "nougat" "Nougat skin tone"
                , sqVariant "square-dark-nougat" "dark-nougat" "Dark Nougat skin tone"
                , A.object ["id" .= ("square-animated" :: Text), "description" .= ("Animated logo cycling through all four skin tones" :: Text), "animated" .= True, "frameDurationMs" .= (10000 :: Int), "frames" .= (["yellow", "light-nougat", "nougat", "dark-nougat"] :: [Text]), "gif" .= asset "logo/square/png/square-animated.gif", "webp" .= asset "logo/square/png/square-animated.webp"]
                , A.object ["id" .= ("minifig-colorful" :: Text), "description" .= ("Minifig head with horizontal skin-tone bands" :: Text), "animated" .= False, "theme" .= ("light" :: Text), "svg" .= asset "logo/square/svg/minifig-colorful.svg", "png" .= asset "logo/square/png/minifig-colorful.png", "webp" .= asset "logo/square/png/minifig-colorful.webp"]
                , A.object ["id" .= ("minifig-rainbow" :: Text), "description" .= ("Minifig head with horizontal rainbow bands" :: Text), "animated" .= False, "theme" .= ("light" :: Text), "svg" .= asset "logo/square/svg/minifig-rainbow.svg", "png" .= asset "logo/square/png/minifig-rainbow.png", "webp" .= asset "logo/square/png/minifig-rainbow.webp"]
                ]
            ]
        , "horizontal" .= A.object
            [ "description" .= ("Horizontal logo mark (four heads side-by-side)" :: Text)
            , "aspectRatio" .= ("approx 4.4:1" :: Text)
            , "variants" .= A.toJSON
                [ hzStatic "horizontal" "Logo mark only, light theme" "light" False
                , hzStatic "horizontal-full" "Logo mark with association name subtitle, light theme" "light" True
                , hzStatic "horizontal-full-dark" "Logo mark with subtitle, dark theme" "dark" True
                , hzAnimated "horizontal-animated" "Animated logo mark cycling skin-tone order" "light" False []
                , hzAnimated "horizontal-full-animated" "Animated logo with subtitle, light theme" "light" True []
                , hzAnimated "horizontal-full-dark-animated" "Animated logo with subtitle, dark theme" "dark" True []
                , hzStatic "horizontal-rainbow" "Rainbow logo mark" "light" False
                , hzAnimated "horizontal-rainbow-animated" "Animated rainbow logo cycling all 7 colors" "light" False ["frameCount" .= (7 :: Int), "colors" .= map (\(_, _, h, _) -> hexText h) rainbowColors]
                , hzStatic "horizontal-rainbow-full" "Rainbow logo with subtitle, light theme" "light" True
                , hzAnimated "horizontal-rainbow-full-animated" "Animated rainbow logo with subtitle, light theme" "light" True ["frameCount" .= (7 :: Int)]
                , hzStatic "horizontal-rainbow-full-dark" "Rainbow logo with subtitle, dark theme" "dark" True
                , hzAnimated "horizontal-rainbow-full-dark-animated" "Animated rainbow logo with subtitle, dark theme" "dark" True ["frameCount" .= (7 :: Int)]
                ]
            ]
        ]

-- ---------------------------------------------------------------------------
-- Favicons
-- ---------------------------------------------------------------------------

buildFavicons :: A.Value
buildFavicons =
    A.object
        [ "ico" .= asset "favicon/favicon.ico"
        , "png" .= A.toJSON [assetWith ("favicon/favicon-" <> T.pack (show s) <> ".png") ["size" .= s] | s <- [16, 32, 48 :: Int]]
        , "appleTouchIcon" .= assetWith "favicon/apple-touch-icon.png" ["size" .= (180 :: Int)]
        , "webAppIcons" .= A.toJSON [assetWith ("favicon/icon-" <> T.pack (show s) <> ".png") ["size" .= s] | s <- [192, 512 :: Int]]
        ]

-- ---------------------------------------------------------------------------
-- Components
-- ---------------------------------------------------------------------------

buildComponents :: A.Value
buildComponents =
    A.object
        [ "$description" .= ("Elm UI component catalog. All components live in src/Component/. Import by module name; never copy-paste HTML inline." :: Text)
        , "components" .= A.toJSON
            [ A.object ["name" .= name, "module" .= modName, "$description" .= desc, "props" .= A.toJSON props, "tokenDependencies" .= A.toJSON deps]
            | (name, modName, desc, props, deps) <- componentCatalog
            ]
        ]
  where
    componentCatalog :: [(Text, Text, Text, [Text], [Text])]
    componentCatalog =
        [ ("ColorSwatch",  "Component.ColorSwatch",  "Color token display with hex, name, description, usage tags.", ["hex: String", "name: String", "description: String", "usageTags: List String"], ["colors.semantic.text.primary"])
        , ("LogoCard",     "Component.LogoCard",     "Logo variant gallery card with download links.", ["id, description, theme, animated, withText, svgUrl, pngUrl, webpUrl, gifUrl"], ["colors.semantic.background.dark"])
        , ("DownloadButton","Component.DownloadButton","Inline download link as button.", ["label: String", "href: String"], ["colors.semantic.background.accent"])
        , ("SectionHeader","Component.SectionHeader","Section heading with optional description.", ["title: String", "description: Maybe String"], ["typography.scale[Heading2]"])
        , ("Alert",        "Component.Alert",        "Contextual feedback message. Types: Info, Success, Warning, Error.", ["alertType: AlertType", "title: Maybe String", "body: List (Html msg)"], [])
        , ("Badge",        "Component.Badge",        "Small inline label. Colors: Gray, Blue, Green, Yellow, Red, Purple, Indigo.", ["label: String", "color: Color"], [])
        , ("Button",       "Component.Button",       "Action button or link-button. Variants: Primary, Secondary, Ghost, Danger.", ["label: String", "variant: Variant", "size: Size (Small|Medium|Large)", "onClick: msg  OR  href: String"], ["colors.semantic.background.accent"])
        , ("Card",         "Component.Card",         "Content container with optional header, footer, image, shadow.", ["body, header, footer: Maybe Html", "image: Maybe String", "shadow: Shadow (None|Sm|Md|Lg)"], ["colors.semantic.border.default"])
        , ("Accordion",    "Component.Accordion",    "Collapsible sections using native <details>.", ["items: List { title: String, body: List (Html msg) }"], ["colors.semantic.border.default"])
        , ("Breadcrumb",   "Component.Breadcrumb",   "Navigation breadcrumb trail.", ["items: List { label: String, href: Maybe String }"], [])
        , ("ButtonGroup",  "Component.ButtonGroup",  "Horizontally grouped buttons.", ["buttons: List (Html msg)"], [])
        , ("CloseButton",  "Component.CloseButton",  "Accessible close / dismiss button.", ["onClick: msg", "label: String (aria-label)"], [])
        , ("Collapse",     "Component.Collapse",     "Single collapsible section using <details>.", ["title: String", "body: List (Html msg)", "open: Bool"], ["colors.semantic.border.default"])
        , ("Dropdown",     "Component.Dropdown",     "Disclosure dropdown using <details>/<summary>.", ["trigger: Html msg", "items: List (Html msg)"], [])
        , ("ListGroup",    "Component.ListGroup",    "Vertical list with optional active/disabled states.", ["items: List ListItem"], ["colors.semantic.border.default"])
        , ("Pagination",   "Component.Pagination",   "Page navigation control.", ["current: Int", "total: Int", "onPage: Int -> msg"], [])
        , ("Placeholder",  "Component.Placeholder",  "Animated loading skeleton.", ["lines: Int", "withImage: Bool"], [])
        , ("Progress",     "Component.Progress",     "Horizontal progress bar.", ["value: Float (0-1)", "label: Maybe String", "color: String"], [])
        , ("Spinner",      "Component.Spinner",      "Loading spinner animation.", ["size: SpinnerSize (Sm|Md|Lg)", "label: Maybe String"], [])
        , ("Stats",        "Component.Stats",        "Metric display grid.", ["items: List { label, value, change }"], ["colors.semantic.text.muted"])
        , ("Timeline",     "Component.Timeline",     "Vertical timeline for changelogs.", ["items: List { date, title, children }"], ["colors.semantic.border.default"])
        , ("Toast",        "Component.Toast",        "Notification message bar.", ["message: String", "toastType: ToastType (Info|Success|Warning|Error)"], [])
        , ("Tabs",         "Component.Tabs",         "Tab navigation strip (stateless — host provides active index).", ["tabs: List String", "activeIndex: Int", "onTabClick: Int -> msg"], [])
        ]

-- ---------------------------------------------------------------------------
-- Root
-- ---------------------------------------------------------------------------

buildDesignGuide :: A.Value
buildDesignGuide =
    A.object
        [ "$schema" .= ("https://json-schema.org/draft/2020-12/schema" :: Text)
        , "$description" .= ("Machine-readable design guide for Suomen Palikkaharrastajat ry. Conforms to W3C Design Tokens conventions. Generated by cabal run logo-gen — do not edit by hand." :: Text)
        , "organization" .= A.object
            [ "name" .= associationName
            , "canonicalUrl" .= ("https://logo.palikkaharrastajat.fi" :: Text)
            , "brandGuideUrl" .= ("https://logo.palikkaharrastajat.fi" :: Text)
            , "voice" .= A.toJSON (["playful", "inclusive", "technical"] :: [Text])
            ]
        , "colors"     .= buildColors
        , "typography" .= buildTypography
        , "spacing"    .= buildSpacing
        , "motion"     .= buildMotion
        , "logos"      .= buildLogos
        , "favicons"   .= buildFavicons
        , "components" .= buildComponents
        ]

generateDesignGuide :: IO ()
generateDesignGuide = do
    let guide = buildDesignGuide
        cfg = AP.defConfig{AP.confIndent = AP.Spaces 2, AP.confTrailingNewline = True}
    BSL.writeFile "design-guide.json" (AP.encodePretty' cfg guide)
    putStrLn "Wrote design-guide.json"
