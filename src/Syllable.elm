module Syllable exposing (..)


type alias Word =
    List Syllable


type Tone
    = First
    | Second
    | Third
    | Fourth
    | Fifth


tones =
    [ First, Second, Third, Fourth, Fifth ]


type alias Syllable =
    { first : String
    , second : String
    , third : String
    , forth : String
    , fifth : String
    , selection : Maybe Tone
    , correct : Tone
    }


isCorrect : Syllable -> Bool
isCorrect syllable =
    syllable.selection == Just syllable.correct


allCorrect : List Word -> Bool
allCorrect words =
    List.all (List.all isCorrect) words


allSelected : List Word -> Bool
allSelected words =
    List.all (List.all (\s -> s.selection /= Nothing)) words


getTone : Tone -> Syllable -> String
getTone tone syllable =
    case tone of
        First ->
            syllable.first

        Second ->
            syllable.second

        Third ->
            syllable.third

        Fourth ->
            syllable.forth

        Fifth ->
            syllable.fifth
