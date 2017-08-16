module View exposing (..)

import Types exposing (..)
import Time.DateTime as DateTime exposing (DateTime, DateTimeDelta)
import View.Stylesheet as Stylesheet exposing (Styles(..), stylesheet)
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
        |> Element.viewport stylesheet


rootElement : Model -> Element Styles variation Msg
rootElement ({ route } as model) =
    column None
        [ height <| fill 1
        , width <| fill 1
        ]
        [ navbar model
        , case route of
            TopRoute ->
                top model

            SignupRoute ->
                Page.signup model

            LoginRoute ->
                Page.login model

            BoardRoute name ->
                board model name
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
                paragraph None [] [ text "とってくるよ～" ]

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



-- , height <| fill 1
-- ,
-- type alias Board =
--     { id : Int
--     , name : String
--     , description : String
--     , threads : List Thread
--     , tags : List Tag
--     }


threadList : List Thread -> Element Styles variation Msg
threadList items =
    column None
        [ spacing 1
        , width <| fill 1
        ]
        (List.map threadCard items)


threadCard : Thread -> Element Styles variation Msg
threadCard thread =
    column Card
        [ width <| percent 95

        -- , maxWidth <| px 300
        , minHeight <| px 100
        , height <| fill 1
        , maxHeight <| px 300
        ]
        [ threadCardHeader thread ]


threadCardHeader : Thread -> Element Styles variation msg
threadCardHeader { id, title, lastUpdated, commentCount } =
    row CardHeader
        [ padding 12
        , justify
        ]
        [ paragraph None [] [ text title ]
        , paragraph None [] [ text <| toString id ]
        , paragraph None [] [ text <| DateTime.toISO8601 lastUpdated ]
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
        , onClick <| MoveTo <| BoardRoute <| board.name
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
        [ paragraph None [] [ text name ]
        , tag <| toString <| List.length threads
        ]
