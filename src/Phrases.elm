module Phrases exposing (..)

import Array
import Syllable exposing (Syllable, Tone(..), Word)


type alias Phrase =
    { text : String, options : List Word }


phrases =
    Array.fromList
        [ { text = "我爱咖啡", options = [ wo3, ai4, ka1fei1 ] }
        , { text = "我不喜欢苦的咖啡", options = [ wo3, bu4, xi3huan1, ku3, de5, ka1fei1 ] }
        , { text = "他爱猫", options = [ ta1, ai4, mao1 ] }
        , { text = "她爱狗", options = [ ta1, ai4, gou3 ] }
        , { text = "我是新西兰人", options = [ wo3, shi4, xin1xi1lan2, ren2 ] }
        ]



-- Words


ai4 =
    [ ai Fourth ]


bu4 =
    [ bu Fourth ]


de5 =
    [ de Fifth ]


gou3 =
    [ gou Third ]


ka1fei1 =
    [ ka First, fei First ]


ku3 =
    [ ku Third ]


mao1 =
    [ mao First ]


ren2 =
    [ ren Second ]


shi4 =
    [ shi Fourth ]


ta1 =
    [ ta First ]


wo3 =
    [ wo Third ]


xi3huan1 =
    [ xi Third, huan First ]


xin1xi1lan2 =
    [ xin First, xi First, lan Second ]



-- Syllables


ai =
    Syllable "aī" "aí" "aǐ" "aì" "ai" Nothing


bu =
    Syllable "bū" "bú" "bǔ" "bù" "bu" Nothing


fei =
    Syllable "fēi" "féi" "fěi" "fèi" "fei" Nothing


de =
    Syllable "dē" "dé" "dě" "dè" "de" Nothing


gou =
    Syllable "gōu" "góu" "gǒu" "gòu" "gou" Nothing


ka =
    Syllable "kā" "ká" "kǎ" "kà" "ka" Nothing


huan =
    Syllable "huān" "huán" "huǎn" "huàn" "huan" Nothing


ku =
    Syllable "kū" "kú" "kǔ" "kù" "ku" Nothing


lan =
    Syllable "lān" "lán" "lǎn" "làn" "lan" Nothing


mao =
    Syllable "māo" "máo" "mǎo" "mào" "mao" Nothing


ren =
    Syllable "rēn" "rén" "rěn" "rèn" "ren" Nothing


shi =
    Syllable "shī" "shí" "shǐ" "shì" "shi" Nothing


ta =
    Syllable "tā" "tá" "tǎ" "tà" "ta" Nothing


wo =
    Syllable "wō" "wó" "wǒ" "wò" "wo" Nothing


xi =
    Syllable "xī" "xí" "xǐ" "xì" "xi" Nothing


xin =
    Syllable "xīn" "xín" "xǐn" "xìn" "xin" Nothing
