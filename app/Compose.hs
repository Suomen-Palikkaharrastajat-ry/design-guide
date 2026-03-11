-- | blay-compose: generate derived .blay files from the four master layouts.
--
-- Reads layout/first.blay through layout/fourth.blay (all using yellow #F2CD37
-- as a face-colour placeholder) and writes:
--
--   * Square skin-tone blays — configured in layout/skins.conf:
--       default: square.blay, square-light-nougat.blay, square-nougat.blay,
--                square-dark-nougat.blay
--
--   * Horizontal rainbow blays — four masters composed side-by-side, each
--     recoloured with a different colour from a sliding window of 4:
--       horizontal-rainbow.blay, horizontal-rainbow-rot1.blay … rot6.blay
--
-- skins.conf format (one line per master, first … fourth):
--
--   output-stem  RRGGBB
--
-- Lines starting with # and blank lines are ignored.
-- Missing or unreadable skins.conf falls back to built-in nougat defaults.
--
-- Run blay-compose locally whenever master blays or skins.conf change;
-- commit all outputs so CI only needs logo-gen.
module Main where

import Data.Char (isHexDigit, digitToInt)
import Data.Word (Word8)
import Logo.BrickLayout
    ( BrickLayout (..)
    , RGB
    , readBrickLayout
    , writeBrickLayout
    , recolorLayout
    , composeLayouts
    )
import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStrLn, stderr)
import System.IO.Error (isDoesNotExistError)
import Control.Exception (catch, IOException)

-- | Face-colour placeholder used in all master .blay files (#F2CD37 yellow).
yellowFace :: RGB
yellowFace = (0xF2, 0xCD, 0x37)

-- | Default skin-tone configuration (nougat palette), used when skins.conf
-- is absent.  Order matches first.blay … fourth.blay.
defaultSkins :: [(String, RGB)]
defaultSkins =
    [ ("square",              (0xF2, 0xCD, 0x37))  -- Yellow       #F2CD37
    , ("square-light-nougat", (0xF6, 0xD7, 0xB3))  -- Light Nougat #F6D7B3
    , ("square-nougat",       (0xD0, 0x91, 0x68))  -- Nougat       #D09168
    , ("square-dark-nougat",  (0xAD, 0x61, 0x40))  -- Dark Nougat  #AD6140
    ]

-- | All 7 rainbow colours in order (sliding windows of 4 per frame).
rainbowColors :: [RGB]
rainbowColors =
    [ (0xF2, 0x70, 0x5E)  -- Salmon            #F2705E
    , (0xF9, 0xBA, 0x61)  -- Light Orange      #F9BA61
    , (0xF2, 0xCD, 0x37)  -- Yellow            #F2CD37
    , (0x73, 0xDC, 0xA1)  -- Medium Green      #73DCA1
    , (0x9F, 0xC3, 0xE9)  -- Bright Light Blue #9FC3E9
    , (0x91, 0x95, 0xCA)  -- Light Lilac       #9195CA
    , (0xAC, 0x78, 0xBA)  -- Medium Lavender   #AC78BA
    ]

main :: IO ()
main = do
    args <- getArgs
    case args of
        ["--help"] -> putStr composeUsage >> exitSuccess
        ["-h"]     -> putStr composeUsage >> exitSuccess
        _          -> case parseComposeArgs args defaultComposeArgs of
            Left err -> hPutStrLn stderr ("blay-compose: " ++ err) >> exitFailure
            Right ca -> runCompose ca

data ComposeArgs = ComposeArgs
    { caLayoutDir :: FilePath
    , caHzPadTop  :: Int
    , caGapStuds  :: Int
    }

defaultComposeArgs :: ComposeArgs
defaultComposeArgs = ComposeArgs
    { caLayoutDir = "layout"
    , caHzPadTop  = 20
    , caGapStuds  = 2
    }

runCompose :: ComposeArgs -> IO ()
runCompose ca = do
    let lDir     = caLayoutDir ca
        confPath = lDir ++ "/skins.conf"

    -- Load skin configuration (skins.conf or built-in defaults).
    skins <- loadSkinConf confPath

    when (length skins /= 4) $ do
        hPutStrLn stderr $ "blay-compose: skins.conf must have exactly 4 entries, got "
                        ++ show (length skins)
        exitFailure

    -- Load all 4 master blays (first … fourth).
    masters <- mapM (\n -> readBrickLayout (lDir ++ "/" ++ n ++ ".blay"))
                    ["first", "second", "third", "fourth"]

    -- 1. Square skin-tone blays: each master recoloured per skins config.
    mapM_ (\(master, (name, toneRgb)) ->
                writeBrickLayout (lDir ++ "/" ++ name ++ ".blay")
                                 (recolorLayout yellowFace toneRgb master))
          (zip masters skins)

    -- 2. Horizontal rainbow blays: 7 sliding windows of 4 colours.
    --    Each window position maps to one master (first→pos0, second→pos1, …).
    let nRb     = length rainbowColors
        windows = [ take 4 (drop i (cycle rainbowColors)) | i <- [0 .. nRb - 1] ]
        rbNames = "horizontal-rainbow"
                : [ "horizontal-rainbow-rot" ++ show i | i <- [1 .. nRb - 1 :: Int] ]
    mapM_ (writeRainbow lDir masters (caHzPadTop ca) (caGapStuds ca))
          (zip rbNames windows)

    putStrLn "blay-compose: done."

-- | Load skin configuration from file, falling back to defaults on any error.
loadSkinConf :: FilePath -> IO [(String, RGB)]
loadSkinConf path = do
    result <- (Just <$> readFile path) `catch` handler
    case result of
        Nothing      -> do
            putStrLn $ "  skins.conf not found at " ++ path ++ "; using defaults"
            return defaultSkins
        Just content ->
            case parseSkinConf content of
                Left err    -> do
                    hPutStrLn stderr $ "blay-compose: " ++ path ++ ": " ++ err
                    hPutStrLn stderr   "  falling back to default skin configuration"
                    return defaultSkins
                Right skins -> do
                    putStrLn $ "  loaded " ++ show (length skins)
                             ++ " skin(s) from " ++ path
                    return skins
  where
    handler :: IOException -> IO (Maybe String)
    handler e
        | isDoesNotExistError e = return Nothing
        | otherwise             = return Nothing

-- | Parse skins.conf content.
-- Each non-comment, non-blank line: "output-stem  RRGGBB"
parseSkinConf :: String -> Either String [(String, RGB)]
parseSkinConf content =
    let ls = filter isData (lines content)
    in mapM parseLine ls
  where
    isData l =
        let s = dropWhile (== ' ') l
        in not (null s) && head s /= '#'

    parseLine l = case words l of
        [stem, hex] ->
            case parseHex6 hex of
                Just rgb -> Right (stem, rgb)
                Nothing  -> Left $ "bad hex colour: " ++ hex
        _ -> Left $ "expected 'stem RRGGBB', got: " ++ l

-- | Parse a 6-digit hex string (no #) to an RGB triple.
parseHex6 :: String -> Maybe RGB
parseHex6 h
    | length h == 6 && all isHexDigit h =
        let hv a b = fromIntegral (digitToInt a * 16 + digitToInt b) :: Word8
        in Just (hv (h !! 0) (h !! 1), hv (h !! 2) (h !! 3), hv (h !! 4) (h !! 5))
    | otherwise = Nothing

writeRainbow :: FilePath -> [BrickLayout] -> Int -> Int -> (String, [RGB]) -> IO ()
writeRainbow lDir masters hzPadTop gapStuds (name, window) = do
    let recolored = zipWith (recolorLayout yellowFace) window masters
        composed  = composeLayouts gapStuds recolored
        final     = composed { blPadTop = hzPadTop, blPadBottom = 0 }
    writeBrickLayout (lDir ++ "/" ++ name ++ ".blay") final

when :: Bool -> IO () -> IO ()
when True  action = action
when False _      = return ()

parseComposeArgs :: [String] -> ComposeArgs -> Either String ComposeArgs
parseComposeArgs [] ca = Right ca
parseComposeArgs [f] _  = Left $ "missing value for flag: " ++ f
parseComposeArgs (f : v : rest) ca = case f of
    "--layout-dir" -> parseComposeArgs rest ca { caLayoutDir = v }
    "--hz-pad-top" -> readInt f v >>= \n -> parseComposeArgs rest ca { caHzPadTop = n }
    "--gap-studs"  -> readInt f v >>= \n -> parseComposeArgs rest ca { caGapStuds = n }
    _              -> Left $ "unknown flag: " ++ f

readInt :: String -> String -> Either String Int
readInt flag s = case reads s of
    [(n, "")] -> Right n
    _         -> Left $ "expected integer for " ++ flag ++ ", got: " ++ s

composeUsage :: String
composeUsage = unlines
    [ "Usage: blay-compose [OPTIONS]"
    , ""
    , "Generate derived .blay files from 4 master layouts (first/second/third/fourth.blay)."
    , "Masters must use yellow (#F2CD37) as the face-colour placeholder."
    , "Run locally before committing so CI only needs logo-gen."
    , ""
    , "Skin configuration: layout/skins.conf (falls back to nougat defaults if absent)."
    , "Format — one line per master (first … fourth): output-stem  RRGGBB"
    , ""
    , "Options:"
    , "  --layout-dir PATH   Directory with master .blay files  [default: layout]"
    , "  --hz-pad-top N      Top padding for horizontal blays   [default: 20]"
    , "  --gap-studs N       Gap between logos in horizontal    [default: 2]"
    ]
