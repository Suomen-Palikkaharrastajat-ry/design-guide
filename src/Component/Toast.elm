module Component.Toast exposing (Variant(..), view)

import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


type Variant
    = Default
    | Success
    | Warning
    | Danger


view :
    { title : String
    , body : String
    , variant : Variant
    , onClose : Maybe msg
    }
    -> Html msg
view config =
    Html.div
        [ classes
            ([ Tw.flex
             , Tw.items_start
             , Tw.gap (Th.s3)
             , Tw.w (Th.s80)
             , Tw.rounded_lg
             , Tw.border
             , Tw.p (Th.s4)
             , Tw.shadow_lg
             , Tw.raw "bg-white"
             ]
                ++ borderTw config.variant
            )
        ]
        [ Html.div
            [ classes ([ Tw.mt (Th.s0_dot_5), Tw.shrink_0, Tw.leading_none ] ++ iconColorTw config.variant) ]
            [ icon config.variant ]
        , Html.div [ classes [ Tw.flex_1, Tw.min_w (Th.s0) ] ]
            [ Html.p [ classes [ Tw.type_body_small, Tw.raw "text-gray-900" ] ] [ Html.text config.title ]
            , Html.p [ classes [ Tw.mt (Th.s0_dot_5), Tw.text_sm, Tw.raw "text-gray-500" ] ] [ Html.text config.body ]
            ]
        , case config.onClose of
            Just onClose ->
                Html.button
                    [ Attr.type_ "button"
                    , classes [ Tw.shrink_0, Tw.raw "text-gray-400", Bp.hover [ Tw.raw "text-gray-600" ], Tw.transition_colors ]
                    , Attr.attribute "aria-label" "Sulje"
                    , Events.onClick onClose
                    ]
                    [ FeatherIcons.x |> FeatherIcons.withSize 16 |> FeatherIcons.toHtml [] ]

            Nothing ->
                Html.text ""
        ]


borderTw : Variant -> List Tw.Tailwind
borderTw variant =
    case variant of
        Default ->
            [ Tw.raw "border-gray-200" ]

        Success ->
            [ Tw.raw "border-green-200" ]

        Warning ->
            [ Tw.raw "border-yellow-200" ]

        Danger ->
            [ Tw.raw "border-red-200" ]


iconColorTw : Variant -> List Tw.Tailwind
iconColorTw variant =
    case variant of
        Default ->
            [ Tw.text_simple TC.brand ]

        Success ->
            [ Tw.raw "text-green-500" ]

        Warning ->
            [ Tw.raw "text-yellow-500" ]

        Danger ->
            [ Tw.raw "text-red-500" ]


icon : Variant -> Html msg
icon variant =
    (case variant of
        Default ->
            FeatherIcons.info

        Success ->
            FeatherIcons.checkCircle

        Warning ->
            FeatherIcons.alertTriangle

        Danger ->
            FeatherIcons.xCircle
    )
        |> FeatherIcons.withSize 18
        |> FeatherIcons.toHtml []
