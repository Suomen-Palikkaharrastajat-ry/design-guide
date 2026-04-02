module Site exposing (canonicalUrl, config)

{-| elm-pages site configuration — canonical URL, title, and meta defaults.
-}

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import MimeType
import Pages.Url
import SiteConfig exposing (SiteConfig)


canonicalUrl : String
canonicalUrl =
    "https://logo.palikkaharrastajat.fi"


config : SiteConfig
config =
    { canonicalUrl = canonicalUrl
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport"
        (Head.raw "width=device-width, initial-scale=1")
    , Head.metaName "description"
        (Head.raw "Suomen Palikkaharrastajat ry:n brändiohjeistus: logot, värit ja typografia.")
    , Head.metaProperty "og:image"
        (Head.raw (canonicalUrl ++ "/logo/horizontal/png/horizontal-full.png"))
    , Head.metaProperty "og:type"
        (Head.raw "website")
    , Head.metaName "theme-color"
        (Head.raw "#05131D")

    -- Browser favicons
    , Head.icon [ ( 16, 16 ) ] MimeType.Png (Pages.Url.external (canonicalUrl ++ "/favicon/favicon-16.png"))
    , Head.icon [ ( 32, 32 ) ] MimeType.Png (Pages.Url.external (canonicalUrl ++ "/favicon/favicon-32.png"))
    , Head.icon [ ( 48, 48 ) ] MimeType.Png (Pages.Url.external (canonicalUrl ++ "/favicon/favicon-48.png"))
    , Head.icon [ ( 64, 64 ) ] MimeType.Png (Pages.Url.external (canonicalUrl ++ "/favicon/favicon-64.png"))

    -- Apple touch icons
    , Head.appleTouchIcon (Just 120) (Pages.Url.external (canonicalUrl ++ "/favicon/apple-touch-icon-120.png"))
    , Head.appleTouchIcon (Just 152) (Pages.Url.external (canonicalUrl ++ "/favicon/apple-touch-icon-152.png"))
    , Head.appleTouchIcon (Just 167) (Pages.Url.external (canonicalUrl ++ "/favicon/apple-touch-icon-167.png"))
    , Head.appleTouchIcon (Just 180) (Pages.Url.external (canonicalUrl ++ "/favicon/apple-touch-icon.png"))

    -- PWA icons
    , Head.icon [ ( 192, 192 ) ] MimeType.Png (Pages.Url.external (canonicalUrl ++ "/favicon/icon-192.png"))
    , Head.icon [ ( 512, 512 ) ] MimeType.Png (Pages.Url.external (canonicalUrl ++ "/favicon/icon-512.png"))
    ]
        |> BackendTask.succeed
