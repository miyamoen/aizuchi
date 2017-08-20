module Update exposing (..)

import Types exposing (..)
import Router exposing (moveTo)
import Api
import Rocket exposing ((=>))
import Debug exposing (log, crash)


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
                => [ Api.getThreadComments model.apiUri id (Just 1) Nothing ]

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

        SetCommentForm form ->
            { model | commentForm = form } => []

        GetBoards boards ->
            { model | boards = boards } => []

        GetBoard new threads ->
            { model
                | boards =
                    model.boards
                        |> List.filter (\board -> board.id /= new.id)
                        |> (::) new
                , threads = threads
            }
                => []

        GetThreadComments id comments ->
            { model | comments = comments } => []

        Unauthenticated ->
            { model | identity = Nothing } => [ moveTo LoginRoute ]

        NoHandle message ->
            let
                _ =
                    log "Not Handle :" message
            in
                model => []
