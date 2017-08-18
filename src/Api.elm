module Api exposing (..)

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


getBoards : String -> Cmd Msg
getBoards domain =
    let
        decoder : Decoder Msg
        decoder =
            decode Board
                |> required "id" int
                |> required "name" string
                |> optional "description" string ""
                |> optional "threads" (list id) []
                |> optional "tags" (list id) []
                |> list
                |> Decode.map GetBoards
    in
        get domain "boards"
            |> withExpectJson decoder
            |> send


getBoard : String -> String -> Cmd Msg
getBoard domain name =
    let
        board : Decoder Board
        board =
            decode Board
                |> required "id" int
                |> required "name" string
                |> optional "description" string ""
                |> optional "threads" (list id) []
                |> optional "tags" (list id) []

        thread : Decoder Thread
        thread =
            decode Thread
                |> required "id" int
                |> required "title" string
                |> hardcoded []
                |> required "since" dateTime
                |> required "last-updated" dateTime
                |> required "resnum" int
                |> optional "tags" (list id) []

        decoder : Decoder Msg
        decoder =
            Decode.map2 GetBoard board <| Decode.field "threads" (list thread)
    in
        get domain ("board/" ++ name)
            |> withExpectJson decoder
            |> send


identityDecoder : Decoder ( String, String )
identityDecoder =
    decode (,)
        |> required "name" string
        |> required "email" string


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
        post domain "signup"
            |> withJsonBody (convertSignupForm form)
            |> withExpectJson (Decode.map OkSignup identityDecoder)
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
        post domain "login"
            |> withJsonBody (convertLoginForm form)
            |> withExpectJson (Decode.map OkLogin identityDecoder)
            |> sendWithErrorBody errorDecoder


logout : String -> Cmd Msg
logout domain =
    delete domain "login"
        |> withExpectJson (Decode.succeed OkLogout)
        |> send


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
