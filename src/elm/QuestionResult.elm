module QuestionResult exposing (Model, Msg (..), view, update, init)

import Question exposing (UserResult)

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
update = Debug.todo "QuestionResult.update not implemented"

view = Debug.todo "QuestionResult.view not implemented"