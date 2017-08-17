module View.StyleSheet exposing (Styles(..), styleSheet)

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
    | Tag
    | Navbar
    | Font1
    | Font2
    | Font3
    | Font4
    | Font5
    | Font6
    | Font7


styleSheet : StyleSheet Styles variation
styleSheet =
    Style.styleSheet <|
        [ style None []
        , style Logo
            [ fontSize.size1
            , Font.justifyAll
            , fontBold
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
            , fontSize.size3
            , Font.alignLeft
            ]
        , style Button
            [ Color.background primary.main
            , Color.text colors.white
            , fontBold
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
        , style Tag
            [ Font.center
            , Font.lineHeight 1.5
            , Color.text colors.white
            , Color.background primary.main
            , Border.rounded 10
            ]
        , style Navbar
            [ Font.size 30
            , Font.justifyAll
            , Font.weight 5
            ]
        ]
            ++ fontSizeStyles


fontSizeStyles : List (Style Styles variation)
fontSizeStyles =
    [ style Font1 [ fontSize.size1 ]
    , style Font2 [ fontSize.size2 ]
    , style Font3 [ fontSize.size3 ]
    , style Font4 [ fontSize.size4 ]
    , style Font5 [ fontSize.size5 ]
    , style Font6 [ fontSize.size6 ]
    , style Font7 [ fontSize.size7 ]
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


fontSize :
    { size1 : Property style variation
    , size2 : Property style variation
    , size3 : Property style variation
    , size4 : Property style variation
    , size5 : Property style variation
    , size6 : Property style variation
    , size7 : Property style variation
    }
fontSize =
    let
        base =
            16
    in
        { size1 = base * 3.0 |> Font.size
        , size2 = base * 2.5 |> Font.size
        , size3 = base * 2.0 |> Font.size
        , size4 = base * 1.5 |> Font.size
        , size5 = base * 1.25 |> Font.size
        , size6 = base * 1.0 |> Font.size
        , size7 = base * 0.75 |> Font.size
        }


fontBold : Property style variation
fontBold =
    Font.weight 700
