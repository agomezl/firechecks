{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty
import Network.HTTP.Types.Status (badRequest400)
import Control.Monad.Trans (liftIO)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import qualified Data.ByteString.Lazy.Char8 as BS
import Network.AMQP
import System.IO.Error    (isDoesNotExistError,catchIOError,ioError)
import System.Environment (lookupEnv)


main :: IO ()
main = do
  -- Gets configurations from the environment
  -- TODO: Check formating of courses (remove white-spaces,etc)
  course <- maybe "testLab" id   <$> (lookupEnv "COURSE_NAME")
  -- TODO: Check this is a number
  labsN  <- maybe "1" id         <$> (lookupEnv "LAB_NUMBER")
  mqHost <- maybe "localhost" id <$> (lookupEnv "MQ_HOST")
  -- Create a list of lab names as <course>-<n> with n < labN
  let labs = [course ++ "-lab" ++ show n | n <- [1..(read labsN)]]
  -- Print server configuration
  putStrLn $ "Starting submissionserver for course: " ++ course
  putStrLn $ "with MQ server at: " ++ mqHost
  putStrLn "for labs:"
  mapM_ (\n -> putStrLn $ "  " ++ n) labs
  conn <- openConnection mqHost "/" "guest" "guest"
  chan <- openChannel conn
  mapM_ (\lab -> declareQueue chan newQueue {queueName       = T.pack lab,
                                             queueAutoDelete = False,
                                             queueDurable    = False})
        labs
  scotty 3000 $ do
         get "/:course/:labnum" $ do
                  _course <- param "course"
                  _lab    <- param "labnum"
                  let labN = course ++ "-lab" ++ _lab
                  if _course == course && elem labN labs
                  then do
                    cb   <- param "cb"
                    fl   <- param "zip"
                    liftIO $ do
                          BS.putStrLn $ BS.concat
                            ["[*] Got request for lab=", BS.pack _lab
                            ," to check file at url=", fl
                            ," and write response to url=",cb
                            ]
                          putMsg chan (T.pack _course) (BS.concat [fl,"|",cb])
                  else do
                    liftIO $ putStrLn $
                               "[*] bad request: " ++ _course ++ "/" ++ _lab
                    status badRequest400
                  text ""

putMsg ch queue msg = publishMsg ch "" queue _msg
    where _msg = newMsg {msgBody         = msg,
                         msgDeliveryMode = Just NonPersistent}
