module Component.ButtonGroup exposing (Position(..), view, viewButton, viewEllipsis)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : List (Html msg) -> Html msg
view buttons =
    Html.div
        [ Attr.class "inline-flex rounded-md shadow-sm"
        , Attr.attribute "role" "group"
        ]
        buttons


viewButton :
    { label : String
    , onClick : msg
    , active : Bool
    , position : Position
    }
    -> Html msg
viewButton config =
    Html.button
        [ Attr.type_ "button"
        , Attr.class (buttonClass config.active config.position)
        , Events.onClick config.onClick
        ]
        [ Html.text config.label ]


viewEllipsis : Html msg
viewEllipsis =
    Html.span
        [ Attr.class "inline-flex items-center px-3 py-2 type-body-small border border-gray-300 border-r-0 bg-white text-gray-400 select-none" ]
        [ Html.text "⋯" ]


type Position
    = First
    | Middle
    | Last
    | Only


buttonClass : Bool -> Position -> String
buttonClass active position =
    let
        base =
            "px-4 py-2 type-body-small border transition-colors cursor-pointer focus-visible:z-10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand "

        corners =
            case position of
                First ->
                    "rounded-l-md rounded-r-none border-r-0 "

                Middle ->
                    "rounded-none border-r-0 "

                Last ->
                    "rounded-r-md rounded-l-none "

                Only ->
                    "rounded-md "

        colors =
            if active then
                "bg-brand text-white border-brand"

            else
                "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
    in
    base ++ corners ++ colors
