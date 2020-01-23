module Templates.Wrapped exposing (view)

import Colors
import Css
import Date
import Grid
import Head
import Head.Seo as Seo
import Html.Styled exposing (Html, div, form, h1, h4, img, label, p, pre, span, styled, text, toUnstyled)
import Html.Styled.Attributes exposing (id)
import Html.Styled.Events exposing (onClick, onInput)
import Html.Styled.Lazy exposing (lazy2)
import Http
import Json.Decode as Decode
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.PagePath as PagePath exposing (PagePath)
import Responsive
import State exposing (Model, Msg(..))
import Structure exposing (StaticPage, StaticView, Template)
import Styles exposing (lg, md, sm, xl)
import TheSett.Buttons as Buttons
import TheSett.Cards as Cards
import TheSett.Laf as Laf exposing (devices)
import TheSett.Textfield as Textfield


view : Template Msg Model
view responsiveStyle siteMetadata page =
    { head = head page.frontmatter
    , view =
        \model contentView ->
            { title = title page.frontmatter
            , body =
                styled div
                    [ Laf.wrapper devices ]
                    []
                    [ pageView siteMetadata page model contentView ]
            }
    }


head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        Metadata.Page meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "elm-pages-starter"
                , image =
                    { url = images.iconPng
                    , alt = "elm-pages logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website

        Metadata.Article meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "elm-pages starter"
                , image =
                    { url = meta.image
                    , alt = meta.description
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.description
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.article
                    { tags = []
                    , section = Nothing
                    , publishedTime = Just (Date.toIsoString meta.published)
                    , modifiedTime = Nothing
                    , expirationTime = Nothing
                    }

        Metadata.Author meta ->
            let
                ( firstName, lastName ) =
                    case meta.name |> String.split " " of
                        [ first, last ] ->
                            ( first, last )

                        [ first, middle, last ] ->
                            ( first ++ " " ++ middle, last )

                        [] ->
                            ( "", "" )

                        _ ->
                            ( meta.name, "" )
            in
            Seo.summary
                { canonicalUrlOverride = Nothing
                , siteName = "elm-pages-starter"
                , image =
                    { url = meta.avatar
                    , alt = meta.name ++ "'s elm-pages articles."
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.bio
                , locale = Nothing
                , title = meta.name ++ "'s elm-pages articles."
                }
                |> Seo.profile
                    { firstName = firstName
                    , lastName = lastName
                    , username = Nothing
                    }

        Metadata.BlogIndex ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "elm-pages"
                , image =
                    { url = images.iconPng
                    , alt = "elm-pages logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = "elm-pages blog"
                }
                |> Seo.website


siteTagline : String
siteTagline =
    "Starter blog for elm-pages"


title : Metadata -> String
title frontmatter =
    case frontmatter of
        Metadata.Page metadata ->
            metadata.title

        Metadata.Article metadata ->
            metadata.title

        Metadata.Author author ->
            author.name

        Metadata.BlogIndex ->
            "elm-pages blog"


pageView :
    List ( PagePath Pages.PathKey, Metadata )
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Model
    -> Html Msg
    -> Html Msg
pageView siteMetadata page model viewForPage =
    case page.frontmatter of
        Metadata.Page metadata ->
            viewForPage

        Metadata.Article metadata ->
            viewForPage

        Metadata.Author author ->
            viewForPage

        Metadata.BlogIndex ->
            --, Index.view siteMetadata
            div [] []
