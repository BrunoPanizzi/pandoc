{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Text.Pandoc.Server (API, server, corsWithContentType)
import Servant.API
import Network.Wai.Handler.Warp
import Servant

type MyAPI = "convert" :> API

myApi :: Proxy MyAPI
myApi = Proxy

myServer :: Server MyAPI
myServer = server

main :: IO ()
main = do
    putStrLn "Starting the pandoc server..."
    run 8080 $ corsWithContentType $ serve myApi myServer
