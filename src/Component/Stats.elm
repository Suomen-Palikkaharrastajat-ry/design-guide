module Component.Stats exposing (view, viewItem)

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view items =
    Html.dl
        [ classes
            [ Tw.raw "not-prose"
            , Tw.grid
            , Tw.grid_cols_1
            , Tw.raw "gap-px"
            , Tw.raw "bg-gray-200"
            , Tw.rounded_lg
            , Tw.overflow_hidden
            , Bp.sm [ Tw.grid_cols_2 ]
            , Bp.lg [ Tw.grid_cols_4 ]
            ]
        ]
        items


viewItem : { label : String, value : String, change : Maybe String } -> Html msg
viewItem config =
    Html.div
        [ classes
            [ Tw.flex
            , Tw.flex_wrap
            , Tw.items_baseline
            , Tw.justify_between
            , Tw.gap_x (Th.s4)
            , Tw.gap_y (Th.s2)
            , Tw.raw "bg-white"
            , Tw.px (Th.s6)
            , Tw.py (Th.s5)
            , Bp.sm [ Tw.px (Th.s8) ]
            ]
        ]
        [ Html.dt
            [ classes [ Tw.type_body_small, Tw.raw "leading-6", Tw.raw "text-gray-500" ] ]
            [ Html.text config.label ]
        , case config.change of
            Just change ->
                Html.dd [ classes [ Tw.text_xs, Tw.font_medium, Tw.text_simple TC.brand ] ] [ Html.text change ]

            Nothing ->
                Html.text ""
        , Html.dd
            [ classes [ Tw.w_full, Tw.flex_none, Tw.text_n3xl, Tw.font_medium, Tw.raw "leading-10", Tw.tracking_tight, Tw.text_simple TC.brand ] ]
            [ Html.text config.value ]
        ]
