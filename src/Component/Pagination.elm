module Component.Pagination exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view :
    { currentPage : Int
    , totalPages : Int
    , onPageClick : Int -> msg
    }
    -> Html msg
view config =
    Html.nav
        [ Attr.attribute "aria-label" "Sivutus" ]
        [ Html.ul
            [ Attr.class "inline-flex items-center gap-1 text-sm" ]
            (prevButton config
                :: List.map (pageButton config) (List.range 1 config.totalPages)
                ++ [ nextButton config ]
            )
        ]


prevButton : { currentPage : Int, totalPages : Int, onPageClick : Int -> msg } -> Html msg
prevButton config =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , Attr.class (navBtnClass (config.currentPage <= 1))
            , Attr.disabled (config.currentPage <= 1)
            , Events.onClick (config.onPageClick (config.currentPage - 1))
            , Attr.attribute "aria-label" "Edellinen"
            ]
            [ Html.text "‹" ]
        ]


nextButton : { currentPage : Int, totalPages : Int, onPageClick : Int -> msg } -> Html msg
nextButton config =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , Attr.class (navBtnClass (config.currentPage >= config.totalPages))
            , Attr.disabled (config.currentPage >= config.totalPages)
            , Events.onClick (config.onPageClick (config.currentPage + 1))
            , Attr.attribute "aria-label" "Seuraava"
            ]
            [ Html.text "›" ]
        ]


pageButton : { currentPage : Int, totalPages : Int, onPageClick : Int -> msg } -> Int -> Html msg
pageButton config page =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , Attr.class (pageBtnClass (page == config.currentPage))
            , Events.onClick (config.onPageClick page)
            , Attr.attribute "aria-current"
                (if page == config.currentPage then
                    "page"

                 else
                    "false"
                )
            ]
            [ Html.text (String.fromInt page) ]
        ]


pageBtnClass : Bool -> String
pageBtnClass active =
    "w-9 h-9 flex items-center justify-center rounded-md text-sm font-medium transition-colors cursor-pointer "
        ++ (if active then
                "bg-brand text-white"

            else
                "text-gray-700 hover:bg-gray-100"
           )


navBtnClass : Bool -> String
navBtnClass disabled =
    "w-9 h-9 flex items-center justify-center rounded-md text-sm transition-colors "
        ++ (if disabled then
                "text-gray-300 cursor-not-allowed"

            else
                "text-gray-700 hover:bg-gray-100 cursor-pointer"
           )
