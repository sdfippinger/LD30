module Hack.Browser where
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

import Debug (log, watch)

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

emptyTab : Tab
emptyTab =
  { url = "about:blank"
  , name = "+"
  , content = div [ ] [ ]
  }

emptyState : State
emptyState =
  { address = "about:blank"
  }

---- UPDATE ----

data Action
  = NoOp
  | ChangeTab String
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

    ChangeTab url ->
      {state | address <- url}

    NewTab url content ->
      state

    UpdateAddress address ->
      {state | address <- address}

    CloseTab url ->
      state

    RefreshTab -> state -- @TODO

    Anything action' -> action' state -- @see [2]


---- VIEW ----
view : State -> [Tab] -> Html
view state tabs =
  section
    -- attributes
    [ class "browselm", style [  prop "border" "1px solid #ccc" ] ]
    -- children
    [ Ref.lazy2 tabsView state.address tabs
    ]

onEnter : Input.Handle a -> a -> Attribute
onEnter handle value =
  on "keydown" (when (\k -> k.keyCode == 13) getKeyboardEvent) handle (always value)

toolbar : String -> Html
toolbar url =
  div
    -- attributes
    [ class "toolbar", style [ ] ]
    -- children
    [ button [ style [ prop "float" "left" ] ] [ text "←"]
    , button [ style [ prop "float" "left" ] ] [ text "→"]
    , button [ style [ prop "float" "left" ] ] [ text "^"]
    , button 
        [ style [ prop "float" "left" ]
        , onclick actions.handle (always RefreshTab)
        ] 
        [ text "↻"]
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

tabsView : String -> [Tab] -> Html
tabsView current tabs =
  let tabs' = (tabs ++ [ emptyTab ]) |> withIndex
  in
    div
      [ id "tabs"
      , style [ 
              ]
      ]
      (  concatMap (tabList current) tabs'
      ++ [  div 
              [ class "contents" ]
              (map (tabContent current) tabs')
          ]
      )

withIndex : [a] -> [(Int, a)]
withIndex list = list |> zip [0..length list]

tabList : String -> (Int, Tab) -> [Html]
tabList current (idx, tab) =
  [ input
      -- attributes
      [ type' "radio"
      , id ("tab-" ++ show idx)
      , checked (if idx == 0 then True else False)
      , style [ prop "display" "none"] -- @TODO check current tab
      ]
      -- children
      [ ]
  , label
      -- attributes
      [ class "tab-label"
      , for ("tab-" ++ show idx)
      , style [ prop "display" "inline-block"
              , prop "padding" "0px 15px"
              , prop "border-left" "1px solid #ccc"
              , prop "border-right" "1px solid #ccc"
              ]
      , onclick actions.handle (always (ChangeTab tab.url))
      ]
      -- children
      [ text tab.name ]
  ]

tabContent : String -> (Int, Tab) -> Html
tabContent current (idx, tab) =
  div
    -- attributes
    [ class "content"
    , style [ prop "display" (if idx == 0 then "block" else "none")
            ] 
    ]
    -- children
    [ Ref.lazy toolbar tab.url
    , tab.content 
    ]
    --] 

------ INPUTS ----

-- actions from user input
actions : Input.Input Action
actions = Input.input NoOp