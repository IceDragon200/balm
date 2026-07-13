max_line_length = 200

-- unused args do not matter
unused_args = false

globals = {
  love = {
    fields = {
      -- Headless
      activeFont = {},
      --
      load = {},
      update = {},
      draw = {},
      conf = {},
      filesystem = {
        fields = {
          getDirectoryItems = {},
          getInfo = {},
          newFile = {},
          read = {},
        }
      },
      image = {
        fields = {
          newImageData = {},
        }
      },
      graphics = {
        fields = {

          --
          -- Core
          --
          getSystemLimits = {},

          getWidth = {},
          getHeight = {},

          draw = {},
          push = {},
          pop = {},
          print = {},

          newImage = {},

          setColor = {},
          getColor = {},

          newFont = {},
          setFont = {},
          getFont = {},

          newSpriteBatch = {},
          newText = {},

          newQuad = {},

          setScissor = {},

          rectangle = {},
        }
      },

      timer = {
        fields = {
          getTime = {},
        },
      },
      --
      -- Input
      --
      touchmoved = {},
      touchpressed = {},
      touchreleased = {},
      mousemoved = {},
      mousepressed = {},
      mousereleased = {},
      keypressed = {},
      keyreleased = {},
      joystickaxis = {},
      joystickhat = {},
      joystickadded = {},
      joystickremoved = {},
      joystickpressed = {},
      joystickreleased = {},
      gamepadaxis = {},
      gamepadpressed = {},
      gamepadreleased = {},
    },
  },
}
