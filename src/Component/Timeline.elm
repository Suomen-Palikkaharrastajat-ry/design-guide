module Component.Timeline exposing (view, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view items =
    Html.ol
        [ classes
            [ Tw.raw "not-prose"
            , Tw.relative
            , Tw.border_s_2
            , Tw.raw "border-gray-200"
            , Tw.raw "space-y-0"
            , Tw.raw "ms-8"
            ]
        ]
        items


viewItem : { date : String, title : String, children : List (Html msg), icon : Maybe (Html msg), image : Maybe String } -> Html msg
viewItem config =
    Html.li
        [ classes [ Tw.mb (Th.s10), Tw.raw "ms-12" ] ]
        [ Html.span
            [ classes
                [ Tw.absolute
                , Tw.raw "-start-6"
                , Tw.flex
                , Tw.h (Th.s12)
                , Tw.w (Th.s12)
                , Tw.items_center
                , Tw.justify_center
                , Tw.rounded_full
                , Tw.bg_simple TC.brandYellow
                ]
            ]
            [ case config.icon of
                Nothing ->
                    Html.span [ classes [ Tw.block, Tw.h (Th.s4), Tw.w (Th.s4), Tw.rounded_full, Tw.bg_simple TC.brand ] ] []

                Just icon ->
                    Html.span [ classes [ Tw.text_simple TC.brand ] ] [ icon ]
            ]
        , Html.div [ classes [ Tw.flex, Tw.items_start, Tw.gap (Th.s4) ] ]
            [ Html.div [ classes [ Tw.flex_1, Tw.min_w (Th.s0) ] ]
                [ Html.time
                    [ classes [ Tw.mb (Th.s1), Tw.block, Tw.text_xs, Tw.font_normal, Tw.raw "leading-none", Tw.raw "text-gray-400" ] ]
                    [ Html.text config.date ]
                , Html.h3
                    [ classes [ Tw.type_body_small, Tw.text_simple TC.brand ] ]
                    [ Html.text config.title ]
                , Html.div
                    [ classes [ Tw.mt (Th.s1), Tw.text_sm, Tw.raw "leading-6", Tw.raw "text-gray-600" ] ]
                    config.children
                ]
            , case config.image of
                Nothing ->
                    Html.text ""

                Just src ->
                    Html.img
                        [ Attr.src src
                        , Attr.alt ""
                        , classes [ Tw.w (Th.s24), Tw.h (Th.s24), Tw.object_cover, Tw.rounded_lg, Tw.shrink_0 ]
                        ]
                        []
            ]
        ]
