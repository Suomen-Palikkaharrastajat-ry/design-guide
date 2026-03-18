module Route.Kayttoohje exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Component.SectionHeader as SectionHeader
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StaticPayload)
import Shared
import SiteMeta
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : RouteBuilder.StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = SiteMeta.organizationName
        , image =
            { url = Pages.Url.external "https://logo.palikkaharrastajat.fi/logo/horizontal/png/horizontal-full.png"
            , alt = SiteMeta.organizationName
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Tekninen käyttöohje: koodiesimerkit, tokenit ja integraatio-ohjeet."
        , locale = Nothing
        , title = "Käyttöohje · " ++ SiteMeta.organizationName
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = "Käyttöohje · " ++ SiteMeta.organizationName
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-8 sm:py-12 space-y-14 sm:space-y-20" ]
            [ viewPageHeader
            , viewLogoUsageSection
            , viewColorsSection
            , viewTypografiaSection
            , viewIkoniSection
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ Attr.class "space-y-2" ]
        [ Html.h1 [ Attr.class "text-2xl sm:text-3xl font-bold text-brand" ]
            [ Html.text "Käyttöohje" ]
        , Html.p [ Attr.class "text-sm sm:text-base text-gray-500" ]
            [ Html.text "Koodiesimerkit, tokenit ja integraatio-ohjeet. Koneluettava versio: "
            , Html.a
                [ Attr.href "/design-guide/index.jsonld"
                , Attr.class "underline hover:text-brand transition-colors font-mono text-sm"
                ]
                [ Html.text "design-guide/" ]
            , Html.text "."
            ]
        ]



-- ── Logot ─────────────────────────────────────────────────────────────────────


viewLogoUsageSection : Html msg
viewLogoUsageSection =
    Html.section [ Attr.id "logot", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Logot" ]
            , Html.a
                [ Attr.href "/design-guide/logos.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "logos.jsonld" ]
            ]
        , viewLogoUsageRules
        , viewLogoContextMapping
        , viewFaviconSnippets
        ]


viewLogoUsageRules : Html msg
viewLogoUsageRules =
    Html.div [ Attr.class "bg-amber-50 border border-amber-200 rounded-lg p-4 text-sm text-amber-800 space-y-2" ]
        [ Html.p [ Attr.class "font-semibold" ] [ Html.text "Käyttöohjeet" ]
        , Html.ul [ Attr.class "list-disc list-inside space-y-1 mt-1" ]
            [ Html.li [] [ Html.text "Käytä SVG ensin; WebP PNG-varamenetelmällä" ]
            , Html.li [] [ Html.text "Älä venytä, litistä tai värjää logon osia" ]
            , Html.li [] [ Html.text "Älä käytä animoitua logoa tulostettavissa tai sähköpostissa" ]
            ]
        , Html.div [ Attr.class "flex flex-wrap gap-4 pt-1 border-t border-amber-200 mt-2" ]
            [ Html.span [] [ Html.text "Minimikoko: " , Html.strong [] [ Html.text "80 px" ], Html.text " (neliö) · " , Html.strong [] [ Html.text "200 px" ], Html.text " (vaaka)" ]
            , Html.span [] [ Html.text "Tyhjä tila: vähintään 25 % logon leveydestä joka suuntaan" ]
            ]
        ]


viewLogoContextMapping : Html msg
viewLogoContextMapping =
    Html.div [ Attr.class "space-y-3" ]
        [ SectionHeader.viewSub
            { title = "Mikä logo mihinkin?"
            , description = Just "Valitse variantti käyttökontekstin mukaan."
            }
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "border-b border-gray-200" ]
                        [ th "Konteksti", th "Suositeltu variantti", th "Formaatti" ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
                    (List.map viewContextRow contextMappingRows)
                ]
            ]
        ]


contextMappingRows : List { context : String, variant : String, format : String }
contextMappingRows =
    [ { context = "Sivun header / navigaatio", variant = "square-smile-full tai horizontal-full", format = "SVG" }
    , { context = "Tumma header / footer", variant = "square-smile-full-dark tai horizontal-full-dark", format = "SVG" }
    , { context = "Sosiaalinen media / OG-kuva", variant = "horizontal-full", format = "PNG (1200 × 630)" }
    , { context = "Favicon (selain)", variant = "favicon.ico + favicon-32.png", format = "ICO + PNG" }
    , { context = "PWA / kotinäyttö (Android)", variant = "icon-192.png, icon-512.png", format = "PNG" }
    , { context = "iOS kotinäyttö", variant = "apple-touch-icon.png (180 px)", format = "PNG" }
    , { context = "Painotuotteet", variant = "horizontal-full tai square-smile-full", format = "SVG tai 300 dpi+ PNG" }
    , { context = "Animoitu banneri / hero", variant = "square-animated / horizontal-full-animated", format = "WebP/GIF (ei reduced-motion -käyttäjille)" }
    ]


viewContextRow : { context : String, variant : String, format : String } -> Html msg
viewContextRow row =
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "py-2 px-3 text-gray-700" ] [ Html.text row.context ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand" ] [ Html.text row.variant ]
        , Html.td [ Attr.class "py-2 px-3 text-xs text-gray-500" ] [ Html.text row.format ]
        ]


viewFaviconSnippets : Html msg
viewFaviconSnippets =
    Html.div [ Attr.class "space-y-6" ]
        [ SectionHeader.viewSub
            { title = "Koodiesimerkit"
            , description = Just "Liitä seuraavat koodipalat suoraan HTML-tiedostoosi."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Favicon — <head>" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """<link rel=\"icon\" href=\"/favicon/favicon.ico\" sizes=\"any\">
<link rel=\"icon\" href=\"/favicon/favicon-32.png\" type=\"image/png\" sizes=\"32x32\">
<link rel=\"icon\" href=\"/favicon/favicon-48.png\" type=\"image/png\" sizes=\"48x48\">
<link rel=\"apple-touch-icon\" href=\"/favicon/apple-touch-icon.png\">
<link rel=\"manifest\" href=\"/site.webmanifest\">""" ]
                        ]
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Lisää ICO ensin — vanhat selaimet eivät tue PNG-faviconeja. Apple touch icon on 180 × 180 px." ]
                ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Logo — <picture> WebP + PNG" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """<picture>
  <source
    srcset=\"/logo/horizontal/png/horizontal-full.webp\"
    type=\"image/webp\">
  <img
    src=\"/logo/horizontal/png/horizontal-full.png\"
    alt=\"Suomen Palikkaharrastajat ry\"
    width=\"400\" height=\"120\">
</picture>""" ]
                    ]
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Käytä aina "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "<picture>" ]
                    , Html.text " -elementtiä, jotta selain valitsee WebP:n kun se on tuettu, muuten käytetään PNG-varaversiota."
                    ]
                ]
            ]
        ]



-- ── Värit ─────────────────────────────────────────────────────────────────────


viewColorsSection : Html msg
viewColorsSection =
    Html.section [ Attr.id "varit", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Värit" ]
            , Html.a
                [ Attr.href "/design-guide/colors.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "colors.jsonld" ]
            ]
        , viewSemanticColors
        ]


viewSemanticColors : Html msg
viewSemanticColors =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Semanttiset värit"
            , description = Just "Käytä aina semanttisia nimiä — älä koodaa heksadesimaaliarvoja suoraan komponentteihin. Tailwind-luokat ovat kanonisia; CSS-muuttuja on Tailwind v4:n generoima."
            }
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "border-b border-gray-200" ]
                        [ th "Nimi", th "Arvo", th "Tailwind", th "CSS-muuttuja", th "Käyttö" ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
                    (List.map viewSemanticRow semanticRows)
                ]
            ]
        , Html.p [ Attr.class "text-xs text-gray-400" ]
            [ Html.text "Kanoninen luokka: "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "text.primary" ]
            , Html.text " → "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "text-brand" ]
            , Html.text ". Älä rakenna omia aliaksia kuten "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "text-text-primary" ]
            , Html.text " — ne eivät vastaa ohjeiston kanonisia nimiä."
            ]
        ]


semanticRows : List { name : String, hex : String, tw : String, cssVar : String, desc : String }
semanticRows =
    [ { name = "text.primary",       hex = "#05131D", tw = "text-brand",        cssVar = "--color-brand",        desc = "Pääotsikot ja tärkeä teksti" }
    , { name = "text.onDark",        hex = "#FFFFFF", tw = "text-white",         cssVar = "--color-white",        desc = "Teksti tummalla taustalla" }
    , { name = "text.muted",         hex = "#6B7280", tw = "text-gray-500",      cssVar = "--color-gray-500",     desc = "Sekundääri teksti" }
    , { name = "text.subtle",        hex = "#9CA3AF", tw = "text-gray-400",      cssVar = "--color-gray-400",     desc = "Placeholder, disabled" }
    , { name = "background.page",    hex = "#FFFFFF", tw = "bg-white",           cssVar = "--color-white",        desc = "Sivun pääväri" }
    , { name = "background.dark",    hex = "#05131D", tw = "bg-brand",           cssVar = "--color-brand",        desc = "Tumma teema, navbar" }
    , { name = "background.subtle",  hex = "#F9FAFB", tw = "bg-gray-50",         cssVar = "--color-gray-50",      desc = "Korostusalue, kortit" }
    , { name = "background.accent",  hex = "#FAC80A", tw = "bg-brand-yellow",    cssVar = "--color-brand-yellow", desc = "Keltainen aksentti" }
    , { name = "border.default",     hex = "#E5E7EB", tw = "border-gray-200",    cssVar = "--color-gray-200",     desc = "Kortit, taulukot" }
    , { name = "border.brand",       hex = "#05131D", tw = "border-brand",       cssVar = "--color-brand",        desc = "Aktiiviset elementit" }
    ]


viewSemanticRow : { name : String, hex : String, tw : String, cssVar : String, desc : String } -> Html msg
viewSemanticRow row =
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-700" ] [ Html.text row.name ]
        , Html.td [ Attr.class "py-2 px-3" ]
            [ Html.div [ Attr.class "flex items-center gap-2" ]
                [ Html.span
                    [ Attr.class "w-5 h-5 rounded border border-gray-200 flex-shrink-0"
                    , Attr.style "background-color" row.hex
                    ]
                    []
                , Html.span [ Attr.class "font-mono text-xs text-gray-500" ] [ Html.text row.hex ]
                ]
            ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand" ] [ Html.text row.tw ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-400" ] [ Html.text row.cssVar ]
        , Html.td [ Attr.class "py-2 px-3 text-gray-500 text-xs" ] [ Html.text row.desc ]
        ]



-- ── Typografia ────────────────────────────────────────────────────────────────


viewTypografiaSection : Html msg
viewTypografiaSection =
    Html.section [ Attr.id "typografia", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Typografia" ]
            , Html.a
                [ Attr.href "/design-guide/typography.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "typography.jsonld" ]
            ]
        , viewFontLoadingGuide
        , viewFrameworkIntegrationSection
        , viewTypeScale
        ]


viewFontLoadingGuide : Html msg
viewFontLoadingGuide =
    Html.div [ Attr.class "space-y-6" ]
        [ SectionHeader.viewSub
            { title = "Fontin lataus"
            , description = Just "Lisää nämä koodipalat omaan CSS- tai config-tiedostoosi."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "@font-face (plain CSS)" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """@font-face {
  font-family: "Outfit";
  src: url("/fonts/Outfit-VariableFont_wght.ttf") format("truetype");
  font-weight: 100 900;
  font-display: swap;  /* avoids invisible text (FOIT) during load */
}""" ]
                    ]
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Käytä aina "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "font-display: swap" ]
                    , Html.text ", jotta teksti pysyy luettavana fontin latauksen ajan (vältetään FOIT)."
                    ]
                ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Tailwind v4 — @theme (CSS-tiedostossa)" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """@theme {
  --font-family-sans: "Outfit", system-ui, sans-serif;
  --color-brand: #05131D;
  --color-brand-yellow: #FAC80A;
}""" ]
                    ]
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Tailwind v4 jättää "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "tailwind.config.js" ]
                    , Html.text " kokonaan huomiotta. Kaikki "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "@theme" ]
                    , Html.text " -tokenit kuuluvat CSS-tiedostoon, ei JS-konfigiin."
                    ]
                ]
            ]
        ]


viewFrameworkIntegrationSection : Html msg
viewFrameworkIntegrationSection =
    Html.div [ Attr.class "space-y-6" ]
        [ SectionHeader.viewSub
            { title = "Framework-integraatio"
            , description = Just "Tokenien käyttöönotto eri ympäristöissä. Valitse alla olevista ohjeista omasi."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Plain CSS — CSS custom properties" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """:root {
  --font-family-sans: "Outfit", system-ui, sans-serif;
  --color-brand: #05131D;
  --color-brand-yellow: #FAC80A;
  --color-white: #FFFFFF;
}

body { font-family: var(--font-family-sans); color: var(--color-brand); }
.btn-primary { background: var(--color-brand-yellow); color: var(--color-brand); }""" ]
                    ]
                ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Tailwind CSS v3 — tailwind.config.js" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      fontFamily: { sans: [\"Outfit\", \"system-ui\", \"sans-serif\"] },
      colors: {
        brand: \"#05131D\",
        \"brand-yellow\": \"#FAC80A\",
      },
    },
  },
}""" ]
                    ]
                ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Tailwind CSS v4 — style.css (@theme)" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """/* style.css — Tailwind v4 jättää tailwind.config.js huomiotta */
@import \"tailwindcss\";

@font-face {
  font-family: \"Outfit\";
  src: url(\"/fonts/Outfit-VariableFont_wght.ttf\") format(\"truetype\");
  font-weight: 100 900;
  font-display: swap;
}

@theme {
  --font-family-sans: \"Outfit\", system-ui, sans-serif;
  --color-brand: #05131D;
  --color-brand-yellow: #FAC80A;
}""" ]
                    ]
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Tailwind v4:ssä kaikki tokenit määritellään "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "@theme" ]
                    , Html.text " -lohkossa CSS-tiedostossa. "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "tailwind.config.js" ]
                    , Html.text " ei vaikuta lainkaan."
                    ]
                ]
            ]
        ]


viewTypeScale : Html msg
viewTypeScale =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Tyyliaste"
            , description = Just "Käytä aina nimettyjä tyylejä — älä määritä fonttikokoja suoraan komponenteissa."
            }
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "border-b border-gray-200" ]
                        [ th "Nimi", th "Paino", th "Koko (rem)", th "Rivinorkeus", th "Esimerkki" ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
                    (List.map viewTypeRow typeScaleRows)
                ]
            ]
        ]


typeScaleRows : List { name : String, weight : String, size : String, lineHeight : String }
typeScaleRows =
    [ { name = "Display",   weight = "700", size = "3.0rem",   lineHeight = "1.1"  }
    , { name = "Heading1",  weight = "700", size = "1.875rem", lineHeight = "1.2"  }
    , { name = "Heading2",  weight = "700", size = "1.5rem",   lineHeight = "1.3"  }
    , { name = "Heading3",  weight = "600", size = "1.25rem",  lineHeight = "1.35" }
    , { name = "Heading4",  weight = "600", size = "1.125rem", lineHeight = "1.4"  }
    , { name = "Body",      weight = "400", size = "1rem",     lineHeight = "1.6"  }
    , { name = "BodySmall", weight = "500", size = "0.875rem", lineHeight = "1.5"  }
    , { name = "Caption",   weight = "400", size = "0.875rem", lineHeight = "1.4"  }
    , { name = "Mono",      weight = "400", size = "0.875rem", lineHeight = "1.6"  }
    , { name = "Overline",  weight = "600", size = "0.75rem",  lineHeight = "1.4"  }
    ]


viewTypeRow : { name : String, weight : String, size : String, lineHeight : String } -> Html msg
viewTypeRow row =
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand font-medium" ] [ Html.text row.name ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.weight ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.size ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.lineHeight ]
        , Html.td [ Attr.class "py-2 px-3 text-brand overflow-hidden max-w-xs" ]
            [ Html.span
                [ Attr.style "font-weight" row.weight
                , Attr.style "font-size" row.size
                , Attr.style "line-height" row.lineHeight
                , Attr.class "whitespace-nowrap"
                ]
                [ Html.text "Nopea ruskea kettu hyppää laiskan koiran yli" ]
            ]
        ]



-- ── Ikonit ────────────────────────────────────────────────────────────────────


viewIkoniSection : Html msg
viewIkoniSection =
    Html.section [ Attr.id "ikonit", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Ikonit" ]
        , Html.div [ Attr.class "bg-white border border-gray-200 rounded-xl p-4 sm:p-6 space-y-4" ]
            [ Html.p [ Attr.class "text-sm text-gray-600" ]
                [ Html.text "Suositeltu ikonisetti: "
                , Html.strong [] [ Html.text "Feather Icons" ]
                , Html.text ". Yhtenäinen, viiva-pohjainen tyyli sopii yhteen Outfit-fontin geometrisen ilmeen kanssa."
                ]
            , Html.div [ Attr.class "overflow-x-auto" ]
                [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                    [ Html.thead []
                        [ Html.tr [ Attr.class "border-b border-gray-200" ]
                            [ th "Ympäristö", th "Paketti", th "Versio" ]
                        ]
                    , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
                        [ Html.tr [ Attr.class "hover:bg-gray-50" ]
                            [ Html.td [ Attr.class "py-2 px-3 text-gray-700" ] [ Html.text "Elm" ]
                            , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand" ] [ Html.text "feathericons/elm-feather" ]
                            , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text "1.5.0" ]
                            ]
                        , Html.tr [ Attr.class "hover:bg-gray-50" ]
                            [ Html.td [ Attr.class "py-2 px-3 text-gray-700" ] [ Html.text "npm / plain JS" ]
                            , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand" ] [ Html.text "feather-icons" ]
                            , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text "4.x" ]
                            ]
                        ]
                    ]
                ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Elm — elm.json" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """\"dependencies\": {
    \"direct\": {
        \"feathericons/elm-feather\": \"1.5.0\"
    },
    \"indirect\": {
        \"elm/svg\": \"1.0.1\"   -- tarvitaan elm-feather-riippuvuutena
    }
}""" ]
                    ]
                ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Elm — käyttö" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """import FeatherIcons

FeatherIcons.menu
    |> FeatherIcons.withSize 20
    |> FeatherIcons.toHtml [ Attr.attribute \"aria-hidden\" \"true\" ]""" ]
                    ]
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Lisää aina "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "aria-hidden=\"true\"" ]
                    , Html.text " koristelullisiin ikoneihin — teksti tai "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "aria-label" ]
                    , Html.text " välittää merkityksen ruudunlukijalle."
                    ]
                ]
            ]
        ]



-- ── Helpers ───────────────────────────────────────────────────────────────────


th : String -> Html msg
th label =
    Html.th [ Attr.class "py-2 px-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider" ]
        [ Html.text label ]
