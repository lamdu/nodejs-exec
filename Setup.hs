{-# LANGUAGE CPP #-}
{-# OPTIONS -Wall #-}
import Distribution.PackageDescription
import Distribution.Simple
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Setup
import Distribution.Simple.Utils
import Distribution.Verbosity
import System.Directory
import System.FilePath ((</>))

nodeRelPath :: FilePath
nodeRelPath = "bin/node.exe"

output :: Verbosity -> String -> IO ()
output verbosity msg
    | verbosity >= verbose = putStrLn msg
    | otherwise = pure ()

buildNode :: Verbosity -> IO ()
buildNode verbosity =
    do
        e <- doesFileExist nodeRelPath
        if e
            then output verbosity $ "Using node from " ++ show nodeRelPath
            else rawSystemExit verbosity "bash" ["build_node.sh"]

postInstNode :: Verbosity -> PackageDescription -> LocalBuildInfo -> IO ()
postInstNode verbosity pkgDesc localBuildInfo =
    do
        output verbosity $ "Setting file executable " ++ show path
        setFileExecutable path
    where
        path =
            datadir (absoluteInstallDirs pkgDesc localBuildInfo NoCopyDest) </> nodeRelPath

main :: IO ()
main =
    defaultMainWithHooks simpleUserHooks
    { postBuild =
      \args buildFlags pkgDesc localBuildInfo ->
      do
          postBuild simpleUserHooks args buildFlags pkgDesc localBuildInfo
          let verbosity = fromFlagOrDefault normal $ buildVerbosity buildFlags
          buildNode verbosity
    , postInst = wrapInst postInst installVerbosity
    , postCopy = wrapInst postCopy copyVerbosity
    }
    where
        wrapInst f getVerbosity args flags pkgDesc localBuildInfo =
            do
                () <- f simpleUserHooks args flags pkgDesc localBuildInfo
                let verbosity = fromFlagOrDefault normal $ getVerbosity flags
                postInstNode verbosity pkgDesc localBuildInfo
