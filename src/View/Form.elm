module View.Form exposing (..)

import Types exposing (..)
import View.Common exposing (..)
import View.Layout as Layout
import View.Stylesheet as Stylesheet exposing (Styles(..))
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)
import Element.Events exposing (onInput, on, targetValue, onClick)
import Debug exposing (log, crash)


signup : SignupForm -> Element Styles variation Msg
signup form =
    Layout.formCard
        [ inputText Input
            [ placeholder "User Name"
            , onInput (\name -> SetSignupForm { form | name = name })
            , padding 5
            ]
            form.name
        , inputText Input
            [ placeholder "Email Address"
            , onInput (\email -> SetSignupForm { form | email = email })
            , padding 5
            ]
            form.email
        , inputPassword Input
            [ placeholder "Password"
            , onInput (\password -> SetSignupForm { form | password = password })
            , padding 5
            ]
            form.password
        , button <|
            el Button
                [ height <| px 40
                , type_ "submit"
                , onClick Signup
                ]
            <|
                text "Signup"
        ]


login : LoginForm -> Element Styles variation Msg
login form =
    Layout.formCard
        [ inputText Input
            [ placeholder "User Name"
            , onInput (\name -> SetLoginForm { form | name = name })
            , padding 5
            ]
            form.name
        , inputPassword Input
            [ placeholder "Password"
            , onInput (\password -> SetLoginForm { form | password = password })
            , padding 5
            ]
            form.password
        , button <|
            el Button
                [ height <| px 40
                , type_ "submit"
                , onClick Login
                ]
            <|
                text "Login"
        ]


inputPassword : style -> List (Attribute variation msg) -> String -> Element style variation msg
inputPassword elem attrs content =
    node "input" <|
        el elem (type_ "password" :: value content :: attrs) empty
