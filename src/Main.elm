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
    , signupForm = initialSignupForm
    , loginForm = initialLoginForm
    , boards = []
    , threads = []
    }


initialSignupForm : SignupForm
initialSignupForm =
    { name = ""
    , nameErrors = []
    , email = ""
    , emailErrors = []
    , password = ""
    , passwordErrors = []
    }


initialLoginForm : LoginForm
initialLoginForm =
    { error = Nothing
    , name = ""
    , nameErrors = []
    , password = ""
    , passwordErrors = []
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


b : Board
b =
    { id = 17592186045426
    , name = "default"
    , description = "Default board"
    , threads = []
    , tags = []
    }



---- UPDATE ----


update : Msg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        MoveTo route ->
            model => [ moveTo route ]

        SetRoute TopRoute ->
            { model | route = TopRoute }
                => [ Api.getBoards model.apiUri ]

        SetRoute SignupRoute ->
            { model | route = SignupRoute } => []

        SetRoute LoginRoute ->
            { model | route = LoginRoute } => []

        SetRoute( BoardRoute id) ->

        Signup ->
            model => [ Api.signup model.apiUri model.signupForm ]

        Login ->
            model => [ Api.login model.apiUri model.loginForm ]

        Logout ->
            model => [ Api.logout model.apiUri ]

        -- SignupResult (Ok ()) ->
        --     model => [ moveTo LoginRoute ]
        -- SignupResult (Err form) ->
        --     { model | signupForm = form } => []
        -- LoginResult (Ok ( name, email )) ->
        --     { model
        --         | identity =
        --             Just
        --                 { name = name
        --                 , email = email
        --                 , tags = []
        --                 }
        --     }
        --         => []
        -- LoginResult (Err form) ->
        --     { model | loginForm = form } => []
        OkSignup ( name, email ) ->
            let
                form =
                    model.loginForm

                form_ =
                    { form | name = name, password = model.signupForm.password }
            in
                { model | loginForm = form_ } => [ moveTo LoginRoute ]

        OkLogin ( name, email ) ->
            { model | identity = Just { name = name, email = email, tags = [] } }
                => [ moveTo TopRoute ]

        OkLogout ->
            model => [ moveTo LoginRoute ]

        SetSignupForm form ->
            { model | signupForm = form } => []

        SetLoginForm form ->
            { model | loginForm = form } => []

        GetBoards boards ->
            { model | boards = boards |> log "ぼーどだよ" } => []

        Unauthenticated ->
            { model | identity = Nothing } => [ moveTo LoginRoute ]

        NoHandle message ->
            let
                _ =
                    log "Not Handle :" message
            in
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
