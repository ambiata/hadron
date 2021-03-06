{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
module Hadron.Core.Parser.Header(
    headerNameP
  , headerP
  , headerValueP
  ) where

import           Data.Attoparsec.ByteString (Parser, (<?>))
import qualified Data.Attoparsec.ByteString as AB
import qualified Data.List.NonEmpty as NE

import           Hadron.Core.Data.Header
import           Hadron.Core.Parser.Common

import           P

import           X.Data.Attoparsec.ByteString (sepByByte1)
import           X.Data.Attoparsec.ByteString.Ascii (isPrintable)

-- | header-field   = field-name ":" OWS field-value OWS
headerP :: Parser Header
headerP = do
  n <- headerNameP <?> "headerNameP"
  void $ AB.word8 0x3a -- colon
  vs <- fmap NE.fromList $ (sepByByte1 headerValueP 0x2c <?> "sepByByte1 headerValueP") -- 0x2c = comma
  pure $ Header n vs

headerNameP :: Parser HeaderName
headerNameP =
  HeaderName <$> AB.takeWhile isTokenWord

-- | We don't need to separate out multiple header values here, we can
-- do that on render if we need to.
headerValueP :: Parser HeaderValue
headerValueP =
  fmap HeaderValue $ AB.peekWord8 >>= \case
    Nothing -> pure "" -- empty header values are technically valid
    Just 0x0d -> pure "" -- end of the line, empty header
    Just w ->
      if isPrintable w
        then AB.takeWhile isHeaderWord
        else fail "invalid initial header value character"
  where
    isHeaderWord 0x09 = True -- tab
    isHeaderWord w = isPrintable w

