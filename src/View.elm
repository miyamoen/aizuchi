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
    column Main
        [ -- height <| fill 1
          -- , width <| fill 1
          minHeight <| fill 1
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
thread ({ threads, comments } as model) id =
    let
        maybeThread =
            List.filter (.id >> (==) id) threads
                |> List.head
    in
        column None
            [ width <| fill 1, height <| fill 1 ]
            [ column ThreadClass
                [ yScrollbar
                , width <| fill 1
                , height <| fill 1
                , maxHeight <| percent 90
                ]
                (List.map comment comments)
            , commentForm id model.commentForm
            ]


commentForm : Id -> CommentForm -> Element Styles variation Msg
commentForm threadId ({ content, format } as form) =
    row None
        [ padding 10, height <| fill 1, maxHeight <| px 200, yScrollbar ]
        [ column None
            [ width <| percent 50 ]
            [ textArea TextArea
                [ onInput
                    (\content ->
                        { form | content = content }
                            |> SetCommentForm
                    )
                , rows 17
                ]
                content
            , row None
                []
                [ button <|
                    el Button
                        [ height <| px 40
                        , type_ "submit"
                        , onClick <| PostComment threadId
                        ]
                    <|
                        text "New Comment"
                ]
            ]
        , el None [ width <| percent 50 ] <| commentContent format content
        ]


comment : Comment -> Element Styles variation msg
comment { content, postedAt, postedBy, format, index } =
    row None
        [ padding 5
        , spacing 8
        , width <| fill 1
        ]
        [ image ("https://flathash.com/" ++ postedBy.name) None [ width <| px 64, height <| px 64 ] empty
        , column None
            [ paddingTop 17, spacing 10 ]
            [ row None
                [ spacing 20 ]
                [ paragraph None [] [ text <| toString index ]
                , paragraph None [] [ text postedBy.name ]
                , paragraph None [] [ text <| DateTime.toISO8601 postedAt ]
                ]
            , commentContent format content
            ]
        ]


commentContent : Format -> String -> Element Styles variation msg
commentContent format content =
    case format of
        Plain ->
            el None [ width <| fill 1, padding 5 ] <|
                paragraph PlainText [] [ text content ]

        Markdown ->
            el None [ width <| fill 1, paddingXY 60 5 ] <|
                markdown content

        Voice ->
            el None [ width <| fill 1, padding 5 ] <|
                paragraph None [] [ text "Not Supported Voice Comment" ]


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
