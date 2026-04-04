{-# LANGUAGE OverloadedStrings #-}

module DesignTokensGen.JsonSpec (tests) where

import Data.Aeson (Value (..), decode)
import Data.Aeson.KeyMap qualified as KM
import Data.Text (isInfixOf)
import Data.Text.Lazy qualified as TL
import Data.Text.Lazy.Encoding qualified as TLE
import DesignTokensGen.Json (generateTokensJson)
import DesignTokensGen.Toml (parseContentDir)
import DesignTokensGen.Types (dgBrandColors, dgMeta, metaOrganization)
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests =
    testGroup
        "Guide.Json"
        [ testCase "organization matches expected value" $ do
            dg <- parseContentDir "content"
            metaOrganization (dgMeta dg) @?= "Suomen Palikkaharrastajat ry"
        , testCase "brand colors has 3 entries" $ do
            dg <- parseContentDir "content"
            length (dgBrandColors dg) @?= 3
        , testCase "JSON output is valid and has color group" $ do
            dg <- parseContentDir "content"
            let bs = generateTokensJson dg
            case decode bs :: Maybe Value of
                Nothing -> assertFailure "Generated JSON is not valid"
                Just (Object o) -> assertBool "has color key" $ KM.member "color" o
                Just _ -> assertFailure "Top-level JSON is not an object"
        , testCase "color tokens have $type" $ do
            dg <- parseContentDir "content"
            let bs = generateTokensJson dg
                txt = TL.toStrict (TLE.decodeUtf8 bs)
            assertBool "$type appears in output" $
                "\"$type\"" `isInfixOf` txt
        ]
