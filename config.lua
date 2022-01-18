Config = {}
Config.Client = {}
Config.Server = {}

-- Server config settings.


-- Client config settings.

-- Configurable controls
Config.Client.ToggleControl        = `INPUT_PHOTO_MODE_PC`                     -- F6
Config.Client.IncreaseSpeedControl = {`INPUT_CREATOR_LT`, `INPUT_PREV_WEAPON`} -- Page Up, Middle Wheel Up
Config.Client.DecreaseSpeedControl = {`INPUT_CREATOR_RT`, `INPUT_NEXT_WEAPON`} -- Page Down, Middle Wheel Down
Config.Client.UpControl            = `INPUT_JUMP`                              -- Spacebar
Config.Client.DownControl          = `INPUT_SPRINT`                            -- Shift
Config.Client.ForwardControl       = `INPUT_MOVE_UP_ONLY`                      -- W
Config.Client.BackwardControl      = `INPUT_MOVE_DOWN_ONLY`                    -- S
Config.Client.LeftControl          = `INPUT_MOVE_LEFT_ONLY`                    -- A
Config.Client.RightControl         = `INPUT_MOVE_RIGHT_ONLY`                   -- D
Config.Client.ToggleModeControl    = `INPUT_COVER`                             -- Q
Config.Client.FollowCamControl     = `INPUT_MULTIPLAYER_PREDATOR_ABILITY`      -- H

-- Maximum speed
Config.Client.MaxSpeed = 10.0

-- Minimum speed
Config.Client.MinSpeed = 0.1

-- How much speed increases by when speed up/down controls are pressed
Config.Client.SpeedIncrement = 0.1

-- Default speed
Config.Client.Speed = 0.1

-- Whether to enable relative mode by default.
--
-- false: Movement is based on the cardinal directions.
-- 	W = North
-- 	S = South
-- 	A = East
-- 	D = West
--
-- true: Movement is based on the current heading.
-- 	W = forward
-- 	S = backwards
-- 	A = rotate left
-- 	D = rotate right
--
Config.Client.RelativeMode = true

-- Whether to enable follow cam mode by default.
Config.Client.FollowCam = true
