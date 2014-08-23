module Hack.Browser (initialize, step, view) where
{-| A tabbed Browser emulator library implemented in Elm.

This is supposed to be nested to a bigger module, exporting `Action`
and `State` to be incorporate into parent's `Action` and `State`.

Also provides APIs for `initialize` (called in parent's initial state),
`step` (performed in parent's step function), and `view` (rendered in
parent's view function). This is to follow [1].

Also `Browser.Action` can also be extended to support arbitrary action
from the parent, following [2].

## References:
[1] https://gist.github.com/evancz/2b2ba366cae1887fe621#nesting
[2] https://gist.github.com/evancz/2b2ba366cae1887fe621#generalizing-actions
-}

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Html.Tags (..)
import Html.Optimize.RefEq as Ref
import Maybe
import Window

import Graphics.Input
import Graphics.Input as Input

--- API ---

initialize : State
initialize =
  { address = "about:blank"
  }

---- MODEL ----

-- The full application state of the browser.
type State =
  { address : String
  }

type Tab =
  { url     : String
  , name    : String
  , content : Html
  }

newTab: String -> Html -> Tab
newTab url content =
  { url = url
  , name = "Blank page"
  , content = content
  }

emptyState : State
emptyState =
  { address = "about:blank"
  }

---- UPDATE ----

data Action
  = NoOp
  | NewTab String Html
  | UpdateAddress String
  | CloseTab String
  | RefreshTab
  | Anything (State -> State) -- @see [2]

-- How we step the state forward for any given action
step : Action -> State -> State
step action state =
  case action of
    NoOp -> state

    NewTab url content ->
      state

    CloseTab url ->
      state

    RefreshTab -> state -- @TODO

    Anything action' -> action' state -- @see [2]


---- VIEW ----
view : State -> [Tab] -> Html
view state tabs =
  section
    -- attributes
    [ class "browselm" ]
    -- children
    [ Ref.lazy2 toolbar state.address tabs
    , Ref.lazy2 tabList state.address tabs
    ]

onEnter : Input.Handle a -> a -> Attribute
onEnter handle value =
  on "keydown" (when (\k -> k.keyCode == 13) getKeyboardEvent) handle (always value)

toolbar : String -> [Tab] -> Html
toolbar url tabs =
  let buttonStyles = [ prop "border" "none"
                     , prop "outline" "none"
                     , prop "background-color" "transparent"
                     , prop "float" "left"
                     ]
  in div
      -- attributes
      [ class "toolbar"
      , style [ prop "background-color" "#e7e7e4"
              , prop "padding" "0 0.5em"
              ]
      ]
      -- children
      [ button [ style buttonStyles ] [ text "<"]
      , button [ style buttonStyles ] [ text ">"]
      , button [ style buttonStyles ] [ text "^"]
      , button [ style buttonStyles ] [ text "@"]
      , label
          -- attributes
          [ for "address"
          , style [ prop "float" "left" ] 
          ]
          -- children
          [ text "Address" ]
      , span
          [ style [ prop "display" "block"
                  , prop "overflow" "hidden"
                  , prop "padding-right" "5px"
                  , prop "padding-left" "10px"
                  ]
          ]
          [ input
              -- attributes
              [ id "address" 
              , type' "url"
              , placeholder "http://www.example.com"
              , autofocus True
              , value url
              , name "address"
              , on "input" getValue actions.handle UpdateAddress
              , onEnter actions.handle RefreshTab
              , style [ prop "width" "100%"]
              ]
              -- children
              [ ]
          ]
      ]

tabList : String -> [Tab] -> Html
tabList current tabs =
  div
    [ id "tabs" ]
    (map tabContent (tabs |> withIndex))

withIndex : [a] -> [(Int, a)]
withIndex list = list |> zip [0..length list]

tabContent : (Int, Tab) -> Html
tabContent (idx, tab) = 
  div
    -- attributes
    [ class "tab" ]
    -- children
    [ input
        -- attributes
        [ type' "radio"
        , id ("tab-" ++ show idx)
        , checked True
        ]
        -- children
        [ ]
    , label
        -- attributes
        [ for ("tab-" ++ show idx) ]
        -- children
        [ text tab.name ]
    , div
        -- attributes
        [ class "content" ]
        -- children
        [ tab.content ]
    ] 

------ INPUTS ----

-- actions from user input
actions : Input.Input Action
actions = Input.input NoOp