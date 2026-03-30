module Component.Card exposing (Shadow(..), view, viewSimple)

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th


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
        [ classes
            ([ Tw.raw "bg-white"
             , Tw.rounded_xl
             , Tw.border
             , Tw.raw "border-gray-200"
             , Tw.overflow_hidden
             ]
                ++ shadowTw config.shadow
            )
        ]
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
        [ classes [ Tw.raw "bg-white", Tw.rounded_xl, Tw.border, Tw.raw "border-gray-200", Tw.p (Th.s6) ] ]
        body


viewImage : String -> Html msg
viewImage src =
    Html.img
        [ Attr.src src
        , Attr.alt ""
        , classes [ Tw.w_full, Tw.object_cover ]
        ]
        []


viewHeader : Html msg -> Html msg
viewHeader content =
    Html.div
        [ classes [ Tw.px (Th.s6), Tw.py (Th.s4) ] ]
        [ content ]


viewBody : List (Html msg) -> Html msg
viewBody content =
    Html.div
        [ classes [ Tw.p (Th.s6) ] ]
        content


viewFooter : Html msg -> Html msg
viewFooter content =
    Html.div
        [ classes [ Tw.px (Th.s6), Tw.py (Th.s4), Tw.border_t, Tw.raw "border-gray-100" ] ]
        [ content ]


shadowTw : Shadow -> List Tw.Tailwind
shadowTw shadow =
    case shadow of
        None ->
            []

        Sm ->
            [ Tw.shadow_sm ]

        Md ->
            [ Tw.shadow_md ]

        Lg ->
            [ Tw.shadow_lg ]
