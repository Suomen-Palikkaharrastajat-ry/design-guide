{-# LANGUAGE OverloadedStrings #-}

module DesignTokensGen.ElmGenSpec (tests) where

import Data.Text (Text)
import Data.Text qualified as T
import DesignTokensGen.ElmGen (generateElmPackage)
import DesignTokensGen.Toml (parseContentDir)
import DesignTokensGen.Types
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests =
    testGroup
        "Guide.ElmGen"
        [ testCase "generates correct number of files" $ do
            dg <- parseContentDir "content"
            length (generateElmPackage dg) @?= 10
        , testCase "root module contains version" $ do
            dg <- parseContentDir "content"
            let files = generateElmPackage dg
                root = maybe "" snd $ lookup' "src/DesignTokens.elm" files
            assertBool "has version" $
                "version" `T.isInfixOf` root
        , testCase "colors module contains legoBlack" $ do
            dg <- parseContentDir "content"
            let files = generateElmPackage dg
                colors = maybe "" snd $ lookup' "src/DesignTokens/Colors.elm" files
            assertBool "has legoBlack" $
                "legoBlack" `T.isInfixOf` colors
        , testCase "skinTones has 4 entries" $ do
            dg <- parseContentDir "content"
            length (dgSkinTones dg) @?= 4
        , testCase "rainbowColors has 7 entries" $ do
            dg <- parseContentDir "content"
            length (dgRainbowColors dg) @?= 7
        , testCase "escapeElmString handles quotes" $
            renderString "say \"hi\"" @?= "\"say \\\"hi\\\"\""
        , testCase "escapeElmString handles backslash" $
            renderString "a\\b" @?= "\"a\\\\b\""
        ]

lookup' :: FilePath -> [(FilePath, Text)] -> Maybe (FilePath, Text)
lookup' _ [] = Nothing
lookup' k ((p, v) : xs)
    | k == p = Just (p, v)
    | otherwise = lookup' k xs

-- | Mirror of Guide.ElmGen internals for testing the escape logic.
escapeElmString :: Text -> Text
escapeElmString = T.concatMap escapeChar
  where
    escapeChar '\\' = "\\\\"
    escapeChar '"' = "\\\""
    escapeChar '\n' = "\\n"
    escapeChar c = T.singleton c

renderString :: Text -> Text
renderString t = "\"" <> escapeElmString t <> "\""
