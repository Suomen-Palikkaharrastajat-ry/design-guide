module Component.Spinner exposing (Size(..), view)

import Html exposing (Html)
import Html.Attributes as Attr


view : { size : Size, label : String } -> Html msg
view config =
    Html.div
        [ Attr.class "inline-flex items-center gap-2"
        , Attr.attribute "role" "status"
        ]
        [ Html.div
            [ Attr.class ("animate-spin rounded-full border-2 border-gray-200 border-t-brand " ++ sizeClass config.size) ]
            []
        , Html.span [ Attr.class "sr-only" ] [ Html.text config.label ]
        ]


type Size
    = Small
    | Medium
    | Large


sizeClass : Size -> String
sizeClass size =
    case size of
        Small ->
            "w-4 h-4"

        Medium ->
            "w-6 h-6"

        Large ->
            "w-10 h-10"
