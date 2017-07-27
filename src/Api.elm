module Api exposing (..)

import Http exposing (Error(..), Response, expectJson, expectString, expectStringResponse)
import HttpBuilder exposing (..)
import Json.Decode exposing (int, string, float, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Types exposing (..)
import Rocket exposing ((=>))
import Debug exposing (log, crash)


{-
   type alias Response body =
       { url : String
       , status : { code : Int, message : String }
       , headers : Dict String String
       , body : body
       }
-}
-- ({:db/id 17592186045426
-- , :board/name "default"
-- , :board/description "Default board"})
-- [{id: 17592186045426, name: "default", description: "Default board"}]


getBoards : String -> Cmd Msg
getBoards domain =
    let
        decoder : Decoder (List Board)
        decoder =
            decode Board
                |> required "id" int
                |> required "name" string
                |> optional "description" string ""
                |> hardcoded []
                |> hardcoded []
                |> list
    in
        get (domain ++ "/api/boards")
            |> withHeaders
                [ "Content-Type" => "application/json"
                , "Accept" => "application/json"
                ]
            |> withCredentials
            |> withExpect (expectJson decoder)
            |> send GetBoards


signup : String -> SignupForm -> Cmd Msg
signup domain form =
    let
        handler : Response String -> Result String (List String)
        handler { url, status, headers, body } =
            case status.code of
                200 ->
                    Ok [ "Signup Failed" ]

                302 ->
                    Ok []

                _ ->
                    Err "Unexpected Status Code"
    in
        post (domain ++ "/signup")
            |> withHeader "Content-Type" "application/x-www-form-urlencoded"
            |> withCredentials
            |> withUrlEncodedBody (transformSignupForm form)
            |> withExpect (expectStringResponse handler)
            |> send (errorToMessages >> SignupResult)


login : String -> LoginForm -> Cmd Msg
login domain form =
    let
        handler : Response String -> Result String (List String)
        handler ({ url, status, headers, body } as res) =
            let
                re =
                    log "なんふぁ" res
            in
                case status.code of
                    200 ->
                        Ok []

                    302 ->
                        Ok []

                    _ ->
                        Err "Unexpected Status Code"
    in
        post (domain ++ "/login")
            |> withHeader "Content-Type" "application/x-www-form-urlencoded"
            |> withCredentials
            |> withUrlEncodedBody (transformLoginForm form)
            |> withExpect (expectStringResponse handler)
            |> send (errorToMessages >> LoginResult)


logout : String -> Cmd Msg
logout domain =
    let
        handler : Response String -> Result String (List String)
        handler { url, status, headers, body } =
            case status.code of
                302 ->
                    Ok []

                _ ->
                    Err "Unexpected Status Code"
    in
        get (domain ++ "/logout")
            |> withCredentials
            |> withExpect (expectStringResponse handler)
            |> send (errorToMessages >> LogoutResult)


errorToMessages : Result Error (List String) -> List String
errorToMessages res =
    case res of
        Ok msgs ->
            msgs

        Err (BadUrl msg) ->
            [ "Bad url : " ++ msg ]

        Err Timeout ->
            [ "Timeout" ]

        Err NetworkError ->
            [ "Network Error" ]

        Err (BadStatus { status }) ->
            [ "Bad status : " ++ toString status.code ++ " " ++ status.message ]

        Err (BadPayload msg { body }) ->
            [ msg, "Bad body :" ++ body ]


transformSignupForm : SignupForm -> List ( String, String )
transformSignupForm { name, email, password } =
    [ ( "user/name", name )
    , ( "user/email", email )
    , ( "user/password", password )
    ]


transformLoginForm : LoginForm -> List ( String, String )
transformLoginForm { name, password } =
    [ ( "username", name )
    , ( "password", password )
    ]
