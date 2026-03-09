module Component.ListGroup exposing (view, viewActionItem, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : List (Html msg) -> Html msg
view items =
    Html.ul
        [ Attr.class "divide-y divide-gray-200 rounded-lg border border-gray-200 overflow-hidden" ]
        items


viewItem : { label : String, badge : Maybe String } -> Html msg
viewItem config =
    Html.li
        [ Attr.class "flex items-center justify-between bg-white px-4 py-3 text-sm text-gray-800" ]
        [ Html.span [] [ Html.text config.label ]
        , case config.badge of
            Just b ->
                Html.span
                    [ Attr.class "inline-flex items-center rounded-full bg-brand/10 px-2 py-0.5 text-xs font-medium text-brand" ]
                    [ Html.text b ]

            Nothing ->
                Html.text ""
        ]


viewActionItem : { label : String, onClick : msg, active : Bool } -> Html msg
viewActionItem config =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , Attr.class
                (if config.active then
                    "w-full text-left px-4 py-3 text-sm font-medium bg-brand text-white cursor-pointer"

                 else
                    "w-full text-left px-4 py-3 text-sm text-gray-800 bg-white hover:bg-gray-50 hover:text-brand transition-colors cursor-pointer"
                )
            , Events.onClick config.onClick
            ]
            [ Html.text config.label ]
        ]
