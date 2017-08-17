module View.Layout exposing (..)

import View.Common exposing (..)
import View.StyleSheet as StyleSheet exposing (Styles(..))
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)


centerColumn : List (Element Styles variation msg) -> Element Styles variation msg
centerColumn =
    column None
        [ width <| fill 1
        , verticalCenter
        , center
        , spacingXY 25 25
        ]


formCard : List (Element Styles variation msg) -> Element Styles variation msg
formCard =
    column FormCard
        [ padding 20
        , spacingXY 10 14
        , width <| percent 90
        , maxWidth <| px 450
        ]
