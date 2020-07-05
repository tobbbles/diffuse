module UI.Adjunct exposing (..)

import Keyboard
import Maybe.Extra as Maybe
import Return
import Return.Ext as Return
import UI.Alfred.State as Alfred
import UI.Audio.State as Audio
import UI.Authentication.Types as Authentication
import UI.Interface.State exposing (hideOverlay)
import UI.Playlists.State as Playlists
import UI.Queue.State as Queue
import UI.Tracks.State as Tracks
import UI.Types as UI exposing (..)



-- 📣


keyboardInput : Keyboard.Msg -> Manager
keyboardInput msg model =
    (\m ->
        let
            skip =
                Return.singleton m

            authenticated =
                case model.authentication of
                    Authentication.Authenticated _ ->
                        True

                    _ ->
                        False
        in
        if not authenticated || (m.focusedOnInput && Maybe.isNothing model.alfred) then
            case m.pressedKeys of
                [ Keyboard.Escape ] ->
                    hideOverlay m

                _ ->
                    skip

        else if Maybe.isJust model.alfred then
            case m.pressedKeys of
                [ Keyboard.ArrowDown ] ->
                    Alfred.selectNext m

                [ Keyboard.ArrowUp ] ->
                    Alfred.selectPrevious m

                [ Keyboard.Enter ] ->
                    Alfred.runSelectedAction m

                [ Keyboard.Escape ] ->
                    hideOverlay m

                _ ->
                    skip

        else
            case m.pressedKeys of
                [ Keyboard.ArrowLeft ] ->
                    Queue.rewind m

                [ Keyboard.ArrowRight ] ->
                    Queue.shift m

                [ Keyboard.ArrowUp ] ->
                    Audio.seek ((m.audioPosition - 10) / m.audioDuration) m

                [ Keyboard.ArrowDown ] ->
                    Audio.seek ((m.audioPosition + 10) / m.audioDuration) m

                [ Keyboard.Character "L" ] ->
                    Playlists.assistWithSelectingPlaylist m

                [ Keyboard.Character "N" ] ->
                    Tracks.scrollToNowPlaying m

                [ Keyboard.Character "P" ] ->
                    Audio.playPause m

                [ Keyboard.Character "R" ] ->
                    Queue.toggleRepeat m

                [ Keyboard.Character "S" ] ->
                    Queue.toggleShuffle m

                [ Keyboard.Escape ] ->
                    hideOverlay m

                _ ->
                    skip
    )
        { model | pressedKeys = Keyboard.update msg model.pressedKeys }