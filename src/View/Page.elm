module View.Page exposing (..)

import Types exposing (..)
import View.StyleSheet as StyleSheet exposing (Styles(..))
import View.Form as Form
import View.Common as Common exposing (..)
import View.Layout as Layout
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)
import Element.Events exposing (onInput, on, targetValue, onClick)
import Debug exposing (log, crash)


signup : Model -> Element Styles variation Msg
signup { signupForm } =
    Layout.centerColumn
        [ logo
        , Form.signup signupForm
        , paragraph None
            [ spacing 10 ]
            [ paragraph None [] [ link "#/login" <| text "Login" ]
            ]
        ]


login : Model -> Element Styles variation Msg
login { loginForm } =
    Layout.centerColumn
        [ logo
        , Form.login loginForm
        , paragraph None
            [ spacing 10 ]
            [ paragraph None [] [ text "New to us?" ]
            , paragraph None [] [ link "#/signup" <| text "Sign up" ]
            ]
        ]
