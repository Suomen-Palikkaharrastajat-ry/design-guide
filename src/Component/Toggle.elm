module Component.Toggle exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


view : { id : String, label : String, checked : Bool, onToggle : Bool -> msg, disabled : Bool } -> Html msg
view config =
    Html.label
        [ Attr.for config.id
        , classes [ Tw.inline_flex, Tw.items_center, Tw.gap (Th.s3), Tw.cursor_pointer ]
        ]
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.id config.id
            , Attr.checked config.checked
            , Attr.disabled config.disabled
            , classes [ Tw.sr_only, Tw.raw "peer" ]
            , Events.onCheck config.onToggle
            ]
            []
        , Html.div
            [ classes
                [ Tw.relative
                , Tw.w (Th.s11)
                , Tw.h (Th.s6)
                , Tw.rounded_full
                , Tw.transition_colors
                , Tw.raw "bg-gray-300"
                , Bp.withVariant "peer-checked" [ Tw.bg_simple TC.brand ]
                , Bp.withVariant "peer-focus-visible" [ Tw.ring_2, Tw.raw "ring-brand", Tw.ring_offset_2 ]
                , Bp.withVariant "peer-disabled" [ Tw.opacity_50, Tw.cursor_not_allowed ]
                ]
            ]
            [ Html.div
                [ classes
                    [ Tw.absolute
                    , Tw.raw "top-0.5"
                    , Tw.raw "left-0.5"
                    , Tw.w (Th.s5)
                    , Tw.h (Th.s5)
                    , Tw.rounded_full
                    , Tw.raw "bg-white"
                    , Tw.shadow
                    , Tw.transition_transform
                    , Bp.withVariant "peer-checked" [ Tw.raw "translate-x-5" ]
                    ]
                ]
                []
            ]
        , Html.span [ classes [ Tw.text_sm, Tw.raw "text-gray-700" ] ] [ Html.text config.label ]
        ]
