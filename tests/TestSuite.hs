module Main where

import Test.Tasty
import qualified Brand.ColorsSpec as Colors
import qualified Brand.ElmGenSpec as ElmGen
import qualified Brand.JsonSpec as Json
import qualified Logo.BlockifySpec as Blockify

main :: IO ()
main = defaultMain $ testGroup "logo-gen"
    [ Colors.tests
    , ElmGen.tests
    , Json.tests
    , Blockify.tests
    ]
