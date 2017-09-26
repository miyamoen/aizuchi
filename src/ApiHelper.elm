module ApiHelper exposing (..)

import Http exposing (Error(..), Response, expectJson, expectString, expectStringResponse)
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (int, string, float, list, oneOf, Decoder, decodeString)
import Types exposing (..)
import Rocket exposing ((=>))
import Debug exposing (log, crash)


toRequestWithApiPath : String -> ApiPath -> RequestBuilder ()
toRequestWithApiPath domain apiPath =
    let
        toFullPath paths =
            [ domain, "api" ] ++ paths |> String.join "/"
    in
        case apiPath of
            LoginPath ->
                [ "login" ]
                    |> toFullPath
                    |> post

            LogoutPath ->
                [ "login" ]
                    |> toFullPath
                    |> delete

            SignupPath ->
                [ "signup" ]
                    |> toFullPath
                    |> post

            BoardPath name ->
                [ "board", name ]
                    |> toFullPath
                    |> get

            BoardsPath ->
                [ "boards" ]
                    |> toFullPath
                    |> get

            ThreadPath id ->
                [ "thread", toString id ]
                    |> toFullPath
                    |> get

            ThreadCommentsPath id (Just from) (Just to) ->
                [ "thread"
                , toString id
                , "comments"
                , String.join "-" [ toString from, toString to ]
                ]
                    |> toFullPath
                    |> get

            ThreadCommentsPath id (Just from) Nothing ->
                [ "thread", toString id, "comments", toString from ++ "-" ]
                    |> toFullPath
                    |> get

            ThreadCommentsPath id Nothing (Just to) ->
                [ "thread", toString id, "comments", "-" ++ toString to ]
                    |> toFullPath
                    |> get

            ThreadCommentsPath id Nothing Nothing ->
                [ "thread", toString id, "comments" ]
                    |> toFullPath
                    |> get

            CreateCommentPath threadId ->
                [ "thread", toString threadId, "comments" ]
                    |> toFullPath
                    |> post


request : String -> ApiPath -> RequestBuilder ()
request domain apiPath =
    toRequestWithApiPath domain apiPath
        |> withHeader "Accept" "application/json"
        |> withCredentials


withExpectJson : Decoder a -> RequestBuilder b -> RequestBuilder a
withExpectJson decoder =
    withExpect <| expectJson decoder


withExpectAlways : a -> RequestBuilder b -> RequestBuilder a
withExpectAlways a =
    withExpect <| expectStringResponse (\res -> Ok a)


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
