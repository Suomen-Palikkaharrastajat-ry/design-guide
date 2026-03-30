module Component.CloseButton exposing (view)

import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th


view : { onClick : msg, label : String } -> Html msg
view config =
    Html.button
        [ classes
            [ Tw.inline_flex
            , Tw.items_center
            , Tw.justify_center
            , Tw.w (Th.s11)
            , Tw.h (Th.s11)
            , Tw.rounded
            , Tw.raw "text-gray-400"
            , Bp.hover [ Tw.raw "text-gray-600", Tw.raw "bg-gray-100" ]
            , Tw.transition_colors
            , Tw.cursor_pointer
            , Bp.focus_visible [ Tw.outline_none, Tw.ring_2, Tw.raw "ring-brand", Tw.ring_offset_2 ]
            ]
        , Attr.type_ "button"
        , Attr.attribute "aria-label" config.label
        , Events.onClick config.onClick
        ]
        [ FeatherIcons.x |> FeatherIcons.withSize 18 |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
        ]
