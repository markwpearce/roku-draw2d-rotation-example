sub main()
  ' Load PNG files
  clockFaceBmp = CreateObject("roBitmap", "pkg:/images/clockface.png")
  hourHandBmp = CreateObject("roBitmap", "pkg:/images/hourhand.png")
  minuteHandBmp = CreateObject("roBitmap", "pkg:/images/minutehand.png")
  secondHandBmp = CreateObject("roBitmap", "pkg:/images/secondhand.png")

  ' Load Audio files for the ticks and tocks
  tickSound = CreateObject("roAudioResource", "pkg:/sounds/tick.wav")
  tockSound = CreateObject("roAudioResource", "pkg:/sounds/tock.wav")

  ' Make an roRegion out of the Bitmap
  hourHandRegion = CreateObject("roRegion", hourHandBmp, 0, 0, 36, 240)
  ' Set the Pre-translation, which is only possible on an roRegion
  ' This a translation of the image so the anchor point/rotation point is at (0,0)
  ' In this case, set the rotation point to the middle of "ring" at the end of each clock hand
  ' For the hour hand image, that point is at (16, 181), so pre-translate the opposite: -16, -181
  hourHandRegion.SetPretranslation(-16, -181)

  ' Do the same for the minute hand
  minuteHandRegion = CreateObject("roRegion", minuteHandBmp, 0, 0, 36, 240)
  minuteHandRegion.SetPretranslation(-17, -224)

  ' Do the same for the second hand
  secondHandRegion = CreateObject("roRegion", secondHandBmp, 0, 0, 20, 280)
  secondHandRegion.SetPretranslation(-9, -262)

  ' Make the screen object to draw to
  screen = CreateObject("roScreen", true, 1280, 720)
  screen.setAlphaEnable(true)

  ' Add a message port to the screen so we can listen for input
  inputPort = CreateObject("roMessagePort")
  screen.setMessagePort(inputPort)

  while true
    ' Check if there was any input
    inputMsg = inputPort.GetMessage()
    if type(inputMsg) = "roUniversalControlEvent"
      ' Exit on any remote control key press
      exit while
    end if

    ' Clear the screen to black
    screen.clear(256)
    ' Add the clock face
    screen.drawScaledObject(340, 60, 0.5, 0.5, clockFaceBmp)

    ' Get the current time
    date = CreateObject("roDateTime")
    date.toLocalTime()
    seconds = date.getSeconds()
    ' Use float values for minutes & hours so they move on each second
    minutes = date.getMinutes() + seconds / 60
    hours = date.getHours() mod 12 + minutes / 60

    ' Add the hour hand
    ' Rotate it based on the time
    ' Draw it at the center, because it was pre-translated
    screen.DrawRotatedObject(640, 360, hoursToDegrees(hours), hourHandRegion)
    ' Add the minute hand
    screen.DrawRotatedObject(640, 360, minutesOrSecondsToDegrees(minutes), minuteHandRegion)
    ' Add the second hand
    screen.DrawRotatedObject(640, 360, minutesOrSecondsToDegrees(seconds), secondHandRegion)
    ' Swap buffers to draw the screen object
    screen.swapBuffers()

    ' Play a tick or tock sound at 80% volume
    if seconds mod 2 = 0
      tickSound.trigger(80)
    else
      tockSound.trigger(80)
    end if

    ' Wait a second
    sleep(1000)
  end while
end sub

' Converts a minutes or seconds value to the correct rotation in degrees for a clock hand
' Returns a negative value, because positive rotation is counter-clockwise
'
' @param {float} minutesOrSeconds the time value the clock hand has
' @return {float} rotation in degrees
function minutesOrSecondsToDegrees(minutesOrSeconds as float) as float
  return -minutesOrSeconds * 6.0
end function

' Converts an hours value to the correct rotation in degrees for a clock hand
' Returns a negative value, because positive rotation is counter-clockwise
'
' @param {float} hours the time value the clock hand has
' @return {float} rotation in degrees
function hoursToDegrees(hours as float) as float
  return -hours * 30
end function
