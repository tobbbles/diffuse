module UI.Core exposing (Flags, Model, Msg(..))

import Alien
import Browser
import Browser.Navigation as Nav
import Common exposing (Switch(..))
import File exposing (File)
import Json.Encode as Json
import Queue
import Time
import UI.Authentication as Authentication
import UI.Backdrop as Backdrop
import UI.Page exposing (Page)
import UI.Queue.Core as Queue
import UI.Sources as Sources
import UI.Tracks.Core as Tracks
import Url exposing (Url)



-- ⛩


type alias Flags =
    { initialTime : Int
    , viewport : Viewport
    }



-- 🌳


type alias Model =
    { currentTime : Time.Posix
    , isAuthenticated : Bool
    , isLoading : Bool
    , navKey : Nav.Key
    , page : Page
    , url : Url
    , viewport : Viewport

    -----------------------------------------
    -- Audio
    -----------------------------------------
    , audioDuration : Float
    , audioHasStalled : Bool
    , audioIsLoading : Bool
    , audioIsPlaying : Bool

    -----------------------------------------
    -- Children
    -----------------------------------------
    , authentication : Authentication.Model
    , backdrop : Backdrop.Model
    , queue : Queue.Model
    , sources : Sources.Model
    , tracks : Tracks.Model
    }


type alias Viewport =
    { height : Float
    , width : Float
    }



-- 📣


type Msg
    = Bypass
    | LoadEnclosedUserData Json.Value
    | LoadHypaethralUserData Json.Value
    | SetCurrentTime Time.Posix
    | ToggleLoadingScreen Switch
      -----------------------------------------
      -- Audio
      -----------------------------------------
    | Pause
    | Play
    | Seek Float
    | SetAudioDuration Float
    | SetAudioHasStalled Bool
    | SetAudioIsLoading Bool
    | SetAudioIsPlaying Bool
    | Unstall
      -----------------------------------------
      -- Brain
      -----------------------------------------
    | ProcessSources
    | SaveEnclosedUserData
    | SaveFavourites
    | SaveSources
    | SaveTracks
    | SignOut
      -----------------------------------------
      -- Children
      -----------------------------------------
    | AuthenticationMsg Authentication.Msg
    | BackdropMsg Backdrop.Msg
    | QueueMsg Queue.Msg
    | SourcesMsg Sources.Msg
    | TracksMsg Tracks.Msg
      -----------------------------------------
      -- Children, Pt. 2
      -----------------------------------------
    | ActiveQueueItemChanged (Maybe Queue.Item)
    | FillQueue
      -----------------------------------------
      -- Import / Export
      -----------------------------------------
    | Export
    | Import File
    | ImportJson String
    | RequestImport
      -----------------------------------------
      -- URL
      -----------------------------------------
    | ChangeUrlUsingPage Page
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url
