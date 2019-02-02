module QuestionResult exposing (Model, Msg (..), ExternalMsgs (..), view, update, init)

import Html exposing ( Html, div, text )
import Html.Attributes exposing ( id )
import Html.Events
import Browser.Dom
import Task
import Http
import Url.Builder
import Json.Decode exposing ( Decoder, field, string, at, index )
import Time.Extra
import Time

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

isSlow : Time.Posix -> Time.Posix -> Bool
isSlow start end =
  let
    diffSeconds = Time.Extra.diff Time.Extra.Second Time.utc start end
  in
    diffSeconds > 5

determineReward : UserResult -> String
determineReward result =
  case result.correct of
    True ->
        if isSlow result.start result.finish then "turtle pet" else "hedgehog pet"
    False -> "disappointed"

init : Int -> UserResult -> ( Model, Cmd Msg )
init random userResult =
  let
    initModel = 
      { result = userResult
      , state = Initializing random
      }
    focusCmd = Browser.Dom.focus "submit-button" |> Task.attempt (FocusResult >> Internal)
    rewardTopic = determineReward userResult
    requestImageCmd = determineReward userResult |> getRandomGif random
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
      Initializing x -> Html.img [ Html.Attributes.src "loading.gif", id "reward-image" ] [ ]

      ShowImage x -> Html.img [ Html.Attributes.src x, id "reward-image" ] []

view : Model -> Html Msg
view model = 
  let
    result = if model.result.correct then
        if isSlow model.result.start model.result.finish then "A Little Slow!" else "Correct!"
      else "Try Again"
    button = Html.button
      [ Html.Events.onClick (External NextQuestion)
      , id "submit-button" ]

      [ Html.text ">" ]
    rewardImage = viewReward model.state
  in
    div [ id "result-container" ] [ div [] [text result], rewardImage, div [] [button] ]

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
          ]
    in
      Http.get
        { url = compiledUrl
        , expect = Http.expectJson ( GifResult >> Internal ) decodeGifUrl }

decodeGifUrl : Decoder String
decodeGifUrl =
  field "data" <| index 0 <| at [ "images", "fixed_width", "webp" ] string