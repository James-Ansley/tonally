module Tonally exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, disabled)
import Html.Events exposing (onClick)
import Syllable exposing (Syllable, Tone(..), Word, tones)



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { text : String, options : List Word, isChecked : Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { text = "我不喜欢苦的咖啡"
      , options =
            [ [ Syllable "wō" "wó" "wǒ" "wò" "wo" Nothing Third ]
            , [ Syllable "bū" "bú" "bǔ" "bù" "bu" Nothing Fourth ]
            , [ Syllable "xī" "xí" "xǐ" "xì" "xi" Nothing Third
              , Syllable "huān" "huán" "huǎn" "huàn" "huan" Nothing First
              ]
            , [ Syllable "kū" "kú" "kǔ" "kù" "ku" Nothing Third ]
            , [ Syllable "dē" "dé" "dě" "dè" "de" Nothing Fifth ]
            , [ Syllable "kā" "ká" "kǎ" "kà" "ka" Nothing First
              , Syllable "fēi" "féi" "fěi" "fèi" "fei" Nothing First
              ]
            ]
      , isChecked = False
      }
    , Cmd.none
    )


canCheck : Bool -> List Word -> Bool
canCheck hasChecked words =
    if hasChecked then
        False

    else
        Syllable.allSelected words


checkSymbol : Bool -> Bool -> Bool -> String
checkSymbol isChecked isCorrect showCorrect =
    case ( isChecked, isCorrect, showCorrect ) of
        ( True, True, True ) ->
            "✓"

        ( True, False, _ ) ->
            "✗"

        _ ->
            ""



-- UPDATE


type Msg
    = Selection SelectionOptions
    | Check


type alias SelectionOptions =
    { wordIndex : Int, syllableIndex : Int, tone : Tone }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Selection selection ->
            ( { model | options = updateSelection selection model.options }
            , Cmd.none
            )

        Check ->
            if canCheck model.isChecked model.options then
                ( { model | isChecked = True }, Cmd.none )

            else
                ( model, Cmd.none )


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
    div [ attribute "role" "main" ]
        [ p [ class "phrase" ] [ text model.text ]
        , p [ class "phrase" ] [ text (viewSelectedPinyin model.isChecked model.options) ]
        , div [ class "options" ] <|
            List.indexedMap (viewWord model.isChecked) model.options
        , div
            [ class "button-bar" ]
            [ button
                [ class "check-button"
                , disabled (not (canCheck model.isChecked model.options))
                , onClick Check
                ]
                [ text "check" ]
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
    String.join
        " "
        (List.map writeWord words)
        ++ " "
        ++ checkSymbol isChecked (Syllable.allCorrect words) True


viewWord : Bool -> Int -> Word -> Html Msg
viewWord isChecked wordIndex word =
    let
        viewSyllableOption : Int -> Syllable -> Tone -> Html Msg
        viewSyllableOption syllableIndex syllable tone =
            button
                [ class "option"
                , classList [ ( "selected", syllable.selection == Just tone ) ]
                , onClick
                    (Selection
                        { wordIndex = wordIndex
                        , syllableIndex = syllableIndex
                        , tone = tone
                        }
                    )
                ]
                [ text (Syllable.getTone tone syllable) ]

        viewChecked : Syllable -> Html Msg
        viewChecked syllable =
            div [ class "answer" ]
                [ text (checkSymbol isChecked (Syllable.isCorrect syllable) False) ]

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
