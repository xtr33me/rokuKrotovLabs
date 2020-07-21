Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "playContentWithAds" 
    m.top.id = "PlayerTask"
end sub

sub playContentWithAds()
	adUrl = "http://devtools.web.roku.com/samples/sample.xml"
	keepPlaying = true

	video = m.top.video

	' view is the node under which RAF should display its UI
	view = video.getParent() 

	m.adIface = Roku_Ads() 'RAF initialize
	m.adIface.enableAdMeasurements(true)
	m.adIface.setContentGenre("Entertainment")
	m.adIface.setContentId("CsAdSample")
	m.adIface.setContentLength(194)

	m.adIface.SetDebugOutput(true) 'for debug purpose
	m.adIface.SetAdPrefs(false)
	m.adIface.SetAdURL(adUrl)

	m.adPods = m.adIface.GetAds()

	if m.adPods <> invalid and m.adPods.count() > 0
		keepPlaying = m.adIface.showAds(m.adPods, invalid, view)
	end if

	'Lets test setting up a port for events'
	port = CreateObject("roMessagePort")
	if keepPlaying then
		video.observeField("position", port)
        video.observeField("state", port)
        video.visible = true
        video.control = "play"
        video.setFocus(true) 
	end if
	
	m.adPods = invalid
	currentPos = 0

	while keepPlaying
        msg = wait(0, port)

        if type(msg) = "roSGNodeEvent"

            if msg.GetField() = "position" then
                ' Keep track of the current position
                currentPosition = msg.GetData() 
     
            else if msg.GetField() = "state" then
                ' Save current state
                curState = msg.GetData()
                print "PlayerTask: state = "; curState
                
                ' If current state is stopped, try to play an AdPod if there is one
                if curState = "stopped" then
                    if m.adPods = invalid or m.adPods.count() = 0 then 
                        exit while
                    end if

                    ' If we should keep playing, resume playback of the content
                    if keepPlaying then
                        print "PlayerTask: mid-roll finished, seek to "; stri(currentPosition)
                        video.visible = true
                        video.seek = currentPosition
                        video.control = "play"
                        video.setFocus(true) 'important: take the focus back (RAF took it above)
                    end if
                        
                else if curState = "finished" then
                    print "PlayerTask: main content finished"

                    if m.adPods = invalid or m.adPods.count() = 0 then 
                        exit while
                    end if

                    print "PlayerTask: has postroll ads"
                    isPlayingPostroll = true

                    ' Stop the video, the post-roll would show when the state changes to  "stopped" (above)
                    video.control = "stop"                    
                end if

            end if

        end if

    end while
	'myContentNode = createObject("roSgNode", "ContentNode")
    'myContentNode.url = video.content.URL    
    'myContentNode.streamFormat = video.content.STREAMFORMAT

    'csasStream = m.adIface.constructStitchedStream(myContentNode, m.adPods)
    'm.adIface.renderStitchedStream(csasStream, view)
    'm.video.control = "play"
  	
    'm.adIface.showAds(m.adPods, invalid, view)
    print "PlayerTask: exiting playContentWithAds()"
end sub