module Component.Accordion exposing (view, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr


view : List (Html msg) -> Html msg
view items =
    Html.div
        [ Attr.class "divide-y divide-gray-200 border border-gray-200 rounded-lg overflow-hidden" ]
        items


viewItem : { title : String, body : List (Html msg) } -> Html msg
viewItem config =
    Html.details
        [ Attr.class "group bg-white" ]
        [ Html.summary
            [ Attr.class "flex cursor-pointer items-center justify-between px-6 py-4 font-medium text-brand select-none hover:bg-gray-50" ]
            [ Html.span [] [ Html.text config.title ]
            , Html.span
                [ Attr.class "ml-4 flex-shrink-0 text-gray-400 transition-transform group-open:rotate-180" ]
                [ Html.text "▾" ]
            ]
        , Html.div
            [ Attr.class "px-6 py-4 text-sm text-gray-600 border-t border-gray-100" ]
            config.body
        ]
