{-# LANGUAGE OverloadedStrings #-}

module DesignTokensGen.CssGenSpec (tests) where

import Data.List (nub)
import Data.Text (Text)
import Data.Text qualified as T
import DesignTokensGen.CssGen (generateCss)
import DesignTokensGen.Toml (parseContentDir)
import DesignTokensGen.Types
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests =
    testGroup
        "Guide.CssGen"
        [ testCase "header contains generated comment and version" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
            assertBool "has header comment" ("/* Generated file, do not edit." `T.isInfixOf` css)
            assertBool "has version" (("Version: " <> metaVersion (dgMeta dg)) `T.isInfixOf` css)
        , testCase "contains expected --color-brand variable" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
            assertBool "contains --color-brand" ("--color-brand:" `T.isInfixOf` css)
            assertBool "contains #05131D" ("#05131D" `T.isInfixOf` css)
        , testCase "contains brand-green token" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
            assertBool "contains --color-brand-green" ("--color-brand-green:" `T.isInfixOf` css)
            assertBool "contains #237841" ("#237841" `T.isInfixOf` css)
        , testCase "contains font variables in @theme" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
            assertBool "contains --font-sans" ("--font-sans: \"Outfit\", system-ui, sans-serif;" `T.isInfixOf` css)
            assertBool "contains --font-mono" ("--font-mono: ui-monospace, monospace;" `T.isInfixOf` css)
        , testCase "contains expected @utility type-h1 block with correct declarations" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
                expectedH1 =
                    T.unlines
                        [ "@utility type-h1 {"
                        , "  font-size: 1.875rem;"
                        , "  font-weight: 700;"
                        , "  line-height: 1.2;"
                        , "  letter-spacing: -0.01em;"
                        , "}"
                        ]
            assertBool "contains type-h1 block" (expectedH1 `T.isInfixOf` css)
        , testCase "contains font-family in @utility type-mono" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
            assertBool "type-mono has font-family" ("font-family: ui-monospace, monospace;" `T.isInfixOf` css)
        , testCase "contains text-transform in @utility type-overline" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
            assertBool "type-overline has text-transform" ("text-transform: uppercase;" `T.isInfixOf` css)
        , testCase "no duplicate variable names in @theme block" $ do
            dg <- parseContentDir "content"
            let css = generateCss dg
                vars = extractThemeVars css
            assertBool "theme has variables" (not (null vars))
            vars @?= nub vars
        ]

-- | Extract all `--<name>:` CSS variable names from inside the `@theme` block.
extractThemeVars :: Text -> [Text]
extractThemeVars css =
    let themeContent = extractBetween "@theme {" "}" css
        ls = map T.strip (T.lines themeContent)
        varLines = filter (\l -> "--" `T.isPrefixOf` l && ":" `T.isInfixOf` l) ls
     in map (fst . T.breakOn ":") varLines

extractBetween :: Text -> Text -> Text -> Text
extractBetween start end txt =
    case T.breakOn start txt of
        (_, rest)
            | T.null rest -> ""
            | otherwise ->
                let afterStart = T.drop (T.length start) rest
                 in fst (T.breakOn end afterStart)
