module Types exposing (..)

import Time.DateTime as DateTime exposing (DateTime, DateTimeDelta)
import Debug exposing (log, crash)


---- Main ----


type alias Model =
    { route : Route
    , apiUri : String
    , identity : Maybe User
    , signupForm : SignupForm
    , loginForm : LoginForm
    , commentForm : CommentForm
    , boards : List Board
    , threads : List Thread
    , comments : List Comment
    }


type Route
    = NotFoundRoute
    | TopRoute
    | SignupRoute
    | LoginRoute
    | BoardRoute String
    | ThreadRoute Id


type ApiPath
    = LoginPath
    | SignupPath
    | LogoutPath
    | BoardsPath
    | BoardPath String
    | ThreadPath Id
    | ThreadCommentsPath Id (Maybe Int) (Maybe Int)
    | CreateCommentPath Id


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


type alias CommentForm =
    { content : String
    , format : Format
    }



---- Backchanneling Model ----


type alias Id =
    Int


type alias User =
    { name : String
    , email : String
    , tags : List Id
    }


type alias Board =
    { id : Id
    , name : String
    , description : String
    , threads : List Id
    , tags : List Id
    }


type alias Thread =
    { id : Id
    , title : String
    , comments : List Id
    , since : DateTime
    , lastUpdated : DateTime
    , commentCount : Int -- 'resnum' in back-channeling
    , tags : List Id
    }


type alias Comment =
    { id : Id
    , content : String
    , postedAt : DateTime
    , postedBy : User
    , format : Format
    , index : Int -- 'no' in back-channeling
    }


type alias Tag =
    { name : String
    , description : String
    , isPrivate : Bool
    , prioity : Int
    , color : TagColors
    , owners : List Id
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
    | SetSignupForm SignupForm
    | SetLoginForm LoginForm
    | SetCommentForm CommentForm
    | Signup
    | OkSignup ( String, String )
    | Login
    | OkLogin ( String, String )
    | Logout
    | OkLogout
    | PostComment Id
    | OkComment Id
    | GetBoards (List Board)
    | GetBoard Board (List Thread)
    | GetThreadComments Id (List Comment)
      -- | GetIdentity ( String, String )
    | Unauthenticated
    | NoHandle String
