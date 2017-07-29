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
    { name : String
    , nameErrors : List String
    , email : String
    , emailErrors : List String
    , password : String
    , passwordErrors : List String
    }


type alias LoginForm =
    { error : Maybe String
    , name : String
    , nameErrors : List String
    , password : String
    , passwordErrors : List String
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
    | OkSignup ( String, String )
      -- | SignupResult (Result SignupForm ())
    | SetSignupForm SignupForm
    | Login
    | OkLogin ( String, String )
      -- | LoginResult (Result LoginForm ( String, String ))
    | SetLoginForm LoginForm
    | Logout
    | OkLogout
    | GetBoards (List Board)
      -- | GetIdentity ( String, String )
    | Unauthenticated
    | NoHandle String
