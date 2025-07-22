{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE TypeApplications #-}

module Main where

-- import Text.Pandoc.Server (API, server, corsWithContentType)
import Servant.API
import Network.Wai.Handler.Warp
import Servant

import Control.Monad.IO.Class (liftIO)
import Database.PostgreSQL.Simple

import Models

-- import Storage
-- import MemStorage

-- type MyAPI = "convert" :> API
type MyAPI = "users" :> Get '[JSON] [User]
        :<|> "users" :> ReqBody '[JSON] UserRegistration :> UVerb 'POST '[JSON] '[WithStatus 200 User, WithStatus 500 String]

myApi :: Proxy MyAPI
myApi = Proxy

myServer :: Connection -> Server MyAPI
myServer conn = (listUsers conn)
           :<|> (\u -> insertUser u conn)


listUsers :: Connection -> Handler [User]
listUsers conn = liftIO $ query_ conn "select * from users"

insertUser :: UserRegistration -> Connection -> Handler (Union '[WithStatus 200 User, WithStatus 500 String])
insertUser user conn = do 
    created <- liftIO $ createUser user

    case created of
        Just (User i n e p) -> do
            rows <- liftIO $ query conn "INSERT INTO users (id, name, email, hash) VALUES (?, ?, ?, ?) returning *" (i, n, e, p)

            case rows of
                [u] -> respond (WithStatus @200 (u :: User))
                _   -> respond (WithStatus @500 ("Something bad happened" :: String))
        Nothing -> respond (WithStatus @500 ("Something bad happened" :: String))


main :: IO ()
main = do
    conn <- connectPostgreSQL "postgresql://user:password@localhost:5432/conversor_db"

    
    -- users <- listUsers conn
    -- forM_ users print

    putStrLn "🚀🚀 Starting server on http://localhost:8080"

    run 8080 $ (serve myApi $ myServer conn)

{-     b <- seed
    putStrLn "Starting the pandoc server..."
    run 8080 $ corsWithContentType $ serve myApi myServer -}
