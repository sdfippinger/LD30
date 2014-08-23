module Hack.AdminPage where

import Debug
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Html.Tags (..)
import Html.Optimize.RefEq as Ref
import Graphics.Input
import Graphics.Input as Input

data Action
  = NoOp
  | Telnet Device
  | ForwardPort String String

type State =
  { devices : [Device]
  }

type Device =
  { ip : String
  , forwardedPort: String }

actions : Input.Input Action
actions = Input.input NoOp

initialize : State
initialize = 
  let devices = [ { ip = "192.168.0.50"
                  , forwardedPort = ""}
                , { ip = "192.168.0.24"
                  , forwardedPort = ""}
                ]
  in { devices = devices }
  
step : Action -> State -> State
step action state =
  case action of
    NoOp -> state
  
    Telnet device -> state
    
    ForwardPort ip forwardedPort -> 
      let update device = if device.ip == ip then { device | forwardedPort <- forwardedPort } else device
      in { state | devices <- map update state.devices }

view : State -> Html
view state = 
  ul
    [ id  "device-list"
    , style [ prop "list-style-type" "none" ]
    ]
    ( map drawDevice state.devices )

drawDevice : Device -> Html
drawDevice device = 
  li
    [ ]
    [ text <| (device.ip ++ ":" ++ device.forwardedPort)
    , input
        [ id          "port"
        , value       device.forwardedPort
        , placeholder "Forwarding Port"
        , name        "newTodo"
        , on "input" getValue actions.handle (ForwardPort device.ip)
        ]
        [ ] 
    , button
        [ onclick actions.handle (always (Telnet device)) ]
        [ text "Telnet" ]
    ]
