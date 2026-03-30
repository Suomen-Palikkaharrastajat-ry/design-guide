module Component.Footer exposing (LinkGroup, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


type alias LinkGroup =
    { heading : String
    , links : List { label : String, href : String }
    }


view :
    { groups : List LinkGroup
    , copyright : String
    }
    -> Html msg
view config =
    Html.footer
        [ classes [ Tw.bg_simple TC.brand ] ]
        [ Html.div
            [ classes [ Tw.mx_auto, Tw.raw "max-w-7xl", Tw.px (Th.s6), Tw.py (Th.s12), Bp.lg [ Tw.px (Th.s8) ] ] ]
            [ Html.div
                [ classes [ Tw.grid, Tw.grid_cols_2, Tw.gap (Th.s8), Bp.md [ Tw.grid_cols_4 ] ] ]
                (List.map viewGroup config.groups)
            , Html.div
                [ classes [ Tw.mt (Th.s10), Tw.border_t, Tw.raw "border-white/10", Tw.pt (Th.s8) ] ]
                [ Html.p
                    [ classes [ Tw.type_caption, Tw.raw "text-white/50", Tw.text_center ] ]
                    [ Html.text config.copyright ]
                ]
            ]
        ]


viewGroup : LinkGroup -> Html msg
viewGroup group =
    Html.div []
        [ Html.h3
            [ classes [ Tw.type_body_small, Tw.raw "text-white" ] ]
            [ Html.text group.heading ]
        , Html.ul
            [ classes [ Tw.mt (Th.s4), Tw.raw "space-y-3" ] ]
            (List.map viewGroupLink group.links)
        ]


viewGroupLink : { label : String, href : String } -> Html msg
viewGroupLink link =
    Html.li []
        [ Html.a
            [ Attr.href link.href
            , classes
                [ Tw.type_caption
                , Tw.raw "text-white/60"
                , Bp.hover [ Tw.raw "text-white" ]
                , Bp.withVariant "motion-safe" [ Tw.transition_colors ]
                ]
            ]
            [ Html.text link.label ]
        ]
