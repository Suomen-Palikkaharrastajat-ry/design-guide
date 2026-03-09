module Component.Card exposing (Shadow(..), view, viewSimple)

import Html exposing (Html)
import Html.Attributes as Attr


type Shadow
    = None
    | Sm
    | Md
    | Lg


view :
    { header : Maybe (Html msg)
    , body : List (Html msg)
    , footer : Maybe (Html msg)
    , image : Maybe String
    , shadow : Shadow
    }
    -> Html msg
view config =
    Html.div
        [ Attr.class ("bg-white rounded-xl border border-gray-200 overflow-hidden " ++ shadowClass config.shadow) ]
        (List.filterMap identity
            [ Maybe.map viewImage config.image
            , Maybe.map viewHeader config.header
            , Just (viewBody config.body)
            , Maybe.map viewFooter config.footer
            ]
        )


viewSimple : List (Html msg) -> Html msg
viewSimple body =
    Html.div
        [ Attr.class "bg-white rounded-xl border border-gray-200 p-6" ]
        body


viewImage : String -> Html msg
viewImage src =
    Html.img
        [ Attr.src src
        , Attr.alt ""
        , Attr.class "w-full object-cover"
        ]
        []


viewHeader : Html msg -> Html msg
viewHeader content =
    Html.div
        [ Attr.class "px-6 py-4 border-b border-gray-100" ]
        [ content ]


viewBody : List (Html msg) -> Html msg
viewBody content =
    Html.div
        [ Attr.class "p-6" ]
        content


viewFooter : Html msg -> Html msg
viewFooter content =
    Html.div
        [ Attr.class "px-6 py-4 bg-gray-50 border-t border-gray-100" ]
        [ content ]


shadowClass : Shadow -> String
shadowClass shadow =
    case shadow of
        None ->
            ""

        Sm ->
            "shadow-sm"

        Md ->
            "shadow-md"

        Lg ->
            "shadow-lg"
