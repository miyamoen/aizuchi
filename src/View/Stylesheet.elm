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
    | FormCard
    | Card
    | CardHeader
    | Button
    | Input
    | Navbar
    | Tag


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style Logo
            [ Font.size 50
            , Font.justifyAll
            , Font.weight 8
            ]
        , style FormCard
            [ shadows
                [ Shadow.box { shadow | offset = ( 0, 2 ), blur = 3 }
                , Shadow.box { shadow | blur = 1 }
                ]
            ]
        , style Card
            [ shadows
                [ Shadow.box { shadow | offset = ( 0, 2 ), blur = 3 }
                , Shadow.box { shadow | blur = 1 }
                ]
            , Font.alignLeft
            , Font.lineHeight 1.4
            , Font.letterSpacing 1
            , Style.cursor "pointer"
            , Transition.all
            , hover
                [ Style.translate 0 -1 0
                , Style.shadows
                    [ Shadow.box { shadow | offset = ( 0, 4 ), blur = 4 }
                    , Shadow.box { shadow | blur = 8, size = 1 }
                    ]
                ]
            ]
        , style CardHeader
            [ shadows
                [ Shadow.box { shadow | offset = ( 0, 1 ), blur = 2 }
                ]
            , Font.size 20
            , Font.weight 400
            , Font.alignLeft
            ]
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
        , style Navbar
            [ Font.size 30
            , Font.justifyAll
            , Font.weight 5
            ]
        , style Tag
            [ Font.size 15
            , Font.center
            , Font.lineHeight 1.5
            , Color.text colors.white
            , Color.background primary.main
            , Border.rounded 10
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
