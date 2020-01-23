module Structure exposing (Layout, StaticPage, StaticView, Template)

import Head
import Html.Styled exposing (Html)
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Responsive exposing (ResponsiveStyle)


type alias SiteMetaData =
    List ( PagePath Pages.PathKey, Metadata )


type alias Page =
    { path : PagePath Pages.PathKey, frontmatter : Metadata }


type alias StaticPage msg model =
    { head : List (Head.Tag Pages.PathKey)
    , view : model -> Html msg -> StaticView msg
    }


type alias StaticView msg =
    { title : String
    , body : Html msg
    }


type alias Template msg model =
    ResponsiveStyle -> SiteMetaData -> Page -> StaticPage msg model


type alias Layout msg model =
    Template msg model -> Template msg model
