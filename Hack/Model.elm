module Hack.Model where

type State = 
  { devices : [Device]
  , selectedDevice : Device }

type Device =
  { ip : String
  , forwardedPort: String }

data Action
  = NoOp
  | UpdatePort String String
  | TelnetDevice Device