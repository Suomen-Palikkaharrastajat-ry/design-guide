module Guide.Colors exposing (ColorEntry, RainbowColor, SkinToneEntry, brandColors, rainbowColors, skinTones)

{-| Color data for the Suomen Palikkaharrastajat ry design guide — brand palette, rainbow, and skin-tone entries.
-}


type alias ColorEntry =
    { hex : String
    , id : String
    , name : String
    , description : String
    , usage : List String
    }


type alias SkinToneEntry =
    { hex : String
    , id : String
    , name : String
    , description : String
    }


type alias RainbowColor =
    { hex : String
    , name : String
    , description : String
    }


brandColors : List ColorEntry
brandColors =
    [ { hex = "#FAC80A"
      , id = "lego-yellow"
      , name = "Yellow"
      , description = "Pääaksenttiväri painikkeisiin, korostuksiin ja CTA-elementteihin. Älä käytä tekstinä vaalealla taustalla — kontrasti ei riitä."
      , usage = [ "primary brand", "accent" ]
      }
    , { hex = "#05131D"
      , id = "lego-black"
      , name = "Black"
      , description = "Kaikki otsikot, leipäteksti ja navigaatio vaalealla taustalla. Käytä myös tummalle taustavärille."
      , usage = [ "features", "text", "dark background" ]
      }
    , { hex = "#FFFFFF"
      , id = "lego-white"
      , name = "White"
      , description = "Teksti ja kuvakkeet tummalla (Brand Black) taustalla. Sivun oletustaustaväri."
      , usage = [ "eye highlights", "text on dark background" ]
      }
    , { hex = "#C91A09"
      , id = "red"
      , name = "Red"
      , description = "Aksentti- ja varoitusväri. Ei koskaan pääväri — käytä korostuksiin, danger-tiloihin ja graafisiin elementteihin."
      , usage = [ "accent", "danger", "highlights" ]
      }
    ]


skinTones : List SkinToneEntry
skinTones =
    [ { hex = "#FAC80A", id = "yellow", name = "Yellow", description = "Classic minifig" }
    , { hex = "#F6D7B3", id = "light-nougat", name = "Light Nougat", description = "Light skin" }
    , { hex = "#D09168", id = "nougat", name = "Nougat", description = "Medium skin" }
    , { hex = "#AD6140", id = "dark-nougat", name = "Dark Nougat", description = "Dark skin" }
    ]


rainbowColors : List RainbowColor
rainbowColors =
    [ { hex = "#F2705E", name = "Salmon", description = "Red" }
    , { hex = "#F9BA61", name = "Light Orange", description = "Orange" }
    , { hex = "#FAC80A", name = "Yellow", description = "Yellow" }
    , { hex = "#73DCA1", name = "Medium Green", description = "Green" }
    , { hex = "#9FC3E9", name = "Bright Light Blue", description = "Blue" }
    , { hex = "#9195CA", name = "Light Lilac", description = "Indigo" }
    , { hex = "#AC78BA", name = "Medium Lavender", description = "Violet" }
    ]
