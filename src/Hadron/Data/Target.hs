{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Hadron.Data.Target(
    RequestTarget(..)
  , QueryString(..)
  , URIPath(..)

  , renderQueryString
  , renderRequestTarget
  , renderURIPath
  ) where

import           Control.DeepSeq.Generics (genericRnf)

import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS

import           GHC.Generics (Generic)

import           P

-- | A 'RequestTarget' is derived from but not always the same as the
-- URI the client is requesting.
--
-- The syntax/semantics of a 'RequestTarget' is specified in RFC
-- 7230 (section 5.3) with reference to RFC 3986. 'RequestTarget'
-- implements the subset of URI forms used in HTTP. 
--
-- FIXME: implement the others (asterisk, absolute, target).
data RequestTarget =
    AbsPathTarget !URIPath !QueryString
  deriving (Eq, Show, Generic)

instance NFData RequestTarget where rnf = genericRnf

renderRequestTarget :: RequestTarget -> ByteString
renderRequestTarget (AbsPathTarget p qs) = BS.concat [
    renderURIPath p
  , renderQueryString qs
  ]

-- | The part between the host part and the query string in a URL. We don't
-- care about manipulating 'URIPath's at all, so we don't need any more
-- structure than a ByteString newtype for validation.
newtype URIPath =
  URIPath {
    unURIPath :: ByteString
  } deriving (Eq, Show, Generic)

instance NFData URIPath where rnf = genericRnf

renderURIPath :: URIPath -> ByteString
renderURIPath = unURIPath

-- | The part after the '?', if there is a '?'.
data QueryString =
    NoQueryString
  | QueryStringPart !ByteString
  deriving (Eq, Show, Generic)

instance NFData QueryString where rnf = genericRnf

renderQueryString :: QueryString -> ByteString
renderQueryString NoQueryString = ""
renderQueryString (QueryStringPart qs) = "?" <> qs
