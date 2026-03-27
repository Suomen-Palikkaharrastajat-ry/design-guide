module Route.Typografia exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FeatherIcons
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
        , description = "Typografiaskaala ja ikonit: type-* apuohjelmat, esimerkit, spec-arvot ja feathericons/elm-feather-kirjasto."
        , locale = Nothing
        , title = "Typografia · " ++ SiteMeta.organizationName
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = "Typografia · " ++ SiteMeta.organizationName
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-8 sm:py-12 space-y-14 sm:space-y-20" ]
            [ viewPageHeader
            , viewTypeScaleSection
            , viewDosDontsSection
            , viewUsageSection
            , viewIconsSection
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ Attr.class "space-y-2" ]
        [ Html.h1 [ Attr.class "text-2xl sm:text-3xl font-bold text-brand" ]
            [ Html.text "Typografia" ]
        , Html.p [ Attr.class "text-sm sm:text-base text-gray-500" ]
            [ Html.text "Outfit-fonttiperhe, typografiaskaala ja "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "type-*" ]
            , Html.text " CSS-apuohjelmat. Nämä apuohjelmat on määritelty "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "brand.css" ]
            , Html.text ":ssä ja "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "style.css" ]
            , Html.text ":ssä."
            ]
        ]



-- ── Type scale section ────────────────────────────────────────────────────────


viewTypeScaleSection : Html msg
viewTypeScaleSection =
    Html.section [ Attr.id "skaala" ]
        [ Html.h2 [ Attr.class "text-xl font-bold text-brand mb-6 pb-2 border-b border-gray-200" ]
            [ Html.text "Typografiaskaala" ]
        , Html.div [ Attr.class "space-y-10" ]
            (List.map viewTypeRow typeScaleRows)
        ]


type alias TypeRow =
    { cls : String
    , label : String
    , size : String
    , weight : String
    , lineHeight : String
    , letterSpacing : String
    , usage : String
    , example : String
    }


typeScaleRows : List TypeRow
typeScaleRows =
    [ { cls = "type-display"
      , label = "type-display"
      , size = "3rem (48px)"
      , weight = "700"
      , lineHeight = "1.1"
      , letterSpacing = "-0.02em"
      , usage = "Hero-otsikot ja laskeutumissivujen pääotsikot. Käytä vain suurilla näytöillä (≥ md)."
      , example = "Suomen Palikkaharrastajat"
      }
    , { cls = "type-h1"
      , label = "type-h1"
      , size = "1.875rem (30px)"
      , weight = "700"
      , lineHeight = "1.2"
      , letterSpacing = "-0.01em"
      , usage = "Sivutason pääotsikko (yksi per sivu). Käytä type-display sijaan pienillä näytöillä."
      , example = "Tapahtumakalenteri"
      }
    , { cls = "type-h2"
      , label = "type-h2"
      , size = "1.5rem (24px)"
      , weight = "700"
      , lineHeight = "1.3"
      , letterSpacing = "—"
      , usage = "Osion pääotsikko. Hierarkia: Display > H1 > H2 > H3 > H4."
      , example = "Tulevat tapahtumat"
      }
    , { cls = "type-h3"
      , label = "type-h3"
      , size = "1.25rem (20px)"
      , weight = "600"
      , lineHeight = "1.35"
      , letterSpacing = "—"
      , usage = "Aliosion otsikko tai korttiotsikko."
      , example = "Kevät 2026"
      }
    , { cls = "type-h4"
      , label = "type-h4"
      , size = "1.125rem (18px)"
      , weight = "600"
      , lineHeight = "1.4"
      , letterSpacing = "—"
      , usage = "Kortti- ja widgetotsikot. Käytä H3:n alapuolella."
      , example = "Ilmoittautuminen"
      }
    , { cls = "type-body"
      , label = "type-body"
      , size = "1rem (16px)"
      , weight = "400"
      , lineHeight = "1.6"
      , letterSpacing = "—"
      , usage = "Oletusteksti. Pienin sallittu koko saavutettavalle luettavuudelle."
      , example = "Suomen Palikkaharrastajat ry on LEGO®-rakentajien harrasteyhdistys. Järjestämme näyttelyjä ja tapahtumia ympäri vuoden."
      }
    , { cls = "type-body-small"
      , label = "type-body-small"
      , size = "0.875rem (14px)"
      , weight = "500"
      , lineHeight = "1.5"
      , letterSpacing = "—"
      , usage = "Toissijaiset labelit, käyttöliittymäkontrollit ja lomakevihjeet."
      , example = "Tapahtuma julkaistu · Muokkaa tietoja"
      }
    , { cls = "type-caption"
      , label = "type-caption"
      , size = "0.875rem (14px)"
      , weight = "400"
      , lineHeight = "1.4"
      , letterSpacing = "0.02em"
      , usage = "Kuvatekstit, alaviitteet ja metatiedot."
      , example = "Kuva: LEGO-mallinnos Helsingistä, 2025"
      }
    , { cls = "type-mono"
      , label = "type-mono"
      , size = "0.875rem (14px)"
      , weight = "400"
      , lineHeight = "1.6"
      , letterSpacing = "—"
      , usage = "Hex-arvot, tunnisteet ja koodinpätkät."
      , example = "#05131D · --color-brand · type-h2"
      }
    , { cls = "type-overline"
      , label = "type-overline"
      , size = "0.75rem (12px)"
      , weight = "600"
      , lineHeight = "1.4"
      , letterSpacing = "0.08em"
      , usage = "Osiokategorian labelit. Aina versaalein."
      , example = "TAPAHTUMAT · KILPAILUT"
      }
    ]


viewTypeRow : TypeRow -> Html msg
viewTypeRow row =
    Html.div [ Attr.class "grid grid-cols-1 md:grid-cols-2 gap-4 py-6 border-b border-gray-100 last:border-b-0" ]
        [ -- Live example
          Html.div [ Attr.class "flex flex-col justify-center min-h-16" ]
            [ Html.p [ Attr.class row.cls ]
                [ Html.text row.example ]
            ]
        , -- Spec and usage
          Html.div [ Attr.class "space-y-2" ]
            [ Html.div [ Attr.class "flex items-center gap-2" ]
                [ Html.code [ Attr.class "font-mono text-sm bg-brand/10 text-brand px-2 py-0.5 rounded font-semibold" ]
                    [ Html.text row.label ]
                ]
            , Html.table [ Attr.class "w-full text-xs text-gray-600 border-collapse" ]
                [ Html.tbody []
                    [ specRow "Koko" row.size
                    , specRow "Paino" row.weight
                    , specRow "Rivinväli" row.lineHeight
                    , specRow "Kirjainväli" row.letterSpacing
                    ]
                ]
            , Html.p [ Attr.class "text-xs text-gray-500 italic" ]
                [ Html.text row.usage ]
            ]
        ]


specRow : String -> String -> Html msg
specRow label value =
    Html.tr []
        [ Html.td [ Attr.class "pr-3 py-0.5 text-gray-400 font-medium w-24" ] [ Html.text label ]
        , Html.td [ Attr.class "py-0.5 font-mono" ] [ Html.text value ]
        ]



-- ── Do / Don't section ────────────────────────────────────────────────────────


viewDosDontsSection : Html msg
viewDosDontsSection =
    Html.section [ Attr.id "ohjeet" ]
        [ Html.h2 [ Attr.class "text-xl font-bold text-brand mb-6 pb-2 border-b border-gray-200" ]
            [ Html.text "Käyttöohjeet" ]
        , Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-6" ]
            [ viewDoCard
            , viewDontCard
            ]
        ]


viewDoCard : Html msg
viewDoCard =
    Html.div [ Attr.class "rounded-xl border border-green-200 bg-green-50 p-6 space-y-4" ]
        [ Html.h3 [ Attr.class "type-h4 text-green-800" ] [ Html.text "✓ Tee näin" ]
        , Html.ul [ Attr.class "space-y-2 text-sm text-green-900 list-disc list-inside" ]
            [ Html.li [] [ Html.text "Käytä ", codeInline "type-h2", Html.text " osion otsikoihin" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-body", Html.text " oletustekstiin" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-overline", Html.text " kategorialabeleissa — aina versaalein" ]
            , Html.li [] [ Html.text "Noudata hierarkiaa: Display > H1 > H2 > H3 > H4" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-display", Html.text " vain md-näytöillä tai suuremmilla" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-mono", Html.text " hex-arvoihin, CSS-muuttujiin ja koodiin" ]
            ]
        ]


viewDontCard : Html msg
viewDontCard =
    Html.div [ Attr.class "rounded-xl border border-red-200 bg-red-50 p-6 space-y-4" ]
        [ Html.h3 [ Attr.class "type-h4 text-red-800" ] [ Html.text "✗ Älä tee näin" ]
        , Html.ul [ Attr.class "space-y-2 text-sm text-red-900 list-disc list-inside" ]
            [ Html.li [] [ Html.text "Älä käytä raa'oitaTailwind-luokkia kuten ", codeInlineDont "text-2xl font-bold" ]
            , Html.li [] [ Html.text "Älä ohita hierarkiatasoja (esim. H1 → H3)" ]
            , Html.li [] [ Html.text "Älä aseta ", codeInlineDont "html { font-size: ... }", Html.text " — rikkoo rem-skaalan" ]
            , Html.li [] [ Html.text "Älä korvaa Outfitia järjestelmäfontilla suunnitellussa tulosteessa" ]
            , Html.li [] [ Html.text "Älä käytä ", codeInlineDont "type-caption", Html.text " alle 14 px sisällössä" ]
            ]
        ]


codeInline : String -> Html msg
codeInline s =
    Html.code [ Attr.class "font-mono text-xs bg-green-100 text-green-800 px-1 rounded" ] [ Html.text s ]


codeInlineDont : String -> Html msg
codeInlineDont s =
    Html.code [ Attr.class "font-mono text-xs bg-red-100 text-red-800 px-1 rounded" ] [ Html.text s ]



-- ── Usage section ─────────────────────────────────────────────────────────────


viewUsageSection : Html msg
viewUsageSection =
    Html.section [ Attr.id "kaytto" ]
        [ Html.h2 [ Attr.class "text-xl font-bold text-brand mb-6 pb-2 border-b border-gray-200" ]
            [ Html.text "CSS-esimerkki" ]
        , Html.div [ Attr.class "space-y-6" ]
            [ Html.p [ Attr.class "type-body text-gray-600" ]
                [ Html.text "Apuohjelmat on määritelty "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-sm" ] [ Html.text "@utility" ]
                , Html.text "-lohkoilla Tailwind v4:ssä. Käytä luokkanimeä suoraan HTML:ssä:"
                ]
            , Html.pre
                [ Attr.class "bg-gray-900 text-green-300 rounded-xl p-4 overflow-x-auto text-sm font-mono leading-relaxed" ]
                [ Html.text """<!-- Otsikko -->
<h1 class=\"type-h1 text-brand\">Tapahtumakalenteri</h1>

<!-- Osion otsikko -->
<h2 class=\"type-h2\">Tulevat tapahtumat</h2>

<!-- Leipäteksti -->
<p class=\"type-body\">Tapahtuman kuvaus tähän.</p>

<!-- Kategorialabel (overline) -->
<span class=\"type-overline text-text-muted\">Kilpailut</span>

<!-- Kuvateksti -->
<figcaption class=\"type-caption text-text-muted\">Kuva: SPH 2025</figcaption>""" ]
            , Html.p [ Attr.class "type-body-small text-gray-500" ]
                [ Html.text "Huom: Tailwind v4 generoi automaattisesti "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-xs" ] [ Html.text "text-*" ]
                , Html.text "-, "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-xs" ] [ Html.text "bg-*" ]
                , Html.text "- ja "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-xs" ] [ Html.text "border-*" ]
                , Html.text "-apuohjelmat "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-xs" ] [ Html.text "@theme" ]
                , Html.text ":n "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-xs" ] [ Html.text "--color-*" ]
                , Html.text "-muuttujista. Esim. "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-xs" ] [ Html.text "--color-text-muted" ]
                , Html.text " → "
                , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded text-xs" ] [ Html.text "text-text-muted" ]
                , Html.text "."
                ]
            ]
        ]



-- ── Ikonit ────────────────────────────────────────────────────────────────────


viewIconsSection : Html msg
viewIconsSection =
    Html.section [ Attr.id "ikonit", Attr.class "scroll-mt-28 space-y-6" ]
        [ Html.h2 [ Attr.class "text-xl font-bold text-brand mb-6 pb-2 border-b border-gray-200" ]
            [ Html.text "Ikonit" ]
        , Html.p [ Attr.class "text-sm sm:text-base text-gray-500" ]
            [ Html.text "Käytämme "
            , Html.a
                [ Attr.href "https://package.elm-lang.org/packages/feathericons/elm-feather/latest/"
                , Attr.class "underline hover:text-brand transition-colors"
                , Attr.target "_blank"
                , Attr.rel "noopener noreferrer"
                ]
                [ Html.text "feathericons/elm-feather" ]
            , Html.text " (v1.5.0) -kirjastoa. Se tarjoaa yli 280 SVG-ikonia Elm-tyyppiturvallisesti."
            ]
        , viewIconUsage
        , viewIconGrid "Navigaatio" navigationIcons
        , viewIconGrid "Tila ja hälytykset" statusIcons
        , viewIconGrid "Sisältö" contentIcons
        , viewIconGrid "Media" mediaIcons
        , viewIconGrid "Toiminnot" actionIcons
        ]


viewIconUsage : Html msg
viewIconUsage =
    Html.div [ Attr.class "space-y-4" ]
        [ Html.p [ Attr.class "text-sm text-gray-600" ]
            [ Html.text "Tuo kirjasto Elm-moduuliisi ja käytä ikonia putkioperaattorilla:" ]
        , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
            [ Html.code []
                [ Html.text """import FeatherIcons

-- Perusikoni (oletuskoko 24 px)
FeatherIcons.info |> FeatherIcons.toHtml []

-- Mukautettu koko
FeatherIcons.alertTriangle |> FeatherIcons.withSize 18 |> FeatherIcons.toHtml []

-- Lisäattribuutit SVG-elementille
FeatherIcons.check |> FeatherIcons.withSize 16 |> FeatherIcons.toHtml [ Attr.class "text-green-500" ]""" ]
            ]
        , Html.p [ Attr.class "text-xs text-gray-500" ]
            [ Html.text "Ikonit perivät nykyisen tekstivärin ("
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "currentColor" ]
            , Html.text "), joten voit värittää ne Tailwind-väriluokilla kuten "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "text-brand" ]
            , Html.text " tai "
            , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "text-red-500" ]
            , Html.text "."
            ]
        ]


type alias IconEntry =
    { name : String
    , icon : FeatherIcons.Icon
    }


navigationIcons : List IconEntry
navigationIcons =
    [ { name = "menu", icon = FeatherIcons.menu }
    , { name = "x", icon = FeatherIcons.x }
    , { name = "arrowUp", icon = FeatherIcons.arrowUp }
    , { name = "arrowDown", icon = FeatherIcons.arrowDown }
    , { name = "arrowLeft", icon = FeatherIcons.arrowLeft }
    , { name = "arrowRight", icon = FeatherIcons.arrowRight }
    , { name = "home", icon = FeatherIcons.home }
    , { name = "search", icon = FeatherIcons.search }
    , { name = "externalLink", icon = FeatherIcons.externalLink }
    , { name = "chevronUp", icon = FeatherIcons.chevronUp }
    , { name = "chevronDown", icon = FeatherIcons.chevronDown }
    , { name = "chevronLeft", icon = FeatherIcons.chevronLeft }
    , { name = "chevronRight", icon = FeatherIcons.chevronRight }
    ]


statusIcons : List IconEntry
statusIcons =
    [ { name = "info", icon = FeatherIcons.info }
    , { name = "alertTriangle", icon = FeatherIcons.alertTriangle }
    , { name = "alertCircle", icon = FeatherIcons.alertCircle }
    , { name = "checkCircle", icon = FeatherIcons.checkCircle }
    , { name = "xCircle", icon = FeatherIcons.xCircle }
    , { name = "check", icon = FeatherIcons.check }
    , { name = "circle", icon = FeatherIcons.circle }
    , { name = "loader", icon = FeatherIcons.loader }
    ]


contentIcons : List IconEntry
contentIcons =
    [ { name = "calendar", icon = FeatherIcons.calendar }
    , { name = "clock", icon = FeatherIcons.clock }
    , { name = "star", icon = FeatherIcons.star }
    , { name = "flag", icon = FeatherIcons.flag }
    , { name = "users", icon = FeatherIcons.users }
    , { name = "user", icon = FeatherIcons.user }
    , { name = "mapPin", icon = FeatherIcons.mapPin }
    , { name = "fileText", icon = FeatherIcons.fileText }
    , { name = "tag", icon = FeatherIcons.tag }
    , { name = "link", icon = FeatherIcons.link }
    , { name = "mail", icon = FeatherIcons.mail }
    , { name = "phone", icon = FeatherIcons.phone }
    ]


mediaIcons : List IconEntry
mediaIcons =
    [ { name = "rss", icon = FeatherIcons.rss }
    , { name = "camera", icon = FeatherIcons.camera }
    , { name = "youtube", icon = FeatherIcons.youtube }
    , { name = "image", icon = FeatherIcons.image }
    , { name = "video", icon = FeatherIcons.video }
    , { name = "music", icon = FeatherIcons.music }
    ]


actionIcons : List IconEntry
actionIcons =
    [ { name = "zap", icon = FeatherIcons.zap }
    , { name = "settings", icon = FeatherIcons.settings }
    , { name = "edit", icon = FeatherIcons.edit }
    , { name = "edit2", icon = FeatherIcons.edit2 }
    , { name = "trash2", icon = FeatherIcons.trash2 }
    , { name = "plus", icon = FeatherIcons.plus }
    , { name = "plusCircle", icon = FeatherIcons.plusCircle }
    , { name = "minus", icon = FeatherIcons.minus }
    , { name = "download", icon = FeatherIcons.download }
    , { name = "upload", icon = FeatherIcons.upload }
    , { name = "share2", icon = FeatherIcons.share2 }
    , { name = "copy", icon = FeatherIcons.copy }
    , { name = "filter", icon = FeatherIcons.filter }
    , { name = "sliders", icon = FeatherIcons.sliders }
    , { name = "lock", icon = FeatherIcons.lock }
    , { name = "unlock", icon = FeatherIcons.unlock }
    ]


viewIconGrid : String -> List IconEntry -> Html msg
viewIconGrid title icons =
    Html.section [ Attr.class "scroll-mt-28 space-y-4" ]
        [ Html.h3 [ Attr.class "text-base font-semibold text-brand" ] [ Html.text title ]
        , Html.div [ Attr.class "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-3" ]
            (List.map viewIconCard icons)
        ]


viewIconCard : IconEntry -> Html msg
viewIconCard entry =
    Html.div
        [ Attr.class "flex flex-col items-center gap-2 p-3 rounded-lg border border-gray-100 bg-white hover:border-brand/30 hover:bg-brand/5 transition-colors group" ]
        [ Html.div [ Attr.class "text-brand" ]
            [ entry.icon |> FeatherIcons.withSize 24 |> FeatherIcons.toHtml [] ]
        , Html.span [ Attr.class "text-xs text-gray-500 font-mono text-center leading-tight break-all group-hover:text-brand transition-colors" ]
            [ Html.text entry.name ]
        ]
