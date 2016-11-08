module Soundcloud exposing (fetchEmbedCode, view, config)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Http exposing (post, Error)
import Task exposing (Task)
import String exposing (..)
import Regex exposing (..)
import Result exposing (..)


oembedUrl = "http://soundcloud.com/oembed"

type Config msg = Config { url : String }

config : { url : String } -> Config msg
config { url } = Config { url = url}
fetchEmbedCode : String -> Task Error String
fetchEmbedCode url =
  let
    bodyData =
      Http.multipart [ Http.stringData "format" "json", Http.stringData "url" url]
    in
    Http.post decodeEmbedData oembedUrl bodyData

decodeEmbedData : Json.Decoder String
decodeEmbedData =
  Json.customDecoder (Json.at ["html"] Json.string) getSrcFromOEmbed

view : Config msg -> Html msg
view (Config { url }) =
    div [] [ iframe [Html.Attributes.src url] [] ]

getSrcFromOEmbed : String -> Result String String
getSrcFromOEmbed str =
  let
    matcher =
      regex "src=\"(.*)\""
    matches =
      List.head (find (AtMost 1) matcher str)
    in
      Result.fromMaybe "No src found in response" matches `andThen` getFirstSubmatch `andThen` getSubmatchValue


getFirstSubmatch : Regex.Match -> Result String (Maybe String)
getFirstSubmatch match =
  fromMaybe "No submatches found" (List.head match.submatches)

getSubmatchValue : Maybe String -> Result String String
getSubmatchValue submatch =
  fromMaybe "Submatch src had no value" submatch
