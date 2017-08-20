module Api exposing (..)

import Http exposing (Error(..), Response, expectJson, expectString, expectStringResponse)
import HttpBuilder exposing (withJsonBody)
import ApiHelper exposing (..)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (int, string, float, list, oneOf, Decoder, decodeString)
import Json.Decode.Pipeline exposing (decode, resolve, required, optional, optionalAt, hardcoded)
import Decoder exposing (..)
import Time.DateTime as DateTime exposing (DateTime)
import Types exposing (..)
import Rocket exposing ((=>))
import Debug exposing (log, crash)


getBoards : String -> Cmd Msg
getBoards domain =
    let
        decoder : Decoder Msg
        decoder =
            decode GetBoards
                |> requiredDecoder (list board)
    in
        request domain BoardsPath
            |> withExpectJson decoder
            |> send


getBoard : String -> String -> Cmd Msg
getBoard domain name =
    let
        decoder : Decoder Msg
        decoder =
            decode GetBoard
                |> requiredDecoder board
                |> required "threads" (list thread)
    in
        request domain (BoardPath name)
            |> withExpectJson decoder
            |> send


getThreadComments : String -> Id -> Maybe Int -> Maybe Int -> Cmd Msg
getThreadComments domain id from to =
    let
        decoder : Decoder Msg
        decoder =
            decode (GetThreadComments id)
                |> requiredDecoder (list comment)
    in
        request domain (ThreadCommentsPath id from to)
            |> withExpectJson decoder
            |> send


signup : String -> SignupForm -> Cmd Msg
signup domain form =
    let
        errorDecoder : Decoder Msg
        errorDecoder =
            decode
                (\( name, email, password ) ->
                    { form
                        | nameErrors = name
                        , emailErrors = email
                        , passwordErrors = password
                    }
                )
                |> required
                    "message"
                    (decode (,,)
                        |> optional "name" (list string) []
                        |> optional "email" (list string) []
                        |> optional "password" (list string) []
                    )
                |> Decode.map SetSignupForm
    in
        request domain SignupPath
            |> withJsonBody (convertSignupForm form)
            |> withExpectJson (Decode.map OkSignup identity_)
            |> sendWithErrorBody errorDecoder


login : String -> LoginForm -> Cmd Msg
login domain form =
    let
        errorDecoder : Decoder Msg
        errorDecoder =
            oneOf
                [ decode (\error -> { form | error = Just error })
                    |> required "message" string
                    |> Decode.map SetLoginForm
                , decode
                    (\( name, password ) ->
                        { form
                            | nameErrors = name
                            , passwordErrors = password
                        }
                    )
                    |> required
                        "message"
                        (decode (,)
                            |> optional "name" (list string) []
                            |> optional "password" (list string) []
                        )
                    |> Decode.map SetLoginForm
                ]
    in
        request domain LoginPath
            |> withJsonBody (convertLoginForm form)
            |> withExpectJson (Decode.map OkLogin identity_)
            |> sendWithErrorBody errorDecoder


logout : String -> Cmd Msg
logout domain =
    request domain LogoutPath
        |> withExpectAlways OkLogout
        |> send


convertSignupForm : SignupForm -> Value
convertSignupForm { name, email, password } =
    Encode.object
        [ ( "user/name", Encode.string name )
        , ( "user/email", Encode.string email )
        , ( "user/password", Encode.string password )
        ]


convertLoginForm : LoginForm -> Value
convertLoginForm { name, password } =
    Encode.object
        [ ( "user/name", Encode.string name )
        , ( "user/password", Encode.string password )
        ]
