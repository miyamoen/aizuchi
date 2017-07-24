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
signupElement model =
    column None
        [ height <| fill 1
        , width <| fill 1
        , verticalCenter
        , center
        , spacingXY 25 25
        ]
        [ paragraph None [] [ text "signupですわ" ]
        ]


loginElement : Model -> Element Styles variation Msg
loginElement { loginForm } =
    column None
        [ height <| fill 1
        , width <| fill 1
        , verticalCenter
        , center
        , spacingXY 25 25
        ]
        [ logo
        , column Card
            [ padding 10 ]
            [ paragraph None
                []
                [ text "ここにじゃぶじゃぶloginしたくなるloginフォームを入れる" ]
            , hairline None
            , inputText None
                [ placeholder "User Name"
                , onChange (\name -> SetLoginForm { loginForm | name = name })
                ]
                loginForm.name
            , inputPassword None
                [ placeholder "Password"
                , onChange (\password -> SetLoginForm { loginForm | password = password })
                ]
                loginForm.password
            ]
        , link "#/signup" <| text "signup"
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
        el elem (type_ "password" :: value (toString content) :: attrs) empty


onChange : (String -> msg) -> Attribute variation msg
onChange tagger =
    on "change" (Json.map tagger targetValue)
