module Main where

import DesignTokensGen.ElmGenSpec qualified as ElmGen
import DesignTokensGen.JsonSpec qualified as Json
import Test.Tasty

main :: IO ()
main =
    defaultMain $
        testGroup
            "design-tokens-gen"
            [ ElmGen.tests
            , Json.tests
            ]
