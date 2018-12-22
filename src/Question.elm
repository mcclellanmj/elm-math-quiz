module Question exposing (Model, Msg, view, update, init)

import Html exposing (Html, div, span)
import Html.Attributes
import Html.Events
import Debug
import Time
import Browser.Dom
import Task

type alias Problem =
    { factor1: Int
    , factor2: Int
    }

type InputValues
    = Empty
    | Error String
    | Valid Int

type alias Model =
    { start: Time.Posix
    , currentValue: InputValues
    , problem: Problem
    }

type Msg
    = Input String
    | FormSubmit
    | FocusResult ( Result Browser.Dom.Error () )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Input value ->
            let
                 parseResult =
                    if(String.isEmpty value) then
                        Empty
                    else
                        case String.toInt value of
                            Nothing -> Error value
                            Just x -> Valid x
            in
                ( { model | currentValue = parseResult }, Cmd.none )

        FormSubmit -> Debug.todo "Question.update: Form Submit not yet implemented"

        FocusResult result -> Debug.log "Finished focus" ( model, Cmd.none )

displayValue : InputValues -> String
displayValue input =
    case input of
        Empty -> ""
        Error x -> x
        Valid x -> String.fromInt x

view : Model -> Html Msg
view model =
    let
        textSpan text = span [] [ Html.text text ]
        factor1 = span [] [ String.fromInt model.problem.factor1 |> Html.text ]
        factor2 = span [] [ String.fromInt model.problem.factor2 |> Html.text ]
        input = Html.input
            [ Html.Attributes.value ( displayValue model.currentValue )
            , Html.Events.onInput Input
            , Html.Attributes.id "answer-input"
            ] []
        fullQuestion = span [] [factor1, textSpan " + ", factor2, textSpan " = "]
    in
        div [ Html.Attributes.id "question-container" ]
            [ fullQuestion
            , Html.form
                [ Html.Events.onSubmit FormSubmit
                , Html.Attributes.id "question-form"
                ]

                [ input ]
            ]

init : Int -> Int -> Time.Posix -> (Model, Cmd Msg)
init number1 number2 startTime =
    let
        problem =
            { factor1 = number1
            , factor2 = number2
            }

        focusCmd = Browser.Dom.focus "answer-input" |> Task.attempt FocusResult
    in
        ( { start = startTime
        , currentValue = Empty
        , problem = problem
        }, focusCmd )