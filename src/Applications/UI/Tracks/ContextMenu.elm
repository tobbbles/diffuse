module UI.Tracks.ContextMenu exposing (cacheAction, trackMenu, viewMenu)

import Conditional exposing (ifThenElse)
import ContextMenu exposing (..)
import Coordinates exposing (Coordinates)
import Material.Icons as Icons
import Maybe.Extra as Maybe
import Playlists exposing (Playlist)
import Queue
import Sources exposing (Source)
import Time
import Tracks exposing (Grouping(..), IdentifiedTrack)
import UI.Queue as Queue
import UI.Reply exposing (Reply(..))
import UI.Tracks as Tracks



-- TRACK MENU


trackMenu :
    { cached : List String
    , cachingInProgress : List String
    , currentTime : Time.Posix
    , lastModifiedPlaylistName : Maybe String
    , selectedPlaylist : Maybe Playlist
    , showAlternativeMenu : Bool
    , sources : List Source
    }
    -> List IdentifiedTrack
    -> Coordinates
    -> ContextMenu Reply
trackMenu { cached, cachingInProgress, currentTime, selectedPlaylist, lastModifiedPlaylistName, showAlternativeMenu, sources } tracks =
    if showAlternativeMenu then
        [ temporaryUrlActions
            currentTime
            sources
            tracks
        ]
            |> List.concat
            |> ContextMenu

    else
        [ queueActions
            tracks

        --
        , playlistActions
            { selectedPlaylist = selectedPlaylist
            , lastModifiedPlaylistName = lastModifiedPlaylistName
            }
            tracks

        --
        , cacheAction
            { cached = cached
            , cachingInProgress = cachingInProgress
            }
            tracks
            |> List.singleton
        ]
            |> List.concat
            |> ContextMenu


cacheAction :
    { cached : List String, cachingInProgress : List String }
    -> List IdentifiedTrack
    -> ContextMenu.Item Reply
cacheAction { cached, cachingInProgress } tracks =
    case tracks of
        [ ( i, t ) as track ] ->
            if List.member t.id cached then
                Item
                    { icon = Icons.offline_bolt
                    , label = "Remove from cache"
                    , msg = RemoveTracksFromCache (List.map Tuple.second tracks)
                    , active = False
                    }

            else if List.member t.id cachingInProgress then
                Item
                    { icon = Icons.offline_bolt
                    , label = "Downloading ..."
                    , msg = Shunt
                    , active = True
                    }

            else
                Item
                    { icon = Icons.offline_bolt
                    , label = "Store in cache"
                    , msg = StoreTracksInCache (List.map Tuple.second tracks)
                    , active = False
                    }

        _ ->
            Item
                { icon = Icons.offline_bolt
                , label = "Store in cache"
                , msg = StoreTracksInCache (List.map Tuple.second tracks)
                , active = False
                }


playlistActions :
    { selectedPlaylist : Maybe Playlist
    , lastModifiedPlaylistName : Maybe String
    }
    -> List IdentifiedTrack
    -> List (ContextMenu.Item Reply)
playlistActions { selectedPlaylist, lastModifiedPlaylistName } tracks =
    let
        maybeCustomPlaylist =
            Maybe.andThen
                (\p -> ifThenElse p.autoGenerated Nothing (Just p))
                selectedPlaylist

        maybeAddToLastModifiedPlaylist =
            Maybe.andThen
                (\n ->
                    if Maybe.map .name selectedPlaylist /= Just n then
                        justAnItem
                            { icon = Icons.waves
                            , label = "Add to \"" ++ n ++ "\""
                            , msg =
                                AddTracksToPlaylist
                                    { playlistName = n, tracks = Tracks.toPlaylistTracks tracks }
                            , active = False
                            }

                    else
                        Nothing
                )
                lastModifiedPlaylistName
    in
    case maybeCustomPlaylist of
        -----------------------------------------
        -- In a custom playlist
        -----------------------------------------
        Just playlist ->
            Maybe.values
                [ justAnItem
                    { icon = Icons.waves
                    , label = "Remove from playlist"
                    , msg = RemoveFromSelectedPlaylist playlist tracks
                    , active = False
                    }
                , maybeAddToLastModifiedPlaylist
                , justAnItem
                    { icon = Icons.waves
                    , label = "Add to another playlist"
                    , msg = RequestAssistanceForPlaylists tracks
                    , active = False
                    }
                ]

        -----------------------------------------
        -- Otherwise
        -----------------------------------------
        _ ->
            Maybe.values
                [ maybeAddToLastModifiedPlaylist
                , justAnItem
                    { icon = Icons.waves
                    , label = "Add to playlist"
                    , msg = RequestAssistanceForPlaylists tracks
                    , active = False
                    }
                ]


queueActions : List IdentifiedTrack -> List (ContextMenu.Item Reply)
queueActions identifiedTracks =
    [ Item
        { icon = Icons.update
        , label = "Play next"
        , msg = AddToQueue { inFront = True, tracks = identifiedTracks }
        , active = False
        }
    , Item
        { icon = Icons.update
        , label = "Add to queue"
        , msg = AddToQueue { inFront = False, tracks = identifiedTracks }
        , active = False
        }
    ]


temporaryUrlActions : Time.Posix -> List Source -> List IdentifiedTrack -> List (ContextMenu.Item Reply)
temporaryUrlActions timestamp sources tracks =
    case tracks of
        [ ( i, t ) ] ->
            [ Item
                { icon = Icons.link
                , label = "Copy temporary url"
                , msg = CopyToClipboard (Queue.makeTrackUrl timestamp sources t)
                , active = False
                }
            ]

        _ ->
            []



-- VIEW MENU


viewMenu : Bool -> Maybe Grouping -> Coordinates -> ContextMenu Reply
viewMenu onlyCachedTracks maybeGrouping =
    ContextMenu
        [ groupByDirectory (maybeGrouping == Just Directory)
        , groupByFirstAlphaCharacter (maybeGrouping == Just FirstAlphaCharacter)
        , groupByProcessingDate (maybeGrouping == Just AddedOn)
        , groupByTrackYear (maybeGrouping == Just TrackYear)

        --
        , Item
            { icon = Icons.filter_list
            , label = "Cached tracks only"
            , active = onlyCachedTracks
            , msg = ToggleCachedTracksOnly
            }
        ]


groupByDirectory isActive =
    Item
        { icon = ifThenElse isActive Icons.clear Icons.library_music
        , label = "Group by directory"
        , active = isActive

        --
        , msg =
            if isActive then
                DisableTracksGrouping

            else
                GroupTracksBy Directory
        }


groupByFirstAlphaCharacter isActive =
    Item
        { icon = ifThenElse isActive Icons.clear Icons.library_music
        , label = "Group by first letter"
        , active = isActive

        --
        , msg =
            if isActive then
                DisableTracksGrouping

            else
                GroupTracksBy FirstAlphaCharacter
        }


groupByProcessingDate isActive =
    Item
        { icon = ifThenElse isActive Icons.clear Icons.library_music
        , label = "Group by processing date"
        , active = isActive

        --
        , msg =
            if isActive then
                DisableTracksGrouping

            else
                GroupTracksBy AddedOn
        }


groupByTrackYear isActive =
    Item
        { icon = ifThenElse isActive Icons.clear Icons.library_music
        , label = "Group by track year"
        , active = isActive

        --
        , msg =
            if isActive then
                DisableTracksGrouping

            else
                GroupTracksBy TrackYear
        }
