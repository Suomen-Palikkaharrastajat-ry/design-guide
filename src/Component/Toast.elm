module Component.Toast exposing (Variant(..), view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


type Variant
    = Default
    | Success
    | Warning
    | Danger


view :
    { title : String
    , body : String
    , variant : Variant
    , onClose : Maybe msg
    }
    -> Html msg
view config =
    Html.div
        [ Attr.class ("flex items-start gap-3 w-80 rounded-lg border p-4 shadow-lg bg-white " ++ borderClass config.variant) ]
        [ Html.div
            [ Attr.class ("mt-0.5 flex-shrink-0 text-lg " ++ iconColorClass config.variant) ]
            [ Html.text (icon config.variant) ]
        , Html.div [ Attr.class "flex-1 min-w-0" ]
            [ Html.p [ Attr.class "text-sm font-medium text-gray-900" ] [ Html.text config.title ]
            , Html.p [ Attr.class "mt-0.5 text-sm text-gray-500" ] [ Html.text config.body ]
            ]
        , case config.onClose of
            Just onClose ->
                Html.button
                    [ Attr.type_ "button"
                    , Attr.class "flex-shrink-0 text-gray-400 hover:text-gray-600 transition-colors"
                    , Attr.attribute "aria-label" "Sulje"
                    , Events.onClick onClose
                    ]
                    [ Html.text "×" ]

            Nothing ->
                Html.text ""
        ]


borderClass : Variant -> String
borderClass variant =
    case variant of
        Default ->
            "border-gray-200"

        Success ->
            "border-green-200"

        Warning ->
            "border-yellow-200"

        Danger ->
            "border-red-200"


iconColorClass : Variant -> String
iconColorClass variant =
    case variant of
        Default ->
            "text-brand"

        Success ->
            "text-green-500"

        Warning ->
            "text-yellow-500"

        Danger ->
            "text-red-500"


icon : Variant -> String
icon variant =
    case variant of
        Default ->
            "ℹ"

        Success ->
            "✓"

        Warning ->
            "⚠"

        Danger ->
            "✕"
