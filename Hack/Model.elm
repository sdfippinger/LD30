module Hack.Model where

import Hack.Browser as Browser
import Hack.AdminPage as AdminPage

data State = Email | Admin | Camera | Win | Lose
  
-- The full application state of our game.
type Game =
  { state   : State
  , target  : String
  , browser : Browser.State
  , adminPage: AdminPage.State
  }

data Action
  = NoOp
  | Browser Browser.Action
  | AdminPage AdminPage.Action