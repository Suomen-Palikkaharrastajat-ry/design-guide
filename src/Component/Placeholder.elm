module Component.Placeholder exposing (view, viewBlock, viewLine)

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th


view : List (Html msg) -> Html msg
view items =
    Html.div [ classes [ Tw.animate_pulse, Tw.raw "space-y-3" ] ] items


viewLine : { widthClass : List Tw.Tailwind } -> Html msg
viewLine config =
    Html.div
        [ classes ([ Tw.h (Th.s4), Tw.raw "bg-gray-200", Tw.rounded ] ++ config.widthClass) ]
        []


viewBlock : { widthClass : List Tw.Tailwind, heightClass : List Tw.Tailwind } -> Html msg
viewBlock config =
    Html.div
        [ classes ([ Tw.raw "bg-gray-200", Tw.rounded ] ++ config.widthClass ++ config.heightClass) ]
        []
