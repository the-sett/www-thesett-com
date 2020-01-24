module Devices exposing (devices)

import Responsive exposing (Device(..), DeviceProps, ResponsiveStyle)
import TypeScale



-- Device Configurations


sm : DeviceProps
sm =
    { device = Sm
    , baseFontSize = 16.0
    , breakWidth = 480
    , wrapperWidth = 480
    }


md : DeviceProps
md =
    { device = Md
    , baseFontSize = 17.0
    , breakWidth = 768
    , wrapperWidth = 760
    }


lg : DeviceProps
lg =
    { device = Lg
    , baseFontSize = 18.0
    , breakWidth = 992
    , wrapperWidth = 820
    }


xl : DeviceProps
xl =
    { device = Xl
    , baseFontSize = 19.0
    , breakWidth = 1200
    , wrapperWidth = 880
    }


{-| The responsive device configuration.
-}
devices : ResponsiveStyle
devices =
    { commonStyle =
        { lineHeightRatio = 1.5
        , typeScale = TypeScale.minorThird
        }
    , deviceStyles =
        { sm = sm
        , md = md
        , lg = lg
        , xl = xl
        }
    }
