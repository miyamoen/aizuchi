module Main exposing (..)

import Types exposing (..)
import Update exposing (update)
import Router exposing (router)
import View exposing (view)
import Api
import Navigation exposing (Location)
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
    , commentForm = initialCommentForm
    , boards = []
    , threads = []
    , comments = []
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


initialCommentForm : CommentForm
initialCommentForm =
    { threadId = Nothing
    , content = ""
    , format = Plain
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



---- Subscriptions ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



---- PROGRAM ----


main : Program Never Model Msg
main =
    Navigation.program router
        { view = view
        , init = init >> Rocket.batchInit
        , update = update >> Rocket.batchUpdate
        , subscriptions = subscriptions
        }
