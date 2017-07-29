module View exposing (..)

import Types exposing (..)
import View.Stylesheet as Stylesheet exposing (Styles(..), stylesheet)
import Html exposing (Html)
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)
import Element.Events exposing (onInput, on, targetValue, onClick)
import Json.Decode as Json
import Debug exposing (log, crash)


view : Model -> Html Msg
view model =
    Element.viewport stylesheet <|
        rootElement model


rootElement : Model -> Element Styles variation Msg
rootElement ({ route } as model) =
    case route of
        TopRoute ->
            topElement model

        SignupRoute ->
            signupElement model

        LoginRoute ->
            loginElement model


topElement : Model -> Element Styles variation Msg
topElement model =
    column None
        [ height <| fill 1
        , width <| fill 1
        , verticalCenter
        , center
        , spacingXY 25 25
        ]
        [ paragraph None [] [ text "トップですわ" ]
        ]


signupElement : Model -> Element Styles variation Msg
signupElement { signupForm } =
    column None
        [ width <| fill 1
        , verticalCenter
        , center
        , spacingXY 25 25
        ]
        [ logo
        , column Card
            [ padding 20
            , spacingXY 10 14
            , width <| percent 90
            , maxWidth <| px 450
            , height <| fill 1
            ]
            [ inputText Input
                [ placeholder "User Name"
                , onInput (\name -> SetSignupForm { signupForm | name = name })
                , padding 5
                ]
                signupForm.name
            , inputText Input
                [ placeholder "Email Address"
                , onInput (\email -> SetSignupForm { signupForm | email = email })
                , padding 5
                ]
                signupForm.email
            , inputPassword Input
                [ placeholder "Password"
                , onInput (\password -> SetSignupForm { signupForm | password = password })
                , padding 5
                ]
                signupForm.password
            , button <|
                el Button
                    [ height <| px 40
                    , type_ "submit"
                    , onClick Signup
                    ]
                <|
                    text "Signup"
            ]
        , paragraph None
            [ spacing 10 ]
            [ paragraph None [] [ link "#/login" <| text "Login" ]
            ]
        ]


loginElement : Model -> Element Styles variation Msg
loginElement { loginForm } =
    column None
        [ width <| fill 1
        , verticalCenter
        , center
        , spacingXY 25 25
        ]
        [ logo
        , column Card
            [ padding 20
            , spacingXY 10 14
            , width <| percent 90
            , maxWidth <| px 450
            , height <| fill 1
            ]
            [ inputText Input
                [ placeholder "User Name"
                , onInput (\name -> SetLoginForm { loginForm | name = name })
                , padding 5
                ]
                loginForm.name
            , inputPassword Input
                [ placeholder "Password"
                , onInput (\password -> SetLoginForm { loginForm | password = password })
                , padding 5
                ]
                loginForm.password
            , button <|
                el Button
                    [ height <| px 40
                    , type_ "submit"
                    , onClick Login
                    ]
                <|
                    text "Login"
            ]
        , paragraph None
            [ spacing 10 ]
            [ paragraph None [] [ text "New to us?" ]
            , paragraph None [] [ link "#/signup" <| text "Sign up" ]
            ]
        ]


logo : Element Styles variation msg
logo =
    paragraph Logo
        [ center
        , verticalCenter
        ]
        [ text "Aizuchi" ]



---- Form ----


inputPassword : style -> List (Attribute variation msg) -> String -> Element style variation msg
inputPassword elem attrs content =
    node "input" <|
        el elem (type_ "password" :: value content :: attrs) empty
