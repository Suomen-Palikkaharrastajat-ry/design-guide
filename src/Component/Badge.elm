module Component.Badge exposing (Color(..), Size(..), view)

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th


type Color
    = Gray
    | Blue
    | Green
    | Yellow
    | Red
    | Purple
    | Indigo


type Size
    = Small
    | Medium
    | Large


view : { label : String, color : Color, size : Size } -> Html msg
view config =
    Html.span
        [ classes
            ([ Tw.inline_flex, Tw.items_center, Tw.rounded_full, Tw.font_medium ]
                ++ sizeTw config.size
                ++ colorTw config.color
            )
        ]
        [ Html.text config.label ]


sizeTw : Size -> List Tw.Tailwind
sizeTw size =
    case size of
        Small ->
            [ Tw.px (Th.s1_dot_5), Tw.py_px, Tw.text_xs ]

        Medium ->
            [ Tw.px (Th.s2_dot_5), Tw.py (Th.s0_dot_5), Tw.text_xs ]

        Large ->
            [ Tw.px (Th.s3), Tw.py (Th.s1), Tw.text_sm ]


colorTw : Color -> List Tw.Tailwind
colorTw color =
    case color of
        Gray ->
            [ Tw.raw "bg-gray-100", Tw.raw "text-gray-700" ]

        Blue ->
            [ Tw.raw "bg-blue-100", Tw.raw "text-blue-700" ]

        Green ->
            [ Tw.raw "bg-green-100", Tw.raw "text-green-700" ]

        Yellow ->
            [ Tw.raw "bg-yellow-100", Tw.raw "text-yellow-800" ]

        Red ->
            [ Tw.raw "bg-red-100", Tw.raw "text-red-700" ]

        Purple ->
            [ Tw.raw "bg-purple-100", Tw.raw "text-purple-700" ]

        Indigo ->
            [ Tw.raw "bg-indigo-100", Tw.raw "text-indigo-700" ]
