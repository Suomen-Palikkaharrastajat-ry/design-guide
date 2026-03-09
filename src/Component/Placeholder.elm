module Component.Placeholder exposing (view, viewBlock, viewLine)

import Html exposing (Html)
import Html.Attributes as Attr


view : List (Html msg) -> Html msg
view items =
    Html.div [ Attr.class "animate-pulse space-y-3" ] items


viewLine : { widthClass : String } -> Html msg
viewLine config =
    Html.div
        [ Attr.class ("h-4 bg-gray-200 rounded " ++ config.widthClass) ]
        []


viewBlock : { widthClass : String, heightClass : String } -> Html msg
viewBlock config =
    Html.div
        [ Attr.class ("bg-gray-200 rounded " ++ config.widthClass ++ " " ++ config.heightClass) ]
        []
