module Main exposing (main)

import Browser
import Debug
import Html
import Html.Attributes
import Random
import Question
import Time
import Task

type alias Flags =
    { randomSeed: Int
    }

type Question = Question Int Int

type LocalModel
    = Initial (Int, Int)
    | QuestionModel Question.Model

type alias Model =
    { currentSeed: Random.Seed
    , localModel: LocalModel
    }

type Msg
    = TimeMsg Time.Posix
    | QuestionMsg Question.Msg

reversePairWith : x -> y -> (y, x)
reversePairWith x y = (y, x)

generateNumbers : Random.Seed -> ( (Int, Int), Random.Seed )
generateNumbers seed =
    let
        firstGenerator = Random.int 1 19
        secondFunction first = Random.map (reversePairWith first) ( Random.int 1 (20 - first) )
        finalGenerator = firstGenerator |> Random.andThen secondFunction
    in
        Random.step finalGenerator seed

init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( numbers, seed ) = Random.initialSeed flags.randomSeed |> generateNumbers
        model =
            { currentSeed = seed
            , localModel = Initial numbers
            }
    in
        ( model, Task.perform TimeMsg Time.now )

viewQuestion : Question -> String -> Html.Html Msg
viewQuestion ( Question num1 num2 ) answer =
    let
        quickSpan content = Html.span [] content
        number1Html = Html.span [] [ String.fromInt num1 |> Html.text ]
        number2Html = Html.span [] [ String.fromInt num2 |> Html.text ]
        questionHtml = quickSpan [ number1Html, quickSpan [ Html.text " + " ], number2Html, quickSpan [Html.text " = "] ]
    in
        Html.div [] [ questionHtml ]

viewLocal : LocalModel -> Html.Html Msg
viewLocal model =
    case model of
        QuestionModel subModel -> Question.view subModel |> Html.map QuestionMsg

        _ -> Html.div [] [ Html.text "Initializing" ]

wrapperDiv : String -> Html.Html msg -> Html.Html msg
wrapperDiv className toWrap =
    Html.div [ Html.Attributes.class className ] [ toWrap ]

view : Model -> Browser.Document Msg
view model = 
    let 
        localHtml = viewLocal model.localModel
    in
        [ wrapperDiv "app-container" localHtml ] |> Browser.Document "Math-Quiz"

liftToParent : ( subModel -> model ) -> ( subMsg -> Msg ) -> ( subModel, Cmd subMsg ) -> ( model, Cmd Msg )
liftToParent modelLift msgLift ( subModel, subCmd ) =
    ( modelLift subModel
    , Cmd.map msgLift subCmd
    )

updateLocalModel: Msg -> LocalModel -> ( LocalModel, Cmd Msg )
updateLocalModel msg localModel =
    case (msg, localModel) of
        (QuestionMsg (Question.Internal innerMsg), QuestionModel innerModel) ->
            Question.update innerMsg innerModel |> liftToParent QuestionModel QuestionMsg

        (QuestionMsg (Question.External external), QuestionModel model) ->
            Debug.log "Got finished" ( localModel, Cmd.none )

        (_, _) -> Debug.todo "Got an unmapped message"

update : Msg -> Model -> (Model, Cmd Msg)
update msg globalModel =
    case (msg, globalModel.localModel) of
        ( TimeMsg timeMsg, Initial (num1, num2) ) ->
            let
                ( questionModel, questionCmd ) = Question.init num1 num2 timeMsg
            in
                ( { globalModel | localModel = QuestionModel questionModel }, Cmd.map QuestionMsg questionCmd )

        ( TimeMsg timeMsg, _ ) -> Debug.log "Got a time message when not in initial state" ( globalModel, Cmd.none )

        ( _, model ) ->
            let
                (newLocal, newMsg) = updateLocalModel msg model
            in
                ({ globalModel | localModel = newLocal }, newMsg)

sub : Model -> Sub Msg
sub _ = Sub.none

main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = sub
        , view = view
        }
