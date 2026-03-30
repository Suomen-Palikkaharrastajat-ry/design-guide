module Component.Alert exposing (AlertType(..), view)

import Component.CloseButton as CloseButton
import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th


type AlertType
    = Info
    | Success
    | Warning
    | Error


view : { alertType : AlertType, title : Maybe String, body : List (Html msg), onDismiss : Maybe msg } -> Html msg
view config =
    Html.div
        (List.filterMap identity
            [ Just (classes (containerTw config.alertType ++ dismissTw config.onDismiss))
            , Maybe.map (\_ -> Attr.attribute "role" "alert") config.onDismiss
            ]
        )
        (List.filterMap identity
            [ Just
                (Html.div [ classes [ Tw.flex ] ]
                    [ Html.div [ classes [ Tw.shrink_0, Tw.leading_none ] ]
                        [ icon config.alertType ]
                    , Html.div [ classes [ Tw.ml (Th.s3) ] ]
                        (List.filterMap identity
                            [ Maybe.map
                                (\t ->
                                    Html.p
                                        [ classes ([ Tw.font_semibold ] ++ titleTw config.alertType) ]
                                        [ Html.text t ]
                                )
                                config.title
                            , Just
                                (Html.div
                                    [ classes ([ Tw.text_sm ] ++ bodyTw config.alertType) ]
                                    config.body
                                )
                            ]
                        )
                    ]
                )
            , Maybe.map
                (\msg ->
                    Html.div [ classes [ Tw.absolute, Tw.raw "top-2", Tw.raw "right-2" ] ]
                        [ CloseButton.view { onClick = msg, label = "Sulje ilmoitus" } ]
                )
                config.onDismiss
            ]
        )


dismissTw : Maybe msg -> List Tw.Tailwind
dismissTw onDismiss =
    case onDismiss of
        Just _ ->
            [ Tw.relative ]

        Nothing ->
            []


containerTw : AlertType -> List Tw.Tailwind
containerTw alertType =
    [ Tw.rounded_lg, Tw.p (Th.s4) ]
        ++ (case alertType of
                Info ->
                    [ Tw.raw "bg-blue-50" ]

                Success ->
                    [ Tw.raw "bg-green-50" ]

                Warning ->
                    [ Tw.raw "bg-yellow-50" ]

                Error ->
                    [ Tw.raw "bg-red-50" ]
           )


icon : AlertType -> Html msg
icon alertType =
    (case alertType of
        Info ->
            FeatherIcons.info

        Success ->
            FeatherIcons.checkCircle

        Warning ->
            FeatherIcons.alertTriangle

        Error ->
            FeatherIcons.xCircle
    )
        |> FeatherIcons.withSize 18
        |> FeatherIcons.toHtml []


titleTw : AlertType -> List Tw.Tailwind
titleTw alertType =
    case alertType of
        Info ->
            [ Tw.raw "text-blue-800" ]

        Success ->
            [ Tw.raw "text-green-800" ]

        Warning ->
            [ Tw.raw "text-yellow-800" ]

        Error ->
            [ Tw.raw "text-red-800" ]


bodyTw : AlertType -> List Tw.Tailwind
bodyTw alertType =
    case alertType of
        Info ->
            [ Tw.raw "text-blue-700" ]

        Success ->
            [ Tw.raw "text-green-700" ]

        Warning ->
            [ Tw.raw "text-yellow-700" ]

        Error ->
            [ Tw.raw "text-red-700" ]
