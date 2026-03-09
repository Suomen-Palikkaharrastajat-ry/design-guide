module Component.Progress exposing (Color(..), view)

import Html exposing (Html)
import Html.Attributes as Attr


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
    Html.div [ Attr.class "space-y-1" ]
        (case config.label of
            Just lbl ->
                [ Html.div [ Attr.class "flex justify-between text-sm text-gray-600" ]
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
        [ Attr.class "w-full bg-gray-200 rounded-full h-2.5 overflow-hidden"
        , Attr.attribute "role" "progressbar"
        , Attr.attribute "aria-valuenow" (String.fromInt pct)
        , Attr.attribute "aria-valuemin" "0"
        , Attr.attribute "aria-valuemax" "100"
        ]
        [ Html.div
            [ Attr.class ("h-2.5 rounded-full transition-all " ++ colorClass color)
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


colorClass : Color -> String
colorClass color =
    case color of
        Brand ->
            "bg-brand"

        Success ->
            "bg-green-500"

        Warning ->
            "bg-yellow-500"

        Danger ->
            "bg-red-500"

        Info ->
            "bg-blue-500"
