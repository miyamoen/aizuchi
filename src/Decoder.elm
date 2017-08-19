module Decoder exposing (..)

import Types exposing (..)
import Json.Decode as Decode exposing (int, string, float, list, oneOf, Decoder, decodeString)
import Json.Decode.Pipeline exposing (..)
import Time.DateTime as DateTime exposing (DateTime)


requiredDecoder : Decoder a -> Decoder (a -> b) -> Decoder b
requiredDecoder valDecoder decoder =
    custom valDecoder decoder


id : Decoder Id
id =
    decode identity
        |> required "id" int


identity_ : Decoder ( String, String )
identity_ =
    decode (,)
        |> required "name" string
        |> required "email" string


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


user : Decoder User
user =
    decode User
        |> required "name" string
        |> required "email" string
        |> optional "tags" (list id) []


board : Decoder Board
board =
    decode Board
        |> requiredDecoder id
        |> required "name" string
        |> required "description" string
        |> optional "threads" (list id) []
        |> optional "tags" (list id) []


thread : Decoder Thread
thread =
    decode Thread
        |> requiredDecoder id
        |> required "title" string
        |> hardcoded []
        |> required "since" dateTime
        |> required "last-updated" dateTime
        |> required "resnum" int
        |> optional "tags" (list id) []


comment : Decoder Comment
comment =
    decode Comment
        |> requiredDecoder id
        |> required "content" string
        |> required "posted-at" dateTime
        |> required "posted-by" user
        |> requiredAt [ "format", "ident" ] format
        |> required "no" int


format : Decoder Format
format =
    string
        |> Decode.andThen
            (\string ->
                case string of
                    "plain" ->
                        Decode.succeed Plain

                    "markdown" ->
                        Decode.succeed Markdown

                    "voice" ->
                        Decode.succeed Voice

                    _ ->
                        Decode.fail ("Bad format : " ++ string)
            )
