module Main exposing (..)

import Types exposing (..)
import View exposing (view)
import Api
import Navigation exposing (Location)
import UrlParser exposing (..)
import Rocket exposing (..)
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



---- UPDATE ----


update : Msg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        MoveTo route ->
            model => [ moveTo route ]

        SetRoute NotFoundRoute ->
            { model | route = NotFoundRoute } => []

        SetRoute TopRoute ->
            { model | route = TopRoute }
                => [ Api.getBoards model.apiUri ]

        SetRoute SignupRoute ->
            { model | route = SignupRoute } => []

        SetRoute LoginRoute ->
            { model | route = LoginRoute } => []

        SetRoute (BoardRoute name) ->
            { model | route = BoardRoute name }
                => [ Api.getBoard model.apiUri name ]

        SetRoute (ThreadRoute id) ->
            { model | route = ThreadRoute id }
                => []

        Signup ->
            model => [ Api.signup model.apiUri model.signupForm ]

        Login ->
            model => [ Api.login model.apiUri model.loginForm ]

        Logout ->
            model => [ Api.logout model.apiUri ]

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
            { model | boards = boards |> log "ぼーどsだよ" } => []

        GetBoard new threads ->
            { model
                | boards =
                    model.boards
                        |> List.filter (\board -> board.id /= new.id)
                        |> (::) new
                , threads = threads
            }
                => []

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



---- PROGRAM ----


main : Program Never Model Msg
main =
    Navigation.program router
        { view = view
        , init = init >> Rocket.batchInit
        , update = update >> Rocket.batchUpdate
        , subscriptions = subscriptions
        }
