module Markdown exposing (..)

import Html
import Html.Attributes
import Html.Styled exposing (Html, div, form, h1, h4, img, label, p, pre, span, styled, text, toUnstyled)
import Markdown.Block exposing (Block)
import Markdown.Html
import Markdown.Parser
import Metadata exposing (Metadata)
import Pages.Document


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata (Html msg) )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \markdownBody ->
                markdownBody
                    |> Markdown.Parser.parse
                    |> Result.mapError deadEndsToString
                    |> Result.andThen (Markdown.Parser.render markdownRenderer)
                    |> Result.map (Html.div [])
                    |> Result.map Html.Styled.fromUnstyled
        }


deadEndsToString deadEnds =
    deadEnds
        |> List.map Markdown.Parser.deadEndToString
        |> String.join "\n"


markdownRenderer : Markdown.Parser.Renderer (Html.Html msg)
markdownRenderer =
    let
        default =
            Markdown.Parser.defaultHtmlRenderer
    in
    { default
        | image =
            \{ src } alt ->
                Html.img [ Html.Attributes.src src, Html.Attributes.style "width" "100%" ] [ Html.text alt ] |> Ok
    }
