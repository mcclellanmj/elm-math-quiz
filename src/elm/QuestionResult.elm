module QuestionResult exposing (Model, Msg (..), ExternalMsgs (..), view, update, init)

import Html exposing ( Html, div, text )
import Html.Attributes
import Html.Events
import Browser.Dom
import Task
import Http
import Json.Decode exposing ( Decoder, field, string, at )

import GlobalTypes exposing ( UserResult )

type InternalMsgs
  = GifResult ( Result Http.Error String )
  | FocusResult ( Result Browser.Dom.Error () )

type ExternalMsgs =
  NextQuestion

type Msg
  = Internal InternalMsgs
  | External ExternalMsgs

type State
  = Initializing Int
  | ShowImage String

type alias Model = 
  { result: UserResult
  , state: State
  }

init : Int -> UserResult -> ( Model, Cmd Msg )
init random userResult =
  let
    initModel = 
      { result = userResult
      , state = Initializing random
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

getRandomGif : Int -> String -> Cmd Msg
getRandomGif index topic =
    Http.get
      { url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
      , expect = Http.expectJson ( GifResult >> Internal ) decodeGifUrl }

decodeGifUrl : Decoder String
decodeGifUrl =
  at ["data", "image_url"] string
