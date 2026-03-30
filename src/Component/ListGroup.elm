module Component.ListGroup exposing (view, viewActionItem, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view items =
    Html.ul
        [ classes
            [ Tw.raw "divide-y"
            , Tw.raw "divide-gray-200"
            , Tw.rounded_lg
            , Tw.border
            , Tw.raw "border-gray-200"
            , Tw.overflow_hidden
            ]
        ]
        items


viewItem : { label : String, badge : Maybe String } -> Html msg
viewItem config =
    Html.li
        [ classes [ Tw.flex, Tw.items_center, Tw.justify_between, Tw.raw "bg-white", Tw.px (Th.s4), Tw.py (Th.s3), Tw.text_sm, Tw.raw "text-gray-800" ] ]
        [ Html.span [] [ Html.text config.label ]
        , case config.badge of
            Just b ->
                Html.span
                    [ classes [ Tw.inline_flex, Tw.items_center, Tw.rounded_full, Tw.raw "bg-brand/10", Tw.px (Th.s2), Tw.py (Th.s0_dot_5), Tw.text_xs, Tw.font_medium, Tw.text_simple TC.brand ] ]
                    [ Html.text b ]

            Nothing ->
                Html.text ""
        ]


viewActionItem : { label : String, onClick : msg, active : Bool } -> Html msg
viewActionItem config =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , classes
                ([ Tw.w_full, Tw.raw "text-left", Tw.px (Th.s4), Tw.py (Th.s3), Tw.cursor_pointer ]
                    ++ (if config.active then
                            [ Tw.type_body_small, Tw.bg_simple TC.brand, Tw.raw "text-white" ]

                        else
                            [ Tw.text_sm, Tw.raw "text-gray-800", Tw.raw "bg-white", Bp.hover [ Tw.raw "bg-gray-50", Tw.text_simple TC.brand ], Tw.transition_colors ]
                       )
                )
            , Events.onClick config.onClick
            ]
            [ Html.text config.label ]
        ]
