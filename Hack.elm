module Hack where

import Debug
import Window
import Html
import Html (..)
import Html.Events (..)
import Html.Optimize.RefEq as Ref
import Graphics.Input (..)
import Graphics.Input as Input

import Hack.AdminPage
import Hack.AdminPage (..)
import Hack.Model (..)


newState : State
newState = 
  { devices = [{ip="192.168.0.50",forwardedPort=""}, {ip="192.168.0.24",forwardedPort=""}] 
  , selectedDevice = {ip="",forwardedPort=""} }

step : Action -> State -> State
step action state =
    case action of
      NoOp ->
        state
      UpdatePort ip forwardedPort ->
        let update device = if device.ip == ip then { device | forwardedPort <- forwardedPort } else device
        in { state | devices <- map update state.devices }
      TelnetDevice device ->
        { state | selectedDevice <- device }

state : Signal State
state = foldp step newState actions.signal

main : Signal Element
main = lift2 display state Window.dimensions

display : State -> (Int,Int) -> Element
display state (w,h) = 
  Html.toElement 800 800 (view state)

view : State -> Html
view state = 
  node "div"
    [ "id" := "admin-console" ] []
    [ node "div"
        [ "id" := "devices" ]
        []
        [ Ref.lazy draw state.devices ]

    --, node "div"
    --    [ "id" := "console" ]
    --    []
    --    [ Ref.lazy drawConsole state.selectedDevice ]
    ]

