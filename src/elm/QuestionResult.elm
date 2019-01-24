module QuestionResult exposing (Model, Msg (..), ExternalMsgs (..), view, update, init)

import Html exposing ( Html, div, text )
import Html.Attributes
import Html.Events
import Browser.Dom
import Task
import Http
import Url.Builder
import Json.Decode exposing ( Decoder, field, string, at, index )

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
    requestImageCmd = getRandomGif random "hedgehog pet"
  in
    ( initModel, Cmd.batch [ focusCmd, requestImageCmd ] )

update : InternalMsgs -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FocusResult _ -> ( model, Cmd.none )

    GifResult (Ok x) -> ( { model | state = ShowImage x }, Cmd.none )

    GifResult (Err e) -> ( model, Cmd.none )

viewReward : State -> Html Msg
viewReward state =
  case state of
      Initializing x -> Html.span [] [ text (String.fromInt x) ]

      ShowImage x -> Html.img [ Html.Attributes.src x ] []

view : Model -> Html Msg
view model = 
  let
    result = if model.result.correct then "Correct!" else "Wrong!"
    button = Html.button
      [ Html.Events.onClick (External NextQuestion)
      , Html.Attributes.id "submit-button" ]

      [ Html.text "Submit" ]
    rewardImage = viewReward model.state
  in
    div [] [ text result, button, rewardImage ]

getRandomGif : Int -> String -> Cmd Msg
getRandomGif index topic =
    let
      compiledUrl =
        Url.Builder.crossOrigin "https://api.giphy.com"
          [ "v1", "gifs", "search" ]
          [ Url.Builder.string "api_key" "YyFNENNsyV9REr81iH35J5T6OMAltEOz"
          , Url.Builder.string "q" topic
          , Url.Builder.int "limit" 1
          , Url.Builder.int "offset" index
          , Url.Builder.string "rating" "G"
          , Url.Builder.string "lang" "en" ]
    in
      Http.get
        { url = compiledUrl
        , expect = Http.expectJson ( GifResult >> Internal ) decodeGifUrl }

decodeGifUrl : Decoder String
decodeGifUrl =
  field "data" <| index 0 <| at [ "images", "fixed_width", "webp" ] string