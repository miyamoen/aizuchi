module Main exposing (..)

import Types exposing (..)
import View exposing (view)
import Api
import Navigation exposing (Location)
import UrlParser exposing (..)
import Rocket exposing (..)
import Http exposing (Error(..))
import Debug exposing (log, crash)


---- MODEL ----


initialModel : Model
initialModel =
    { route = TopRoute
    , apiUri = "http://localhost:3009"
    , identity = Nothing
    , signupForm =
        { errors = []
        , name = ""
        , email = ""
        , password = ""
        }
    , loginForm =
        { errors = []
        , name = ""
        , password = ""
        }
    , boards = []
    }


initialCmds : List (Cmd Msg)
initialCmds =
    []


init : Location -> ( Model, List (Cmd Msg) )
init location =
    let
        ( model, cmds ) =
            update (router location) initialModel
    in
        model => initialCmds ++ cmds



---- UPDATE ----


update : Msg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        SetRoute TopRoute ->
            { model | route = TopRoute } => [ Api.getBoards model.apiUri ]

        MoveTo route ->
            model => [ moveTo route ]

        SetRoute SignupRoute ->
            { model | route = SignupRoute } => []

        SetRoute LoginRoute ->
            { model | route = LoginRoute } => []

        Signup ->
            model => [ Api.signup model.apiUri model.signupForm ]

        Login ->
            model => [ Api.login model.apiUri model.loginForm ]

        Logout ->
            model => [ Api.logout model.apiUri ]

        SignupResult [] ->
            model => [ moveTo LoginRoute ]

        SignupResult errors ->
            let
                form =
                    model.signupForm
            in
                { model | signupForm = { form | errors = errors } }
                    => []

        LoginResult [] ->
            model => [ moveTo TopRoute ]

        LoginResult errors ->
            let
                form =
                    model.loginForm
            in
                { model | loginForm = { form | errors = errors } }
                    => []

        LogoutResult [] ->
            model => [ moveTo LoginRoute ]

        LogoutResult errors ->
            crash ("Failed in Logout : " ++ toString errors)

        SetSignupForm form ->
            { model | signupForm = form } => []

        SetLoginForm form ->
            { model | loginForm = form } => []

        GetBoards (Ok boards) ->
            { model | boards = boards |> log "ぼーどだよ" } => []

        GetBoards (Err (BadStatus { status })) ->
            if status.code == 401 then
                model => [ moveTo LoginRoute ]
            else
                model => []

        GetBoards (Err _) ->
            model => []



---- Subscriptions ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



---- Navigation ----


router : Location -> Msg
router location =
    oneOf
        [ map SignupRoute <| s "signup"
        , map LoginRoute <| s "login"
        ]
        |> flip parseHash location
        |> Maybe.withDefault TopRoute
        |> SetRoute


moveTo : Route -> Cmd msg
moveTo route =
    (case route of
        TopRoute ->
            ""

        SignupRoute ->
            "signup"

        LoginRoute ->
            "login"
    )
        |> (++) "./#/"
        |> Navigation.newUrl



---- PROGRAM ----


main : Program Never Model Msg
main =
    Navigation.program router
        { view = view
        , init = init >> Rocket.batchInit
        , update = update >> Rocket.batchUpdate
        , subscriptions = subscriptions
        }
