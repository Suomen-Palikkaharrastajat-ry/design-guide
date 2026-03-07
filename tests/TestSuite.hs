module Main where

import Test.Tasty
import qualified Brand.ColorsSpec as Colors
import qualified Brand.JsonSpec as Json
import qualified Logo.DesignsSpec as Designs
import qualified Logo.BlockifySpec as Blockify

main :: IO ()
main = defaultMain $ testGroup "logo-gen"
    [ Colors.tests
    , Json.tests
    , Designs.tests
    , Blockify.tests
    ]
