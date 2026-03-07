module Logo.Raster (exportPng, exportWebp) where

import System.Directory (removeFile)
import System.Process (callProcess)

-- | Export SVG to PNG at given width using cairosvg (handles embedded fonts).
exportPng :: FilePath -> FilePath -> Int -> IO ()
exportPng svgIn pngOut widthPx = do
    putStrLn $ "  raster " ++ svgIn ++ " -> " ++ pngOut
    callProcess "python3" ["scripts/svg_to_png.py", svgIn, pngOut, show widthPx]

-- | Export SVG to WebP at given width (via intermediate PNG and cwebp).
exportWebp :: FilePath -> FilePath -> Int -> IO ()
exportWebp svgIn webpOut widthPx = do
    putStrLn $ "  raster " ++ svgIn ++ " -> " ++ webpOut
    let tmpPng = webpOut ++ ".tmp.png"
    exportPng svgIn tmpPng widthPx
    callProcess "cwebp" ["-q", "90", tmpPng, "-o", webpOut]
    removeFile tmpPng
