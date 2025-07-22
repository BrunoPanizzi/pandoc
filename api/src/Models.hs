{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Models where

import Data.Aeson
import GHC.Generics (Generic)
import Database.PostgreSQL.Simple (FromRow)
import Database.PostgreSQL.Simple.FromField (FromField(..), fromField)
import Data.Text (Text)
import Data.Text.Encoding as TE
import qualified Data.Text as Text  -- Import Data.Text qualified
import Data.ByteString
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import Crypto.BCrypt

data User = User
    { userId        :: Text
    , userName      :: Text
    , userEmail     :: Text
    , userPassword  :: ByteString
    } deriving (Show, Generic)

instance ToJSON User where
  toJSON user = object
    [ "id"    .= userId user
    , "name"  .= userName user
    , "email" .= userEmail user
    -- Don't include password hash in JSON output
    ]

instance FromRow User

-- The data needed to create a new user
data UserRegistration = UserRegistration
    { registrationName     :: Text
    , registrationEmail    :: Text
    , registrationPassword :: Text
    } deriving (Show, Generic)

instance FromJSON UserRegistration where
    parseJSON = withObject "UserRegistration" $ \v -> UserRegistration
        <$> v .: "name"
        <*> v .: "email"
        <*> v .: "password"

-- A function to create a User from UserRegistration (to be used in your service layer)
createUser :: UserRegistration -> IO (Maybe User)
createUser reg = do
    uuid <- genUserId
    hashedPwd <- hashUserPassword (TE.encodeUtf8 $ registrationPassword reg)
    return $ case hashedPwd of
      Just hash -> Just User
          { userId = uuid
          , userName = registrationName reg
          , userEmail = registrationEmail reg
          , userPassword = hash
          }
      Nothing -> Nothing
  where
    genUserId = Text.pack . show <$> nextRandom
    hashUserPassword :: ByteString -> IO (Maybe ByteString)
    hashUserPassword pass = do
      hash <- hashPasswordUsingPolicy fastBcryptHashingPolicy pass
      return hash