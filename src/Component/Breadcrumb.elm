module Component.Breadcrumb exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


view : List { label : String, href : Maybe String } -> Html msg
view items =
    Html.nav [ Attr.attribute "aria-label" "breadcrumb" ]
        [ Html.ol
            [ Attr.class "flex flex-wrap items-center gap-1.5 text-sm text-gray-500" ]
            (List.indexedMap (viewItem (List.length items)) items)
        ]


viewItem : Int -> Int -> { label : String, href : Maybe String } -> Html msg
viewItem total idx item =
    let
        isLast =
            idx == total - 1
    in
    Html.li [ Attr.class "flex items-center gap-1.5" ]
        ([ if isLast then
            Html.span
                [ Attr.class "font-medium text-gray-900"
                , Attr.attribute "aria-current" "page"
                ]
                [ Html.text item.label ]

           else
            case item.href of
                Just href ->
                    Html.a
                        [ Attr.href href
                        , Attr.class "hover:text-brand transition-colors"
                        ]
                        [ Html.text item.label ]

                Nothing ->
                    Html.span [] [ Html.text item.label ]
         ]
            ++ (if isLast then
                    []

                else
                    [ Html.span [ Attr.class "text-gray-300 select-none" ] [ Html.text "/" ] ]
               )
        )
