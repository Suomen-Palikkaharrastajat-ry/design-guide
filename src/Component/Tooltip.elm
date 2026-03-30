module Component.Tooltip exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th


view : { content : String, children : List (Html msg) } -> Html msg
view config =
    Html.div [ classes [ Tw.relative, Tw.inline_flex, Tw.raw "group" ] ]
        (Html.div
            [ classes
                [ Tw.absolute
                , Tw.bottom_full
                , Tw.raw "left-1/2"
                , Tw.raw "-translate-x-1/2"
                , Tw.mb (Th.s2)
                , Tw.px (Th.s2)
                , Tw.py (Th.s1)
                , Tw.rounded
                , Tw.raw "bg-gray-900"
                , Tw.raw "text-white"
                , Tw.text_xs
                , Tw.whitespace_nowrap
                , Tw.opacity_0
                , Tw.pointer_events_none
                , Bp.group_hover [ Tw.opacity_100 ]
                , Bp.withVariant "group-focus-within" [ Tw.opacity_100 ]
                , Tw.transition_opacity
                , Tw.z_20
                ]
            , Attr.attribute "role" "tooltip"
            ]
            [ Html.text config.content
            , Html.div
                [ classes
                    [ Tw.absolute
                    , Tw.top_full
                    , Tw.raw "left-1/2"
                    , Tw.raw "-translate-x-1/2"
                    , Tw.border_4
                    , Tw.raw "border-transparent"
                    , Tw.raw "border-t-gray-900"
                    ]
                ]
                []
            ]
            :: config.children
        )
