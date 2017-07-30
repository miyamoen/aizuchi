module View.Common exposing (..)

import View.Stylesheet as Stylesheet exposing (Styles(..))
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)
import Debug exposing (log, crash)


logo : Element Styles variation msg
logo =
    paragraph Logo
        [ center
        , verticalCenter
        ]
        [ text "Aizuchi" ]
