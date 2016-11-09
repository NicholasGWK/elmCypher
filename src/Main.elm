import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as Html
import Http
import Task
import Json.Decode exposing (Decoder, int, string, list, object3, maybe, (:=))
import Soundcloud exposing (fetchEmbedCode)
--- Model

type Msg =
    FetchMoreTracksSucceed (List Track)
  | FetchMoreTracksFail Http.Error
  | NextTrack
  | FetchSrcSucceed String
  | FetchSrcFail Http.Error
  | NoOp


firebaseUrl = "https://cypher-72923.firebaseio.com/tracks.json"

type alias Model =
  { currentFetching : Bool
  , previous : List Track
  , current : Track
  , next : List Track
  }
type alias Track =
  { url : String
  , service : String
  , src : Maybe String
  }

trackDecoder : Decoder Track
trackDecoder = object3 Track
                ("url" := string)
                ("type" := string)
                (maybe ("src" := string))

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    noOp = (model, Cmd.none)
  in
    case msg of
      FetchMoreTracksSucceed urls ->
            ({ model | next = model.next ++ urls }, Cmd.none)
      FetchMoreTracksFail _ -> noOp
      FetchSrcSucceed src ->
        let
          current = model.current
          newCurrent = { current | src = Just src }
        in
          ( { model | current = newCurrent }, Cmd.none)
      FetchSrcFail _ -> noOp
      NoOp -> noOp
      NextTrack ->
        case model.next of
          first :: rest ->
            let
              prev = model.previous ++ (current :: [])
              current = first
              next = rest
            in
              case current.src of
                Just src ->
                  (Model False prev current next, Cmd.none)
                Nothing ->
                  (Model True prev current next, fetchSrc current.url)
          [] ->
            (model, fetchMoreTracks)


fetchMoreTracks : Cmd Msg
fetchMoreTracks =
  Task.perform FetchMoreTracksFail FetchMoreTracksSucceed (Http.get decodeTracks firebaseUrl )

fetchSrc : String -> Cmd Msg
fetchSrc url =
  Task.perform FetchSrcFail FetchSrcSucceed (fetchEmbedCode url)

decodeTracks : Decoder (List Track)
decodeTracks =
  Json.Decode.list trackDecoder
-- View
view : Model -> Html Msg
view model =
  let
    embed =
      case model.current.src of
        Just src ->
          Soundcloud.view src
        Nothing ->
          text (toString model.current)
  in
    div [] [ embed
           , button [onClick NextTrack ] [text "Next"]
           ]


-- Init

initModel =
  { previous = []
  , current = { url = ""
              , service = ""
              , src = Nothing
              }
  , next = []
  , currentFetching = False
  }

init : (Model, Cmd Msg)
init =
  ( initModel , fetchMoreTracks)

-- Subs

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

main =
  Html.program { init = init, update = update, view = view, subscriptions = subscriptions }
