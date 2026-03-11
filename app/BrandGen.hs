-- | brand-gen: generate project design-guide assets from Brand.* modules.
--
-- Writes design-guide.json, design-guide/*.jsonld, and optionally an Elm
-- Brand.Tokens module.  No .blay files are read; this step is independent of
-- the blay render pipeline.
--
-- == Usage
--
-- @
-- brand-gen [--elm-tokens-out FILE]
-- @
module Main where

import Brand.ElmGen (generateBrandModule)
import Brand.Json (generateDesignGuide)
import Brand.JsonLd (generateJsonLd)
import qualified Data.Text.IO as TIO
import System.Directory (createDirectoryIfMissing)
import System.Environment (getArgs)
import System.Exit (exitSuccess)
import System.FilePath (takeDirectory)

newtype BrandArgs = BrandArgs
    { baElmTokensOut :: FilePath
    }

defaultBrandArgs :: BrandArgs
defaultBrandArgs = BrandArgs
    { baElmTokensOut = "src/Brand/Tokens.elm"
    }

main :: IO ()
main = do
    args <- getArgs
    case args of
        ("--help" : _) -> putStr usageText >> exitSuccess
        ("-h"     : _) -> putStr usageText >> exitSuccess
        _ -> case parseArgs args defaultBrandArgs of
                Left err -> putStrLn ("brand-gen: " ++ err)
                Right ba -> runBrandGen ba

runBrandGen :: BrandArgs -> IO ()
runBrandGen ba = do
    putStrLn "==> design-guide.json"
    generateDesignGuide
    putStrLn "==> design-guide/*.jsonld"
    generateJsonLd
    putStrLn $ "==> " ++ baElmTokensOut ba
    let elmOut = baElmTokensOut ba
    createDirectoryIfMissing True (takeDirectory elmOut)
    TIO.writeFile elmOut generateBrandModule
    putStrLn $ "Wrote " ++ elmOut
    putStrLn "brand-gen: done."

parseArgs :: [String] -> BrandArgs -> Either String BrandArgs
parseArgs []           ba = Right ba
parseArgs [f]          _  = Left $ "missing value for flag: " ++ f
parseArgs (f : v : rest) ba = case f of
    "--elm-tokens-out" -> parseArgs rest ba { baElmTokensOut = v }
    _                  -> Left $ "unknown flag: " ++ f

usageText :: String
usageText = unlines
    [ "Usage: brand-gen [--elm-tokens-out FILE]"
    , ""
    , "Generate project design-guide assets from Brand.* modules."
    , ""
    , "Options:"
    , "  --elm-tokens-out FILE   Elm tokens output path"
    , "                          [default: src/Brand/Tokens.elm]"
    ]
