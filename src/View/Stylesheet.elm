module View.Stylesheet exposing (Styles(..), stylesheet)

import View.Colors exposing (..)
import Style exposing (..)
import Style.Font as Font
import Style.Color as Color
import Style.Shadow as Shadow
import Style.Border as Border
import Style.Transition as Transition exposing (Transition)
import Color exposing (Color)


type Styles
    = None
    | Logo
    | Card
    | Button
    | HairLine
    | Input


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.stylesheet
        [ style None []
        , style Logo
            [ Font.size 50
            , Font.justifyAll
            , Font.weight 8
            ]
        , style Card
            [ shadows
                [ Shadow.box { shadow | offset = ( 0, 2 ), blur = 3 }
                , Shadow.box { shadow | blur = 1 }
                ]
            ]
        , style HairLine [ Color.background colors.hairLine ]
        , style Button
            [ Color.background primary.main
            , Color.text colors.white
            , Font.weight 700
            , Style.shadows
                [ Shadow.box { shadow | offset = ( 0, 5 ), color = primary.shadow } ]
            , Style.cursor "pointer"
            , Border.none
            , Border.rounded 3
            , Transition.transitions
                [ { transition | duration = 200, props = [ "box-shadow", "transform" ] }
                , { transition | duration = 400, props = [ "background" ] }
                ]
            , hover
                [ Style.translate 0 1 0
                , Style.shadows
                    [ Shadow.box { shadow | offset = ( 0, 4 ), color = primary.shadow } ]
                ]
            , pseudo "active"
                [ Color.background primary.shadow
                , Style.translate 0 5 0
                , Style.shadows
                    [ Shadow.box { shadow | color = primary.shadow } ]
                ]
            ]
        , style Input
            [ Border.all 1
            , Border.rounded 3
            , Border.solid
            , Color.border colors.border
            ]
        ]


shadow :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
shadow =
    { offset = ( 0, 0 )
    , size = 0
    , blur = 0
    , color = colors.shadow
    }


transition : Transition
transition =
    { delay = 0
    , duration = 0
    , easing = "ease"
    , props = []
    }
