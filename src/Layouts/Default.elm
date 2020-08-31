module Layouts.Default exposing (layout)

import Css
import Grid
import Html.Styled exposing (Html, a, button, div, form, input, li, nav, node, styled, text, ul)
import Html.Styled.Attributes exposing (attribute, checked, class, href, id, type_)
import Html.Styled.Events exposing (onClick, onInput)
import Responsive exposing (ResponsiveStyle)
import State exposing (Model, Msg(..))
import Structure exposing (Layout, Template)
import Styles exposing (md, sm)
import Svg.Styled
import TheSett.Colors as Colors
import TheSett.Laf as Laf exposing (wrapper)
import TheSett.Logo as Logo
import TheSett.Textfield as Textfield
import TheSett.TopHeader as TopHeader


layout : Layout Msg Model
layout template =
    \devices siteMetadata page ->
        let
            { head, view } =
                template devices siteMetadata page
        in
        { head = head
        , view =
            \model contentView ->
                let
                    { title, body } =
                        view model contentView
                in
                { title = title
                , body =
                    div
                        []
                        [ TopHeader.topHeader devices
                        , body
                        , footer devices
                        ]
                }
        }


footer : ResponsiveStyle -> Html msg
footer devices =
    node "footer" [ class "thesett-footer mdl-mega-footer" ] []
