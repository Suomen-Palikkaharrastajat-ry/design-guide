module Component.Progress exposing (Color(..), view)

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindTokens as TC


view :
    { value : Int
    , max : Int
    , label : Maybe String
    , color : Color
    }
    -> Html msg
view config =
    let
        pct =
            toFloat config.value / toFloat config.max * 100 |> round |> clamp 0 100
    in
    Html.div [ classes [ Tw.raw "space-y-1" ] ]
        (case config.label of
            Just lbl ->
                [ Html.div [ classes [ Tw.flex, Tw.justify_between, Tw.text_sm, Tw.raw "text-gray-600" ] ]
                    [ Html.span [] [ Html.text lbl ]
                    , Html.span [] [ Html.text (String.fromInt pct ++ "%") ]
                    ]
                , bar pct config.color
                ]

            Nothing ->
                [ bar pct config.color ]
        )


bar : Int -> Color -> Html msg
bar pct color =
    Html.div
        [ classes [ Tw.w_full, Tw.raw "bg-gray-200", Tw.rounded_full, Tw.h (Th.s2_dot_5), Tw.overflow_hidden ]
        , Attr.attribute "role" "progressbar"
        , Attr.attribute "aria-valuenow" (String.fromInt pct)
        , Attr.attribute "aria-valuemin" "0"
        , Attr.attribute "aria-valuemax" "100"
        ]
        [ Html.div
            [ classes ([ Tw.h (Th.s2_dot_5), Tw.rounded_full, Tw.transition_all ] ++ colorTw color)
            , Attr.style "width" (String.fromInt pct ++ "%")
            ]
            []
        ]


type Color
    = Brand
    | Success
    | Warning
    | Danger
    | Info


colorTw : Color -> List Tw.Tailwind
colorTw color =
    case color of
        Brand ->
            [ Tw.bg_simple TC.brand ]

        Success ->
            [ Tw.raw "bg-green-500" ]

        Warning ->
            [ Tw.raw "bg-yellow-500" ]

        Danger ->
            [ Tw.raw "bg-red-500" ]

        Info ->
            [ Tw.raw "bg-blue-500" ]
