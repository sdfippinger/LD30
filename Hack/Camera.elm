module Hack.Camera where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Html.Tags (..)
import Html.Optimize.RefEq as Ref
import Maybe
import Window

import Graphics.Input
import Graphics.Input as Input

import Debug (log, watch)

-- API ---

initialize : State
initialize =
  { camera = "/img/warehouse-right.jpg"
  }

---- MODEL ----

-- The full application state of the browser.
type State =
  { camera : String
  }

---- UPDATE ----

data Action
  = NoOp
  | Start
  | Stop
  | Loop
  --| Anything (State -> State) -- @see [2]

step : Action -> State -> State
step action state =
  case action of
    NoOp -> state

    Start -> state

    Stop -> state

    Loop -> state

---- VIEW ----

view : State -> Html
view state =
  section
    [ class "camera"
    , id "camera-1"
    , style [ prop "position" "relative" ]
    ]
    [ img
        [ src state.camera
        , style [ prop "width" "100%" ]
        ]
        [ ]
    , div
        [ class "objects"
        , style [ prop "position" "absolute" 
                , prop "top" "0"
                ]
        ]
        [ ]
    ]