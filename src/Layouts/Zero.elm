module Layouts.Zero exposing (layout)

import Css
import Grid
import Html.Styled exposing (Html, a, button, div, input, li, nav, node, styled, text, ul)
import Html.Styled.Attributes exposing (attribute, checked, class, href, id, type_)
import Html.Styled.Events exposing (onClick)
import Responsive exposing (ResponsiveStyle)
import State exposing (Model, Msg(..))
import Structure exposing (Layout, Template)
import Styles exposing (md, sm)
import Svg.Styled
import TheSett.Laf as Laf exposing (wrapper)
import TheSett.Logo as Logo


layout : Layout Msg Model
layout template =
    template
