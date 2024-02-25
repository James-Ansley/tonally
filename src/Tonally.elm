module Tonally exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, disabled)
import Html.Events exposing (onClick)



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


type alias Word =
    List Syllable


type Tone
    = First
    | Second
    | Third
    | Forth
    | Fifth


tones =
    [ First, Second, Third, Forth, Fifth ]


type alias Syllable =
    { first : String
    , second : String
    , third : String
    , forth : String
    , fifth : String
    , selection : Maybe Tone
    , correct : Tone
    }


type alias SelectionOptions =
    { wordIndex : Int, syllableIndex : Int, tone : Tone }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { text = "我不喜欢苦的咖啡"
      , options =
            [ [ Syllable "wō" "wó" "wǒ" "wò" "wo" Nothing Third ]
            , [ Syllable "bū" "bú" "bǔ" "bù" "bu" Nothing Forth ]
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
        List.all (List.all (\s -> s.selection /= Nothing)) words


syllableIsCorrect : Syllable -> Bool
syllableIsCorrect syllable =
    syllable.selection == Just syllable.correct


answerIsCorrect : List Word -> Bool
answerIsCorrect words =
    List.all (List.all syllableIsCorrect) words


selectedSyllableTone : Tone -> Syllable -> String
selectedSyllableTone tone syllable =
    case tone of
        First ->
            syllable.first

        Second ->
            syllable.second

        Third ->
            syllable.third

        Forth ->
            syllable.forth

        Fifth ->
            syllable.fifth


checkSymbol : Bool -> Bool -> String
checkSymbol isChecked isCorrect =
    case ( isChecked, isCorrect ) of
        ( True, True ) ->
            "✓"

        ( True, False ) ->
            "✗"

        ( False, _ ) ->
            ""



-- { text = "我是新西兰人"
--      , options =
--            [ [ Syllable "wō" "wó" "wǒ" "wò" "wo" Nothing Third ]
--            , [ Syllable "shī" "shí" "shǐ" "shì" "shi" Nothing Forth ]
--            , [ Syllable "xīn" "xín" "xǐn" "xìn" "xin" Nothing First
--              , Syllable "xī" "xí" "xǐ" "xì" "xi" Nothing First
--              , Syllable "lān" "lán" "lǎn" "làn" "lan" Nothing Second
--              ]
--            , [ Syllable "rēn" "rén" "rěn" "rèn" "ren" Nothing Second ]
--            ]
--      , isChecked = False
--      }
-- UPDATE


type Msg
    = Selection SelectionOptions
    | Check


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
            selectedSyllableTone (Maybe.withDefault Fifth syllable.selection) syllable

        writeWord : Word -> String
        writeWord word =
            String.concat (List.map writeSyllable word)
    in
    String.join
        " "
        (List.map writeWord words)
        ++ " "
        ++ checkSymbol isChecked (answerIsCorrect words)


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
                [ text (selectedSyllableTone tone syllable) ]

        viewChecked : Syllable -> Html Msg
        viewChecked syllable =
            div [ class "answer" ]
                [ text (checkSymbol isChecked (syllableIsCorrect syllable)) ]

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
