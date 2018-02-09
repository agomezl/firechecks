{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty
import Control.Monad.Trans (liftIO)
import Data.Text as T
import Data.Text.IO as T
import Data.ByteString.Lazy.Char8 as BS
import Network.AMQP


main :: IO ()
main = do
  conn <- openConnection "localhost" "/" "guest" "guest"
  chan <- openChannel conn
  declareQueue chan newQueue {queueName       = "lab92",
                              queueAutoDelete = False,
                              queueDurable    = False}
  scotty 3000 $ do
         get "/lab92" $ do
                  cb   <- param "cb"
                  fl   <- param "zip"
                  liftIO $ do
                          BS.putStrLn $ BS.concat ["Request for lab92: ",cb," | ", fl]
                          putMsg chan "lab92" $ BS.concat [cb ," | ", fl]
                  text ""


putMsg ch queue msg = publishMsg ch "" queue _msg
    where
      _msg = newMsg {msgBody         = msg,
                     msgDeliveryMode = Just NonPersistent}
