module View.Common exposing (..)

import Types exposing (..)
import View.StyleSheet as StyleSheet exposing (Styles(..))
import Element exposing (..)
import Element.Events exposing (..)
import Element.Attributes as Attrs exposing (..)
import Markdown
import Debug exposing (log, crash)


logo : Element Styles variation msg
logo =
    paragraph Logo
        [ center
        , verticalCenter
        ]
        [ text "Aizuchi" ]


navbar : Model -> Element Styles variation Msg
navbar model =
    row Navbar
        [ padding 20, justify ]
        [ paragraph Logo [ onClick (MoveTo TopRoute) ] [ text "Aizuchi" ]
        , paragraph Logo [ onClick Logout ] [ text "Logout" ]
        ]


tag : String -> Element Styles variation msg
tag label =
    el StyleSheet.Tag
        [ center
        , verticalCenter
        , width <| px 40
        , paddingXY 5 0
        ]
    <|
        paragraph Font7 [] [ text label ]


markdown : String -> Element Styles variation msg
markdown content =
    Markdown.toHtml [] content
        |> Element.html
