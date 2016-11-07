import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Http
import Task
import Json.Decode exposing (Decoder, int, string, list, object2, (:=))
import Soundcloud exposing (fetchEmbedCode, view)
--- Model

type Msg = FetchInitialUrls | InitialFetchSucceed (List Track) | FetchFail Http.Error

firebaseUrl = "https://cypher-72923.firebaseio.com/tracks.json"

type alias Model =
  { previous : List Track
  , current : Track
  , next : List Track
  }
type alias Track =
  { url: String
  , service: String
  }

trackDecoder : Decoder Track
trackDecoder = object2 Track
                ("url" := string)
                ("type" := string)

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
      FetchInitialUrls ->
        (model, fetchInitialUrls)

      InitialFetchSucceed urls ->
            case urls of
              first :: rest ->
                  ( { previous = model.previous, current = first, next = rest}, Cmd.none)
              _ ->
                ( model, Cmd.none)

      FetchFail _ ->
        (model, Cmd.none)

fetchInitialUrls =
  Task.perform FetchFail InitialFetchSucceed (Http.get decodeTracks firebaseUrl )

decodeTracks : Decoder (List Track)
decodeTracks =
  Json.Decode.list trackDecoder
-- View
view : Model -> Html Msg
view model =
  div [] [text (toString model.current)]


-- Init

init : (Model, Cmd Msg)
init =
  ( { previous = [], current = { url = "", service = "" }, next = [] } , fetchInitialUrls)

-- Subs

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

main =
  Html.program { init = init, update = update, view = view, subscriptions = subscriptions }
