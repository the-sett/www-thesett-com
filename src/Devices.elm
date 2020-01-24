module Devices exposing (devices)

import Responsive exposing (Device(..), DeviceProps, ResponsiveStyle)
import TypeScale exposing (majorThird)



-- Device Configurations


sm : DeviceProps
sm =
    { device = Sm
    , baseFontSize = 14.0
    , breakWidth = 480
    , wrapperWidth = 480
    }


md : DeviceProps
md =
    { device = Md
    , baseFontSize = 15.0
    , breakWidth = 768
    , wrapperWidth = 760
    }


lg : DeviceProps
lg =
    { device = Lg
    , baseFontSize = 16.0
    , breakWidth = 992
    , wrapperWidth = 820
    }


xl : DeviceProps
xl =
    { device = Xl
    , baseFontSize = 17.0
    , breakWidth = 1200
    , wrapperWidth = 880
    }


{-| The responsive device configuration.
-}
devices : ResponsiveStyle
devices =
    { commonStyle =
        { lineHeightRatio = 1.4
        , typeScale = majorThird
        }
    , deviceStyles =
        { sm = sm
        , md = md
        , lg = lg
        , xl = xl
        }
    }
