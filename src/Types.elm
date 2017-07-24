module Types exposing (..)

import Http exposing (Error(..))
import Time.DateTime as DateTime exposing (DateTime, DateTimeDelta)


---- Main ----


type alias Model =
    { route : Route
    , apiUri : String
    , identity : Maybe User
    , signupForm : SignupForm
    , loginForm : LoginForm
    , boards : List Board
    }


type Route
    = TopRoute
    | SignupRoute
    | LoginRoute


type alias SignupForm =
    { errors : List String
    , name : String
    , email : String
    , password : String
    }


type alias LoginForm =
    { errors : List String
    , name : String
    , password : String
    }



---- Backchanneling Model ----


type alias User =
    { name : String
    , email : String
    , tags : List Tag
    }


type alias Board =
    { id : Int
    , name : String
    , description : String
    , threads : List Thread
    , tags : List Tag
    }


type alias Thread =
    { title : String
    , comments : List Comment
    , since : DateTime
    , lastUpdated : DateTime
    , commentCount : Int -- 'resnum' in back-channeling
    , tags : List Tag
    }


type alias Comment =
    { content : String
    , postedAt : DateTime
    , postedBy : Maybe User
    , format : Format
    , id : Int
    , index : Int -- 'no' in back-channeling
    }


type alias Tag =
    { name : String
    , description : String
    , isPrivate : Bool
    , prioity : Int
    , color : TagColors
    }


type Format
    = Plain
    | Markdown
    | Voice


type TagColors
    = White
    | Black
    | Grey
    | Yellow
    | Orange
    | Green
    | Red
    | Blue
    | Pink
    | Purple
    | Brown



---- Msg ----


type Msg
    = SetRoute Route
    | MoveTo Route
    | Signup
    | SignupResult (List String)
    | SetSignupForm SignupForm
    | Login
    | LoginResult (List String)
    | SetLoginForm LoginForm
    | Logout
    | LogoutResult (List String)
    | GetBoards (Result Error (List Board))
