module Question exposing (Model, Msg (..), ExternalMsgs (..), view, update, init)

import Html exposing ( Html, div, span )
import Html.Attributes
import Html.Events
import Time
import Browser.Dom
import Task
import GlobalTypes exposing ( UserResult )

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
    = Internal InternalMsgs
    | External ExternalMsgs

type InternalMsgs
    = Input String
    | FormSubmit
    | FocusResult ( Result Browser.Dom.Error () )

type ExternalMsgs = Finished UserResult

sendReportMessage: Bool -> (Int, Int) -> Time.Posix -> Time.Posix -> Msg
sendReportMessage correct factors startTime finishTime =
    External <| Finished
        { start = startTime
        , finish = finishTime
        , correct = correct
        , factors = factors
        }

update : InternalMsgs -> Model -> (Model, Cmd Msg)
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

        FormSubmit ->
            case model.currentValue of
                Empty -> ( model, Cmd.none )
                Error _ -> ( model, Cmd.none )
                Valid value ->
                    let
                        factor1 = model.problem.factor1
                        factor2 = model.problem.factor2
                        correct = factor1 + factor2 == value
                        reportFn = sendReportMessage correct (factor1, factor2) model.start
                    in
                        ( model, Task.perform reportFn Time.now)

        FocusResult result -> ( model, Cmd.none )

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
            , Html.Events.onInput (Input >> Internal)
            , Html.Attributes.id "answer-input"
            , Html.Attributes.type_ "number"
            ] []
        button = Html.button [ Html.Attributes.id "submit-question-button" ] [ Html.text ">" ]
        fullQuestion = span [ Html.Attributes.id "question-span" ] [factor1, textSpan " + ", factor2, textSpan " = "]
    in
        div [ Html.Attributes.id "question-container" ]
            [Html.form
                [ Html.Events.onSubmit (Internal FormSubmit)
                , Html.Attributes.id "question-form"
                ]
                [ div [] [fullQuestion, input], div [ Html.Attributes.id "button-container" ] [button] ]
            ]

init : Int -> Int -> Time.Posix -> (Model, Cmd Msg)
init number1 number2 startTime =
    let
        problem =
            { factor1 = number1
            , factor2 = number2
            }

        focusCmd = Browser.Dom.focus "answer-input" |> Task.attempt (FocusResult >> Internal)
    in
        ( { start = startTime
        , currentValue = Empty
        , problem = problem
        }, focusCmd )