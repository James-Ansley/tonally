port module Tonally exposing (main)

import Array exposing (Array)
import Browser
import Html exposing (..)
import Html.Attributes exposing (accesskey, attribute, checked, class, classList, disabled, for, id, name, type_, value)
import Html.Events exposing (onClick, onFocus)
import Phrases exposing (Phrase, phrases)
import Random
import Random.Array
import Syllable exposing (Syllable, Tone(..), Word, tones)



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


port toggleTheme : () -> Cmd msg



-- MODEL


type alias Question =
    { text : String, options : List Word, isChecked : Bool }


type Model
    = Loading
    | Error String
    | Loaded (Array Phrase) Int Question


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Random.generate LoadPhrases (Random.Array.shuffle phrases)
    )


canCheck : Bool -> List Word -> Bool
canCheck hasChecked words =
    if hasChecked then
        False

    else
        Syllable.allSelected words


check : String
check =
    "✓"


cross : String
cross =
    "✗"


feedbackSymbol : String -> String -> String -> Bool -> Bool -> String
feedbackSymbol ifCorrect ifIncorrect ifHidden isChecked isCorrect =
    case ( isChecked, isCorrect ) of
        ( True, True ) ->
            ifCorrect

        ( True, False ) ->
            ifIncorrect

        ( False, _ ) ->
            ifHidden



-- UPDATE


type Msg
    = LoadPhrases (Array Phrase)
    | Selection SelectionOptions
    | Check
    | ToggleLightMode
    | RequestNewPhrase


type alias SelectionOptions =
    { wordIndex : Int, syllableIndex : Int, tone : Tone }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( _, LoadPhrases phrases ) ->
            ( updateCurrentQuestion "unexpected error: cannot load questions" phrases 0
            , Cmd.none
            )

        ( Error _, _ ) ->
            ( model, Cmd.none )

        ( Loaded phrases index question, Selection selection ) ->
            ( Loaded phrases index { question | options = updateSelection selection question.options }
            , Cmd.none
            )

        ( Loaded phrases index question, Check ) ->
            if canCheck question.isChecked question.options then
                ( Loaded phrases index { question | isChecked = True }, Cmd.none )

            else
                ( model, Cmd.none )

        ( Loaded phrases index _, RequestNewPhrase ) ->
            let
                newIndex =
                    modBy (Array.length phrases) (index + 1)
            in
            ( updateCurrentQuestion "unexpected error: cannot load new phrase" phrases newIndex
            , Cmd.none
            )

        ( _, ToggleLightMode ) ->
            ( model, toggleTheme () )

        ( Loading, _ ) ->
            ( model, Cmd.none )


updateCurrentQuestion : String -> Array Phrase -> Int -> Model
updateCurrentQuestion errorMsg phrases newQuestionIndex =
    let
        question =
            Array.get newQuestionIndex phrases
    in
    case question of
        Just phrase ->
            Loaded phrases newQuestionIndex { text = phrase.text, options = phrase.options, isChecked = False }

        Nothing ->
            Error errorMsg


updateSelection : SelectionOptions -> List Word -> List Word
updateSelection selection words =
    let
        updateWord : Int -> Word -> Word
        updateWord wordIndex word =
            if wordIndex == selection.wordIndex then
                List.indexedMap updateSyllable word

            else
                word

        updateSyllable : Int -> Syllable -> Syllable
        updateSyllable index syllable =
            if index == selection.syllableIndex then
                { syllable | selection = Just selection.tone }

            else
                syllable
    in
    List.indexedMap updateWord words



-- VIEW


view : Model -> Html Msg
view model =
    div [ attribute "role" "main" ] <|
        case model of
            Error message ->
                [ button
                    [ onClick ToggleLightMode
                    , accesskey 't'
                    ]
                    [ text "toggle light/dark" ]
                , p [ class "message" ] [ text message ]
                ]

            Loading ->
                [ button [ onClick ToggleLightMode, accesskey 't' ] [ text "toggle light/dark" ]
                , p [ class "message" ] [ text "loading..." ]
                ]

            Loaded _ _ question ->
                [ button [ onClick ToggleLightMode, accesskey 't' ] [ text "toggle light/dark" ]
                , p [ class "phrase" ] [ text question.text ]
                , p [ class "phrase" ] [ text (viewSelectedPinyin question.isChecked question.options) ]
                , div [ class "options" ] <|
                    List.indexedMap (viewWord question.isChecked) question.options
                , div
                    [ class "button-bar" ]
                    [ button
                        [ class "bottom-button"
                        , disabled (not (canCheck question.isChecked question.options))
                        , onClick Check
                        , accesskey 'c'
                        ]
                        [ text "check" ]
                    , button
                        [ class "bottom-button"
                        , onClick RequestNewPhrase
                        , accesskey 'a'
                        ]
                        [ text "try another" ]
                    ]
                ]


viewSelectedPinyin : Bool -> List Word -> String
viewSelectedPinyin isChecked words =
    let
        writeSyllable : Syllable -> String
        writeSyllable syllable =
            Syllable.getTone (Maybe.withDefault Fifth syllable.selection) syllable

        writeWord : Word -> String
        writeWord word =
            String.concat (List.map writeSyllable word)
    in
    String.join " " (List.map writeWord words)
        ++ " "
        ++ feedbackSymbol check cross "" isChecked (Syllable.allCorrect words)


viewWord : Bool -> Int -> Word -> Html Msg
viewWord isChecked wordIndex word =
    let
        viewSyllableOption : Int -> Syllable -> Tone -> Html Msg
        viewSyllableOption syllableIndex syllable tone =
            let
                syllableText =
                    Syllable.getTone tone syllable
            in
            label
                [ class "option"
                , classList [ ( "selected", syllable.selection == Just tone ) ]
                ]
                [ span [ class "option-label" ] [ text syllableText ]
                , input
                    [ type_ "radio"
                    , name
                        (String.concat
                            [ Syllable.getTone Fifth syllable
                            , String.fromInt wordIndex
                            , String.fromInt syllableIndex
                            ]
                        )
                    , value syllableText
                    , checked (syllable.selection == Just tone)
                    , onClick (Selection { wordIndex = wordIndex, syllableIndex = syllableIndex, tone = tone })
                    , onFocus (Selection { wordIndex = wordIndex, syllableIndex = syllableIndex, tone = tone })
                    ]
                    []
                ]

        viewChecked : Syllable -> Html Msg
        viewChecked syllable =
            div [ class "answer" ]
                [ text (feedbackSymbol "" cross "" isChecked (Syllable.isCorrect syllable)) ]

        viewSyllable : Int -> Syllable -> Html Msg
        viewSyllable syllableIndex syllable =
            div
                [ class "syllable" ]
            <|
                List.concat
                    [ List.map (viewSyllableOption syllableIndex syllable) tones
                    , [ viewChecked syllable ]
                    ]
    in
    div [ class "word" ] (List.indexedMap viewSyllable word)
