module QuestionResult exposing (Model, Msg (..), ExternalMsgs (..), view, update, init)

import Html exposing ( Html, div, text )
import Html.Attributes
import Html.Events
import Browser.Dom
import Task
import Http

import GlobalTypes exposing ( UserResult )

type InternalMsgs
  = RandomGif String
  | FocusResult ( Result Browser.Dom.Error () )

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
    focusCmd = Browser.Dom.focus "submit-button" |> Task.attempt (FocusResult >> Internal)
  in
    ( initModel, focusCmd )

update : InternalMsgs -> Model -> ( Model, Cmd Msg )
update msg model = ( model, Cmd.none )

view : Model -> Html Msg
view model = 
  let
    result = if model.result.correct then "Correct!" else "Wrong!"
    button = Html.button 
      [ Html.Events.onClick (External NextQuestion)
      , Html.Attributes.id "submit-button" ]

      [ Html.text "Submit" ]
  in
    div [] [ text result, button ]

-- getRandomGif : String -> Cmd Msg
-- getRandomGif topic =
  -- let
    -- url =
      -- "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  -- in
    -- Http.send ShowImage (Http.get url decodeGifUrl)

-- decodeGifUrl : Decode.Decoder String
-- decodeGifUrl =
  -- Decode.at ["data", "image_url"] Decode.string
