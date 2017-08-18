module Api.Helper exposing (..)

import Http exposing (Error(..), Response, expectJson, expectString, expectStringResponse)
import HttpBuilder exposing (..)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (int, string, float, list, oneOf, Decoder, decodeString)
import Json.Decode.Pipeline exposing (decode, resolve, required, optional, optionalAt, hardcoded)
import Time.DateTime as DateTime exposing (DateTime)
import Types exposing (..)
import Rocket exposing ((=>))
import Debug exposing (log, crash)


method : (String -> RequestBuilder ()) -> String -> String -> RequestBuilder ()
method method_ domain path =
    method_ (domain ++ "/api/" ++ path)
        |> withHeader "Accept" "application/json"
        |> withCredentials


get : String -> String -> RequestBuilder ()
get =
    method HttpBuilder.get


post : String -> String -> RequestBuilder ()
post =
    method HttpBuilder.post


delete : String -> String -> RequestBuilder ()
delete =
    method HttpBuilder.delete


put : String -> String -> RequestBuilder ()
put =
    method HttpBuilder.put


id : Decoder Id
id =
    decode identity
        |> required "id" int


dateTime : Decoder DateTime
dateTime =
    string
        |> Decode.andThen
            (\string ->
                case DateTime.fromISO8601 string of
                    Ok dateTime ->
                        Decode.succeed dateTime

                    Err _ ->
                        Decode.fail "Required ISO8601 date time format."
            )


identityDecoder : Decoder ( String, String )
identityDecoder =
    decode (,)
        |> required "name" string
        |> required "email" string


withExpectJson : Decoder a -> RequestBuilder b -> RequestBuilder a
withExpectJson decoder =
    withExpect <| expectJson decoder


sendWithErrorBody : Decoder Msg -> RequestBuilder Msg -> Cmd Msg
sendWithErrorBody errorDecoder =
    HttpBuilder.send (responseHandler errorDecoder)


send : RequestBuilder Msg -> Cmd Msg
send =
    sendWithErrorBody <| Decode.fail "Ignore Error Body"


responseHandler : Decoder Msg -> Result Error Msg -> Msg
responseHandler errorDecoder res =
    case res of
        Ok msg ->
            msg

        Err (BadUrl msg) ->
            NoHandle <| "Bad url : " ++ msg

        Err Timeout ->
            NoHandle "Timeout"

        Err NetworkError ->
            NoHandle "Network Error"

        Err (BadStatus { status, body }) ->
            case ( status.code, decodeString errorDecoder body ) of
                ( _, Ok msg ) ->
                    msg

                ( 401, _ ) ->
                    Unauthenticated

                _ ->
                    NoHandle <| "Bad status : " ++ toString status.code ++ " " ++ status.message

        Err (BadPayload msg { body }) ->
            NoHandle <| "Bad body : " ++ body ++ "\n" ++ msg


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
