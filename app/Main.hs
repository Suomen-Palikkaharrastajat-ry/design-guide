module Main where

import Brand.Colors (darkBg)
import Brand.ElmGen (generateBrandModule)
import Brand.Json (generateDesignGuide)
import Brand.JsonLd (generateJsonLd)
import Control.Monad (forM_)
import Logo.Animate (assembleGif, assembleWebp)
import Logo.BrickLayout
    ( BrickLayout (..)
    , layoutToSvg
    , layoutsToHorizontalSvg
    , readBrickLayout
    )
import Logo.Compose (composeLogo)
import Logo.Config (Config (..), parseConfig)
import Logo.Favicons (generateFavicons)
import Logo.Raster (exportPng, exportWebp)
import System.Directory (createDirectoryIfMissing)
import System.FilePath (takeDirectory)
import qualified Data.Text.IO as TIO

main :: IO ()
main = do
    cfg <- parseConfig

    let sqSvg = cfgSqSvgDir cfg
        hzSvg = cfgHzSvgDir cfg
        sqPng = cfgSqPngDir cfg
        hzPng = cfgHzPngDir cfg

    mapM_ (createDirectoryIfMissing True)
          [sqSvg, hzSvg, sqPng, hzPng]

    runRender cfg

    putStrLn "Done."

-- | Read all committed .blay files and produce SVG, PNG, WebP, GIF, favicons,
-- and design-guide outputs.
runRender :: Config -> IO ()
runRender cfg = do
    let sqSvg = cfgSqSvgDir cfg
        hzSvg = cfgHzSvgDir cfg
        sqPng = cfgSqPngDir cfg
        hzPng = cfgHzPngDir cfg

    -- Square SVGs from the four skin-tone blays.
    putStrLn "==> logos (square SVGs from .blay)"
    forM_ squareSkinTones $ \stem -> do
        bl <- readBlayFile cfg stem
        writeSvg (sqSvg ++ "/" ++ stem ++ ".svg") (layoutToSvg bl)

    -- Horizontal skin-tone SVGs: compose 4 square layouts side by side.
    putStrLn "==> logos (horizontal skin-tone SVGs)"
    let mkHz stems = do
            ls <- mapM (readBlayFile cfg) stems
            return $ layoutsToHorizontalSvg gapBricks (map (withHzPad cfg) ls)
    hzSvg0 <- mkHz squareSkinTones
    writeSvg (hzSvg ++ "/horizontal.svg") hzSvg0
    forM_ (zip [1 :: Int ..] horizontalSkinToneRots) $ \(i, stems) -> do
        svg <- mkHz stems
        writeSvg (hzSvg ++ "/horizontal-rot" ++ show i ++ ".svg") svg

    -- Horizontal rainbow SVGs from committed rainbow .blay files.
    putStrLn "==> logos (rainbow horizontal SVGs from .blay)"
    forM_ rainbowHzVariants $ \stem -> do
        bl <- readBlayFile cfg stem
        writeSvg (hzSvg ++ "/" ++ stem ++ ".svg") (layoutToSvg bl)

    -- Compose: add subtitle text.
    putStrLn "==> compose (add subtitle)"
    forM_ allHorizontalVariants $ \stem -> do
        composeLogo (cfgFontPath cfg)
            (hzSvg ++ "/" ++ stem ++ ".svg")
            (hzSvg ++ "/" ++ stem ++ "-full.svg")
            (cfgTxtSize cfg) Nothing
        composeLogo (cfgFontPath cfg)
            (hzSvg ++ "/" ++ stem ++ ".svg")
            (hzSvg ++ "/" ++ stem ++ "-full-dark.svg")
            (cfgTxtSize cfg) (Just darkBg)

    -- Raster: SVG → PNG + WebP.
    putStrLn "==> raster (PNG + WebP)"
    let rasterTargets =
            [(sqSvg, sqPng, s) | s <- squareSkinTones]
                ++ [(hzSvg, hzPng, s) | s <- allHorizontalVariants]
                ++ [(hzSvg, hzPng, s ++ "-full") | s <- allHorizontalVariants]
                ++ [(hzSvg, hzPng, s ++ "-full-dark") | s <- allHorizontalVariants]
    forM_ rasterTargets $ \(svgDir, pngDir, stem) -> do
        exportPng  (svgDir ++ "/" ++ stem ++ ".svg")
                   (pngDir ++ "/" ++ stem ++ ".png")  (cfgRasterW cfg)
        exportWebp (svgDir ++ "/" ++ stem ++ ".svg")
                   (pngDir ++ "/" ++ stem ++ ".webp") (cfgRasterW cfg)

    -- Animate: PNG frames → GIF + WebP.
    putStrLn "==> animate (GIF + WebP)"
    let mkFrames dir stems ext = map (\s -> dir ++ "/" ++ s ++ ext) stems
        ms = cfgAnimMs cfg

    assembleGif  (mkFrames sqPng squareSkinTones ".png")  (sqPng ++ "/square-animated.gif")  ms
    assembleWebp (mkFrames sqPng squareSkinTones ".png")  (sqPng ++ "/square-animated.webp") ms

    assembleGif  (mkFrames hzPng horizontalSkinTones ".png")  (hzPng ++ "/horizontal-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones ".png")  (hzPng ++ "/horizontal-animated.webp") ms

    assembleGif  (mkFrames hzPng horizontalSkinTones "-full.png")
                 (hzPng ++ "/horizontal-full-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones "-full.png")
                 (hzPng ++ "/horizontal-full-animated.webp") ms

    assembleGif  (mkFrames hzPng horizontalSkinTones "-full-dark.png")
                 (hzPng ++ "/horizontal-full-dark-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones "-full-dark.png")
                 (hzPng ++ "/horizontal-full-dark-animated.webp") ms

    assembleGif  (mkFrames hzPng rainbowHzVariants ".png")
                 (hzPng ++ "/horizontal-rainbow-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants ".png")
                 (hzPng ++ "/horizontal-rainbow-animated.webp") ms

    assembleGif  (mkFrames hzPng rainbowHzVariants "-full.png")
                 (hzPng ++ "/horizontal-rainbow-full-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants "-full.png")
                 (hzPng ++ "/horizontal-rainbow-full-animated.webp") ms

    assembleGif  (mkFrames hzPng rainbowHzVariants "-full-dark.png")
                 (hzPng ++ "/horizontal-rainbow-full-dark-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants "-full-dark.png")
                 (hzPng ++ "/horizontal-rainbow-full-dark-animated.webp") ms

    -- Favicons.
    putStrLn "==> favicons"
    generateFavicons (sqSvg ++ "/square.svg") (cfgFaviconDir cfg)

    -- Design guide JSON + JSON-LD.
    putStrLn "==> design-guide.json"
    generateDesignGuide
    putStrLn "==> design-guide/*.jsonld"
    generateJsonLd

    -- Elm codegen.
    putStrLn "==> elm codegen (Brand.Tokens)"
    let elmBrandSrc = "src/Brand"
    createDirectoryIfMissing True elmBrandSrc
    TIO.writeFile (elmBrandSrc <> "/Tokens.elm") generateBrandModule
    putStrLn "Wrote src/Brand/Tokens.elm"

-- ── Helpers ───────────────────────────────────────────────────────────────────

writeSvg :: FilePath -> String -> IO ()
writeSvg path svg = do
    createDirectoryIfMissing True (takeDirectory path)
    writeFile path svg
    putStrLn $ "  Saved " ++ path

readBlayFile :: Config -> String -> IO BrickLayout
readBlayFile cfg stem =
    readBrickLayout (cfgLayoutDir cfg ++ "/" ++ stem ++ ".blay")

withHzPad :: Config -> BrickLayout -> BrickLayout
withHzPad cfg bl = bl { blPadTop = cfgHzPadTop cfg, blPadBottom = 0 }

gapBricks :: Int
gapBricks = 2

-- ── File lists ────────────────────────────────────────────────────────────────

squareSkinTones :: [String]
squareSkinTones = ["square", "square-light-nougat", "square-nougat", "square-dark-nougat"]

horizontalSkinToneRots :: [[String]]
horizontalSkinToneRots =
    [ drop i squareSkinTones ++ take i squareSkinTones | i <- [1, 2, 3] ]

horizontalSkinTones :: [String]
horizontalSkinTones = ["horizontal", "horizontal-rot1", "horizontal-rot2", "horizontal-rot3"]

rainbowHzVariants :: [String]
rainbowHzVariants =
    "horizontal-rainbow"
        : ["horizontal-rainbow-rot" ++ show i | i <- [1 .. 6 :: Int]]

allHorizontalVariants :: [String]
allHorizontalVariants = horizontalSkinTones ++ rainbowHzVariants
