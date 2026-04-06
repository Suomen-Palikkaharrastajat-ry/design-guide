{-# LANGUAGE OverloadedStrings #-}

module DesignTokensGen.JsonSpec (tests) where

import Data.Aeson (Value (..), decode)
import Data.Aeson.Key (fromString)
import Data.Aeson.KeyMap qualified as KM
import Data.Text (isInfixOf)
import Data.Text.Lazy qualified as TL
import Data.Text.Lazy.Encoding qualified as TLE
import DesignTokensGen.Json (generateTokensJson)
import DesignTokensGen.Toml (parseContentDir)
import DesignTokensGen.Types (dgBrandColors, dgLogos, dgMeta, hexText, lgWebIcons, metaOrganization, metaThemeColor)
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests =
    testGroup
        "Guide.Json"
        [ testCase "organization matches expected value" $ do
            dg <- parseContentDir "content"
            metaOrganization (dgMeta dg) @?= "Suomen Palikkaharrastajat ry"
        , testCase "theme color matches expected value" $ do
            dg <- parseContentDir "content"
            hexText (metaThemeColor $ dgMeta dg) @?= "#05131D"
        , testCase "brand colors has 4 entries" $ do
            dg <- parseContentDir "content"
            length (dgBrandColors dg) @?= 4
        , testCase "web icons include installability set" $ do
            dg <- parseContentDir "content"
            length (lgWebIcons $ dgLogos dg) @?= 9
        , testCase "JSON output is valid and has color group" $ do
            dg <- parseContentDir "content"
            let bs = generateTokensJson dg
            case decode bs :: Maybe Value of
                Nothing -> assertFailure "Generated JSON is not valid"
                Just (Object o) -> assertBool "has color key" $ KM.member "color" o
                Just _ -> assertFailure "Top-level JSON is not an object"
        , testCase "JSON output includes metadata and asset groups" $ do
            dg <- parseContentDir "content"
            let bs = generateTokensJson dg
            case decode bs :: Maybe Value of
                Just (Object o) -> do
                    assertBool "has metadata key" $ KM.member "metadata" o
                    assertBool "has asset key" $ KM.member "asset" o
                _ -> assertFailure "Generated JSON is not an object"
        , testCase "JSON output includes OG social image token" $ do
            dg <- parseContentDir "content"
            let bs = generateTokensJson dg
            case decode bs :: Maybe Value of
                Just (Object o) ->
                    case KM.lookup (fromString "asset") o of
                        Just (Object assetO) ->
                            case KM.lookup (fromString "social-image") assetO of
                                Just (Object socialO) ->
                                    assertBool "has open-graph-default" $
                                        KM.member (fromString "open-graph-default") socialO
                                _ -> assertFailure "Missing social-image asset group"
                        _ -> assertFailure "Missing asset group"
                _ -> assertFailure "Generated JSON is not an object"
        , testCase "color tokens have $type" $ do
            dg <- parseContentDir "content"
            let bs = generateTokensJson dg
                txt = TL.toStrict (TLE.decodeUtf8 bs)
            assertBool "$type appears in output" $
                "\"$type\"" `isInfixOf` txt
        ]
