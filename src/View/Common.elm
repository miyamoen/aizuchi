module View.Common exposing (..)

import Types exposing (..)
import View.Stylesheet as Stylesheet exposing (Styles(..))
import Element exposing (..)
import Element.Events exposing (..)
import Element.Attributes as Attrs exposing (..)
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
