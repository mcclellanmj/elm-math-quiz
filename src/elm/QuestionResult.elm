module QuestionResult exposing (Model, Msg (..), view, update, init)

import Html exposing ( Html, div, text )

import GlobalTypes exposing ( UserResult )

type InternalMsgs =
  RandomGif String

type ExternalMsgs =
  NextQuestion

type Msg
  = Internal InternalMsgs
  | External ExternalMsgs

type State
  = Initializing
  | ShowImage String

type alias Model = 
  { result: UserResult
  , state: State
  }

init : UserResult -> ( Model, Cmd Msg )
init userResult = 
  let
    initModel = 
      { result = userResult
      , state = Initializing
      }
  in
    ( initModel, Cmd.none )

update : InternalMsgs -> Model -> ( Model, Cmd Msg )
update msg model = ( model, Cmd.none )

view : Model -> Html Msg
view model = div [] [ text "The end!" ]