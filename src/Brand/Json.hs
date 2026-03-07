{-# LANGUAGE OverloadedStrings #-}
module Brand.Json (generateBrandJson) where

import Brand.Colors
import qualified Data.Aeson as A
import Data.Aeson ((.=))
import Data.Aeson.Types (Pair)
import qualified Data.Aeson.Encode.Pretty as AP
import qualified Data.ByteString.Lazy as BSL
import Data.Text (Text)
import qualified Data.Text as T

baseUrl :: Text
baseUrl = "https://logo.palikkaharrastajat.fi"

asset :: Text -> A.Value
asset path =
    A.object
        [ "file" .= path
        , "url" .= (baseUrl <> "/" <> path)
        ]

assetWith :: Text -> [Pair] -> A.Value
assetWith path extra =
    A.object $ ["file" .= path, "url" .= (baseUrl <> "/" <> path)] ++ extra

buildColors :: A.Value
buildColors =
    A.object
        [ "brand"
            .= A.toJSON
                [ A.object
                    [ "hex" .= ("#05131D" :: Text)
                    , "id" .= ("lego-black" :: Text)
                    , "name" .= ("LEGO Black" :: Text)
                    , "usage" .= (["features", "text", "dark background"] :: [Text])
                    ]
                , A.object
                    [ "hex" .= ("#FFFFFF" :: Text)
                    , "id" .= ("lego-white" :: Text)
                    , "name" .= ("LEGO White" :: Text)
                    , "usage" .= (["eye highlights", "text on dark background"] :: [Text])
                    ]
                ]
        , "skinTones"
            .= A.toJSON
                [ A.object
                    [ "hex" .= hexText h
                    , "id" .= sid
                    , "name" .= sname
                    , "description" .= desc
                    ]
                | (sid, sname, h, desc) <- skinTonesWithDesc
                ]
        , "rainbow"
            .= A.toJSON
                [ A.object
                    [ "hex" .= hexText h
                    , "name" .= rname
                    , "description" .= rdesc
                    ]
                | (_, rname, h, rdesc) <- rainbowColors
                ]
        , "text"
            .= A.object
                [ "onLight" .= hexText subtitleOnLight
                , "onDark" .= hexText subtitleOnDark
                ]
        , "darkBackground" .= hexText darkBg
        ]
  where
    skinTonesWithDesc :: [(Text, Text, Hex, Text)]
    skinTonesWithDesc =
        [ ("yellow", "Yellow", Hex "#F2CD37", "Classic minifig")
        , ("light-nougat", "Light Nougat", Hex "#F6D7B3", "Light skin")
        , ("nougat", "Nougat", Hex "#CC8E69", "Medium skin")
        , ("dark-nougat", "Dark Nougat", Hex "#AD6140", "Dark skin")
        ]

buildTypography :: A.Value
buildTypography =
    A.object
        [ "primaryFont"
            .= A.object
                [ "family" .= ("Outfit" :: Text)
                , "style" .= ("variable" :: Text)
                , "axes"
                    .= A.toJSON
                        [ A.object
                            [ "tag" .= ("wght" :: Text)
                            , "min" .= (100 :: Int)
                            , "max" .= (900 :: Int)
                            ]
                        ]
                , "files"
                    .= A.object
                        ["variableTTF" .= asset "fonts/Outfit-VariableFont_wght.ttf"]
                , "license" .= ("OFL-1.1" :: Text)
                , "licenseFile" .= asset "fonts/OFL.txt"
                ]
        ]

sqVariant :: Text -> Text -> Text -> A.Value
sqVariant stem skinToneId description =
    A.object
        [ "id" .= stem
        , "description" .= description
        , "skinTone" .= skinToneId
        , "animated" .= False
        , "theme" .= ("light" :: Text)
        , "svg" .= asset ("logo/square/svg/" <> stem <> ".svg")
        , "png" .= asset ("logo/square/png/" <> stem <> ".png")
        , "webp" .= asset ("logo/square/png/" <> stem <> ".webp")
        ]

hzStatic :: Text -> Text -> Text -> Bool -> A.Value
hzStatic stem description theme withText =
    A.object
        [ "id" .= stem
        , "description" .= description
        , "withText" .= withText
        , "animated" .= False
        , "theme" .= theme
        , "svg" .= asset ("logo/horizontal/svg/" <> stem <> ".svg")
        , "png" .= asset ("logo/horizontal/png/" <> stem <> ".png")
        , "webp" .= asset ("logo/horizontal/png/" <> stem <> ".webp")
        ]

hzAnimated :: Text -> Text -> Text -> Bool -> [Pair] -> A.Value
hzAnimated stem description theme withText extra =
    A.object $
        [ "id" .= stem
        , "description" .= description
        , "withText" .= withText
        , "animated" .= True
        , "theme" .= theme
        , "frameDurationMs" .= (10000 :: Int)
        ]
            ++ extra
            ++ [ "gif" .= asset ("logo/horizontal/png/" <> stem <> ".gif")
               , "webp" .= asset ("logo/horizontal/png/" <> stem <> ".webp")
               ]

buildLogos :: A.Value
buildLogos =
    A.object
        [ "primaryLogo" .= ("square/square" :: Text)
        , "square"
            .= A.object
                [ "description" .= ("Square minifig-head logo mark" :: Text)
                , "aspectRatio" .= ("1:1" :: Text)
                , "variants"
                    .= A.toJSON
                        [ sqVariant "square" "yellow" "Yellow, classic minifig"
                        , sqVariant "square-light-nougat" "light-nougat" "Light Nougat skin tone"
                        , sqVariant "square-nougat" "nougat" "Nougat skin tone"
                        , sqVariant "square-dark-nougat" "dark-nougat" "Dark Nougat skin tone"
                        , A.object
                            [ "id" .= ("square-animated" :: Text)
                            , "description" .= ("Animated logo cycling through all four skin tones" :: Text)
                            , "animated" .= True
                            , "frameDurationMs" .= (10000 :: Int)
                            , "frames" .= (["yellow", "light-nougat", "nougat", "dark-nougat"] :: [Text])
                            , "gif" .= asset "logo/square/png/square-animated.gif"
                            , "webp" .= asset "logo/square/png/square-animated.webp"
                            ]
                        , A.object
                            [ "id" .= ("minifig-colorful" :: Text)
                            , "description" .= ("Minifig head with face divided into horizontal skin-tone bands" :: Text)
                            , "animated" .= False
                            , "theme" .= ("light" :: Text)
                            , "svg" .= asset "logo/square/svg/minifig-colorful.svg"
                            , "png" .= asset "logo/square/png/minifig-colorful.png"
                            , "webp" .= asset "logo/square/png/minifig-colorful.webp"
                            ]
                        , A.object
                            [ "id" .= ("minifig-rainbow" :: Text)
                            , "description" .= ("Minifig head with face divided into horizontal rainbow bands" :: Text)
                            , "animated" .= False
                            , "theme" .= ("light" :: Text)
                            , "svg" .= asset "logo/square/svg/minifig-rainbow.svg"
                            , "png" .= asset "logo/square/png/minifig-rainbow.png"
                            , "webp" .= asset "logo/square/png/minifig-rainbow.webp"
                            ]
                        ]
                ]
        , "horizontal"
            .= A.object
                [ "description" .= ("Horizontal logo mark (four heads side-by-side)" :: Text)
                , "aspectRatio" .= ("approx 4.4:1" :: Text)
                , "variants"
                    .= A.toJSON
                        [ hzStatic "horizontal" "Logo mark only, light theme" "light" False
                        , hzStatic "horizontal-full" "Logo mark with association name subtitle, light theme" "light" True
                        , hzStatic "horizontal-full-dark" "Logo mark with subtitle, dark theme" "dark" True
                        , hzAnimated "horizontal-animated" "Animated logo mark cycling skin-tone order" "light" False []
                        , hzAnimated "horizontal-full-animated" "Animated logo with subtitle cycling skin-tone order, light theme" "light" True []
                        , hzAnimated "horizontal-full-dark-animated" "Animated logo with subtitle cycling skin-tone order, dark theme" "dark" True []
                        , hzStatic "horizontal-rainbow" "Rainbow logo mark, sliding window of 4 colors" "light" False
                        , hzAnimated
                            "horizontal-rainbow-animated"
                            "Animated rainbow logo mark cycling all 7 colors one step at a time"
                            "light"
                            False
                            [ "frameCount" .= (7 :: Int)
                            , "colors" .= map (\(_, _, h, _) -> hexText h) rainbowColors
                            ]
                        , hzStatic "horizontal-rainbow-full" "Rainbow logo mark with subtitle, light theme" "light" True
                        , hzAnimated
                            "horizontal-rainbow-full-animated"
                            "Animated rainbow logo with subtitle, light theme, 7 colors cycling"
                            "light"
                            True
                            ["frameCount" .= (7 :: Int)]
                        , hzStatic "horizontal-rainbow-full-dark" "Rainbow logo mark with subtitle, dark theme" "dark" True
                        , hzAnimated
                            "horizontal-rainbow-full-dark-animated"
                            "Animated rainbow logo with subtitle, dark theme, 7 colors cycling"
                            "dark"
                            True
                            ["frameCount" .= (7 :: Int)]
                        ]
                ]
        ]

buildFavicons :: A.Value
buildFavicons =
    A.object
        [ "ico" .= asset "favicon/favicon.ico"
        , "png"
            .= A.toJSON
                [ assetWith ("favicon/favicon-" <> T.pack (show s) <> ".png") ["size" .= s]
                | s <- [16, 32, 48 :: Int]
                ]
        , "appleTouchIcon" .= assetWith "favicon/apple-touch-icon.png" ["size" .= (180 :: Int)]
        , "webAppIcons"
            .= A.toJSON
                [ assetWith ("favicon/icon-" <> T.pack (show s) <> ".png") ["size" .= s]
                | s <- [192, 512 :: Int]
                ]
        ]

buildBrandData :: A.Value
buildBrandData =
    A.object
        [ "$schema" .= ("https://json-schema.org/draft/2020-12/schema" :: Text)
        , "organization" .= A.object ["name" .= associationName]
        , "colors" .= buildColors
        , "typography" .= buildTypography
        , "logos" .= buildLogos
        , "favicons" .= buildFavicons
        ]

generateBrandJson :: IO ()
generateBrandJson = do
    let brand = buildBrandData
        cfg = AP.defConfig{AP.confIndent = AP.Spaces 2, AP.confTrailingNewline = True}
    BSL.writeFile "brand.json" (AP.encodePretty' cfg brand)
    putStrLn "Wrote brand.json"
