module Component.Dropdown exposing (view, viewDivider, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr


{-| A CSS-only dropdown using <details>/<summary>.
Closes on focus-out via the browser's native details behavior.
-}
view : { trigger : Html msg, items : List (Html msg) } -> Html msg
view config =
    Html.details
        [ Attr.class "relative inline-block" ]
        [ Html.summary
            [ Attr.class "list-none cursor-pointer inline-flex items-center gap-1 px-4 py-2 text-sm font-medium bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-brand select-none" ]
            [ config.trigger
            , Html.span [ Attr.class "text-gray-400" ] [ Html.text "▾" ]
            ]
        , Html.div
            [ Attr.class "absolute left-0 top-full mt-1 z-10 w-48 rounded-md border border-gray-200 bg-white shadow-lg py-1" ]
            config.items
        ]


viewItem : { label : String, href : String } -> Html msg
viewItem config =
    Html.a
        [ Attr.href config.href
        , Attr.class "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-brand"
        ]
        [ Html.text config.label ]


viewDivider : Html msg
viewDivider =
    Html.hr [ Attr.class "my-1 border-gray-200" ] []
