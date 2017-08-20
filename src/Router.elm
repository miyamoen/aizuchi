module Router exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (..)
import Rocket exposing ((=>))
import Debug exposing (log, crash)


router : Location -> Msg
router location =
    oneOf
        [ map SignupRoute <| s "signup"
        , map LoginRoute <| s "login"
        , map BoardRoute <| s "board" </> string
        , map ThreadRoute <| s "thread" </> int
        , map TopRoute <| s ""
        ]
        |> flip parseHash location
        |> Maybe.withDefault NotFoundRoute
        |> SetRoute


moveTo : Route -> Cmd msg
moveTo route =
    (case route of
        NotFoundRoute ->
            crash "notFoundページに移動はできません"

        TopRoute ->
            ""

        SignupRoute ->
            "signup"

        LoginRoute ->
            "login"

        BoardRoute name ->
            "board/" ++ name

        ThreadRoute id ->
            "thread/" ++ toString id
    )
        |> (++) "./#/"
        |> Navigation.newUrl
