module System.NodeJS.Path
    ( path
    ) where

import Paths_nodejs_exec (getDataFileName)

path :: IO FilePath
path = getDataFileName "node/node"
