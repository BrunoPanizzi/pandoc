{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Text.Pandoc.Server (API, server)
import Data.Text
import Servant.API
import Network.Wai.Handler.Warp
import Servant

type MyAPI =
    API
    :<|> "hello" :> Get '[PlainText] Text


myApi :: Proxy MyAPI
myApi = Proxy

myServer :: Server MyAPI
myServer = server :<|> return "hellow"

main :: IO ()
main = do
    putStrLn "Starting the pandoc server..."
    run 8080 (serve myApi myServer)
