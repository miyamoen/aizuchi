module Api exposing (..)

import Http exposing (Error(..), Response, expectJson, expectString, expectStringResponse)
import HttpBuilder exposing (..)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (int, string, float, list, oneOf, Decoder, decodeString)
import Json.Decode.Pipeline exposing (decode, resolve, required, optional, optionalAt, hardcoded)
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


id : Decoder Id
id =
    decode identity
        |> required "id" int


getBoards : String -> Cmd Msg
getBoards domain =
    let
        decoder : Decoder (List Board)
        decoder =
            decode Board
                |> required "id" int
                |> required "name" string
                |> optional "description" string ""
                |> optional "threads" (list id) []
                |> optional "tags" (list id) []
                |> list
    in
        get (domain ++ "/api/boards")
            |> withHeaders
                [ "Content-Type" => "application/json"
                , "Accept" => "application/json"
                ]
            |> withCredentials
            |> withExpect (expectJson decoder)
            |> send (errorHandler GetBoards <| Decode.fail "Failed always")


identityDecoder : Decoder ( String, String )
identityDecoder =
    decode (,)
        |> required "name" string
        |> required "email" string


signup : String -> SignupForm -> Cmd Msg
signup domain form =
    let
        failDecoder : Decoder Msg
        failDecoder =
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
        post (domain ++ "/api/signup")
            |> withHeader "Accept" "application/json"
            |> withCredentials
            |> withJsonBody (transformSignupForm form)
            |> withExpect (expectJson identityDecoder)
            |> send (errorHandler OkSignup failDecoder)


login : String -> LoginForm -> Cmd Msg
login domain form =
    let
        failDecoder : Decoder Msg
        failDecoder =
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
        post (domain ++ "/api/login")
            |> withHeader "Accept" "application/json"
            |> withCredentials
            |> withJsonBody (transformLoginForm form)
            |> withExpect (expectJson identityDecoder)
            |> send (errorHandler OkLogin failDecoder)


logout : String -> Cmd Msg
logout domain =
    delete (domain ++ "/api/login")
        |> withCredentials
        |> send (errorHandler (always OkLogout) (Decode.fail "Failed always"))


errorHandler : (a -> Msg) -> Decoder Msg -> Result Error a -> Msg
errorHandler tagger decoder res =
    case res of
        Ok a ->
            tagger a

        Err (BadUrl msg) ->
            NoHandle <| "Bad url : " ++ msg

        Err Timeout ->
            NoHandle "Timeout"

        Err NetworkError ->
            NoHandle "Network Error"

        Err (BadStatus { status, body }) ->
            case ( status.code, decodeString decoder body ) of
                ( _, Ok msg ) ->
                    msg

                ( 401, _ ) ->
                    Unauthenticated

                _ ->
                    NoHandle <| "Bad status : " ++ toString status.code ++ " " ++ status.message

        Err (BadPayload msg { body }) ->
            NoHandle <| "Bad body : " ++ body ++ "\n" ++ msg


transformSignupForm : SignupForm -> Value
transformSignupForm { name, email, password } =
    Encode.object
        [ ( "user/name", Encode.string name )
        , ( "user/email", Encode.string email )
        , ( "user/password", Encode.string password )
        ]


transformLoginForm : LoginForm -> Value
transformLoginForm { name, password } =
    Encode.object
        [ ( "user/name", Encode.string name )
        , ( "user/password", Encode.string password )
        ]
