module State exposing (Model, Msg(..))

import TheSett.Laf as Laf


type alias Model =
    { laf : Laf.Model
    , debug : Bool
    }


type Msg
    = PageChanged
    | LafMsg Laf.Msg
