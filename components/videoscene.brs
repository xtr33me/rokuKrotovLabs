sub init()
  m.top.backgroundURI = "pkg:/images/cindalia_bg_hd.jpg"

  m.videolist = m.top.findNode("videoLabelList")
  m.videoinfo = m.top.findNode("infoLabel")
  m.videoposter = m.top.findNode("videoPoster")
  m.video = m.top.findNode("videoFrame")

  m.video.observeField("state", "controlvideoplay")

  m.readVideoContentTask = createObject("roSGNode", "ContentReader")
  m.readVideoContentTask.observeField("content", "showvideolist")
  
  m.readVideoContentTask.contenturi = "http://krotovlabs.com/media/videocontent.xml"
  m.readVideoContentTask.control = "RUN" 

  m.videolist.observeField("itemFocused", "setvideo")
  m.videolist.observeField("itemSelected", "playvideo")
end sub

sub showvideolist()
  m.videolist.content = m.readVideoContentTask.content
  m.videolist.setFocus(true)
end sub

sub setvideo()
  videocontent = m.videolist.content.getChild(m.videolist.itemFocused)
  m.videoposter.uri = videocontent.hdposterurl
  m.videoinfo.text = videocontent.description
  m.video.content = videocontent
end sub

sub playvideo()
  m.video.control = "play"
  m.video.visible = true
  m.video.setFocus(true)
end sub

sub controlvideoplay()
  if (m.video.state = "finished") 
    m.video.control = "stop"
    m.videolist.setFocus(true)
    m.video.visible = false
  end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then
    if key = "back"
      if (m.video.state = "playing")
        m.video.control = "stop"
        m.videolist.setFocus(true)
        m.video.visible = false

        return true
      end if
    end if
  end if

  return false
end function