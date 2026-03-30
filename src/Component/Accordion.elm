module Component.Accordion exposing (view, viewItem)

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view items =
    Html.div
        [ classes
            [ Tw.raw "divide-y"
            , Tw.raw "divide-gray-200"
            , Tw.border
            , Tw.raw "border-gray-200"
            , Tw.rounded_lg
            , Tw.overflow_hidden
            ]
        ]
        items


viewItem : { title : String, body : List (Html msg) } -> Html msg
viewItem config =
    Html.details
        [ classes [ Tw.raw "group", Tw.raw "bg-white" ] ]
        [ Html.summary
            [ classes
                [ Tw.flex
                , Tw.cursor_pointer
                , Tw.items_center
                , Tw.justify_between
                , Tw.px (Th.s6)
                , Tw.py (Th.s4)
                , Tw.font_medium
                , Tw.text_simple TC.brand
                , Tw.select_none
                , Bp.hover [ Tw.raw "bg-gray-50" ]
                ]
            ]
            [ Html.span [] [ Html.text config.title ]
            , Html.span
                [ classes
                    [ Tw.ml (Th.s4)
                    , Tw.shrink_0
                    , Tw.raw "text-gray-400"
                    , Tw.transition_transform
                    , Bp.withVariant "group-open" [ Tw.rotate_180 ]
                    ]
                ]
                [ Html.text "▾" ]
            ]
        , Html.div
            [ classes
                [ Tw.px (Th.s6)
                , Tw.py (Th.s4)
                , Tw.text_sm
                , Tw.raw "text-gray-600"
                , Tw.border_t
                , Tw.raw "border-gray-100"
                ]
            ]
            config.body
        ]
