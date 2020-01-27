module Markdown exposing (..)

import Html
import Html.Attributes as Attr
import Html.Styled exposing (Html, div, form, h1, h4, img, label, p, pre, span, styled, text, toUnstyled)
import Markdown.Block exposing (Block)
import Markdown.Html
import Markdown.Parser exposing (Renderer)
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
                Html.img [ Attr.src src, Attr.style "width" "100%" ] [ Html.text alt ] |> Ok
    }


defaultHtmlRenderer : Renderer (Html.Html msg)
defaultHtmlRenderer =
    { heading =
        \{ level, children } ->
            case level of
                1 ->
                    Html.h1 [] children

                2 ->
                    Html.h2 [] children

                3 ->
                    Html.h3 [] children

                4 ->
                    Html.h4 [] children

                5 ->
                    Html.h5 [] children

                6 ->
                    Html.h6 [] children

                _ ->
                    Html.text "TODO maye use a type here to clean it up... this will never happen"
    , raw = Html.p []
    , bold =
        \content -> Html.strong [] [ Html.text content ]
    , italic =
        \content -> Html.em [] [ Html.text content ]
    , code =
        \content -> Html.code [] [ Html.text content ]
    , link =
        \link content ->
            Html.a [ Attr.href link.destination ] content
                |> Ok
    , image =
        \image content ->
            Html.img [ Attr.src image.src ] [ Html.text content ]
                |> Ok
    , plain =
        Html.text
    , unorderedList =
        \items ->
            Html.ul []
                (items
                    |> List.map
                        (\itemBlocks ->
                            Html.li []
                                itemBlocks
                        )
                )
    , orderedList =
        \startingIndex items ->
            Html.ol
                (if startingIndex /= 1 then
                    [ Attr.start startingIndex ]

                 else
                    []
                )
                (items
                    |> List.map
                        (\itemBlocks ->
                            Html.li []
                                itemBlocks
                        )
                )
    , html = Markdown.Html.oneOf []
    , codeBlock =
        \{ body, language } ->
            Html.pre []
                [ Html.code []
                    [ Html.text body
                    ]
                ]
    , thematicBreak = Html.hr [] []
    }
