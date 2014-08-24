module Hack where

import Debug (log, watch)
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Html.Tags (..)
import Html.Optimize.RefEq as Ref

import Maybe
import Window

import Graphics.Input
import Graphics.Input as Input

import Hack.Model (..)
import Hack.AdminPage as AdminPage
import Hack.Browser as Browser

newGame : Game
newGame =
  let target = "105.12.31.232" -- @TODO: Randomize this.
  in  { state = Admin
      , target = target
      , browser = Browser.initialize
      , adminPage = AdminPage.initialize
      }

---- UPDATE ----

-- How we step the game forward for any given action
step : Action -> Game -> Game
step action game =
  case action of
    NoOp -> game

    Browser a -> { game | browser <- Browser.step a game.browser }
    
    AdminPage a -> {game | adminPage <- AdminPage.step a game.adminPage }

---- VIEW ----

view : Game -> Html
view game =
  div
    -- attributes
    [ id "hack-elm"]
    -- children
    [ Browser.view 
        game.browser
        [ { url = game.target ++ ":8080"
            , name = "Router"
            , content = AdminPage.view game.adminPage}
        ]
    ]

---- INPUTS ----

-- wire the entire game together
main : Signal Element
main = lift2 scene state Window.dimensions

scene : Game -> (Int,Int) -> Element
scene game (w,h) =
  container w h midTop (toElement w h (view game))

-- manage the state of our application over time
state : Signal Game
state = foldp step startingGame actions.signal

startingGame : Game
--startingGame = Maybe.maybe newGame identity getStorage
startingGame = newGame

-- actions from user input
actions : Input.Input Action
actions = Input.input NoOp

---- interactions with localStorage to save app state
--port getStorage : Maybe State

--port setStorage : Signal State
--port setStorage = state