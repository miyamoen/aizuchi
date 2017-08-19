module View exposing (..)

import Types exposing (..)
import Time.DateTime as DateTime exposing (DateTime, DateTimeDelta)
import View.StyleSheet as StyleSheet exposing (Styles(..), styleSheet)
import View.Form as Form
import View.Common as Common exposing (..)
import View.Layout as Layout
import View.Page as Page
import Html exposing (Html)
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)
import Element.Events exposing (onInput, on, targetValue, onClick)
import Json.Decode as Json
import Debug exposing (log, crash)


view : Model -> Html Msg
view model =
    rootElement model
        |> Element.viewport styleSheet


rootElement : Model -> Element Styles variation Msg
rootElement ({ route } as model) =
    column None
        [ height <| fill 1
        , width <| fill 1
        ]
        [ navbar model
        , case route of
            NotFoundRoute ->
                notFound model

            TopRoute ->
                top model

            SignupRoute ->
                Page.signup model

            LoginRoute ->
                Page.login model

            BoardRoute name ->
                board model name

            ThreadRoute id ->
                thread model id
        ]


notFound : Model -> Element Styles variation Msg
notFound model =
    paragraph None [] [ text "このRouteは知らないRouteです" ]


thread : Model -> Id -> Element Styles variation Msg
thread { threads, comments } id =
    let
        maybeThread =
            List.filter (.id >> (==) id) threads
                |> List.head
    in
        case maybeThread of
            Just thread ->
                paragraph None [] [ text <| toString thread ]

            Nothing ->
                paragraph None [] [ text "Threadとってくるよ～" ]


comment : Model -> Comment -> Element Styles variation Msg
comment _ { content, postedAt, postedBy, format, index } =
    row None
        []
        [ image ("https://flathash.com/" ++ postedBy.name) None [ width <| px 64, height <| px 64 ] empty
        ]


board : Model -> String -> Element Styles variation Msg
board { boards, threads } name =
    let
        maybeBoard =
            List.filter (.name >> (==) name) boards
                |> List.head

        getThread id =
            List.filter (.id >> (==) id) threads
                |> List.head
    in
        case maybeBoard of
            Nothing ->
                paragraph None [] [ text "Boardとってくるよ～" ]

            Just board ->
                board.threads
                    |> List.filterMap getThread
                    |> threadList


top : Model -> Element Styles variation Msg
top model =
    wrappedRow None
        [ width <| fill 1
        , center
        , spacing 25
        , paddingXY 2 25
        ]
    <|
        List.map boardCard model.boards


threadList : List Thread -> Element Styles variation Msg
threadList items =
    column None
        [ spacing 1
        , width <| fill 1
        , center
        ]
        (List.map threadCard items)


threadCard : Thread -> Element Styles variation Msg
threadCard thread =
    column Card
        [ width <| percent 95
        , minHeight <| px 100
        , height <| fill 1
        , maxHeight <| px 300
        , onClick <| MoveTo <| ThreadRoute thread.id
        ]
        [ threadCardHeader thread ]


threadCardHeader : Thread -> Element Styles variation msg
threadCardHeader { id, title, lastUpdated, commentCount } =
    row CardHeader
        [ padding 12
        , justify
        , verticalCenter
        ]
        [ paragraph Font3 [] [ text title ]
        , paragraph Font7 [] [ text <| toString id ]
        , paragraph Font5 [] [ text <| DateTime.toISO8601 lastUpdated ]
        , tag <| toString <| commentCount
        ]


boardCard : Board -> Element Styles variation Msg
boardCard ({ description } as board) =
    column Card
        [ width <| percent 95
        , maxWidth <| px 300
        , minHeight <| px 100
        , height <| fill 1
        , maxHeight <| px 300
        , onClick <| MoveTo <| BoardRoute board.name
        ]
        [ boardCardHeader board
        , paragraph None [ padding 24, yScrollbar ] [ text description ]
        ]


boardCardHeader : Board -> Element Styles variation msg
boardCardHeader { name, threads } =
    row CardHeader
        [ padding 12
        , justify
        ]
        [ paragraph Font3 [] [ text name ]
        , tag <| toString <| List.length threads
        ]
