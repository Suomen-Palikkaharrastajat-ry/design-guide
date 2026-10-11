{- | Generate design token artifacts from content/ TOML files.

Outputs:
  - dist/design-tokens.tokens.json  (W3C DTCG 2025.10)
  - dist/design-tokens-elm/         (publishable Elm package)
  - dist/design-tokens.css          (Tailwind v4 @theme + @utility fragment)
-}
module Main where

import Data.ByteString.Lazy qualified as LBS
import Data.Text.IO qualified as TIO
import DesignTokensGen.CssGen (generateCss)
import DesignTokensGen.ElmGen (generateElmPackage)
import DesignTokensGen.Json (generateTokensJson)
import DesignTokensGen.Toml (parseContentDir)
import System.Directory (createDirectoryIfMissing)
import System.FilePath (takeDirectory)

main :: IO ()
main = do
    dg <- parseContentDir "content"

    -- W3C DTCG JSON
    let jsonPath = "dist/design-tokens.tokens.json"
    createDirectoryIfMissing True (takeDirectory jsonPath)
    LBS.writeFile jsonPath (generateTokensJson dg)
    putStrLn $ "Wrote " ++ jsonPath

    -- Tailwind v4 CSS
    let cssPath = "dist/design-tokens.css"
    createDirectoryIfMissing True (takeDirectory cssPath)
    TIO.writeFile cssPath (generateCss dg)
    putStrLn $ "Wrote " ++ cssPath

    -- Elm package
    let elmFiles = generateElmPackage dg
        elmBase = "dist/design-tokens-elm/"
    mapM_
        ( \(rel, content) -> do
            let full = elmBase ++ rel
            createDirectoryIfMissing True (takeDirectory full)
            TIO.writeFile full content
        )
        elmFiles
    putStrLn $
        "Wrote " ++ show (length elmFiles) ++ " files to " ++ elmBase
