module Hack.AdminPage where

import Debug
import Html
import Html (..)
import Html.Events (..)
import Html.Optimize.RefEq as Ref
import Graphics.Input (..)
import Graphics.Input as Input

import Hack.Model (..)

actions : Input Action
actions = Input.input NoOp

draw : [Device] -> Html
draw devices = 
  node "ul"
    [ "id" := "device-list" ]
    ["list-style-type" := "none"]
    (map drawDevice devices)

drawDevice : Device -> Html
drawDevice device = 
  node "li"
    []
    []
    [ text <| (device.ip ++ ":" ++ device.forwardedPort)
    , eventNode "input"
        [ "id"          := "port"
        , "value"       := device.forwardedPort
        , "placeholder" := "Forwarding Port"
        , "name"        := "newTodo"
        ]
        []
        [ on "input" getValue actions.handle (UpdatePort device.ip) ]
        [] 
    , eventNode "button"
        [] 
        []
        [ onclick actions.handle (always (TelnetDevice device)) ]
        [ text "Telnet" ]
    ]

drawConsole : Device -> Html
drawConsole device =
  node "textarea"
   []
   []
   [ text (device.ip ++ ">")]
