REM PJLink BrightSign Plugin by Tweaklab
REM V1.00

Function PJLinkOff_Initialize(msgPort As Object, userVariables As Object, o As Object)
	print "PJLinkOff_Initialize - entry"
      	PJLinkOffBuilder = newPJLinkOffBuilder(msgPort, userVariables)
      	return PJLinkOffBuilder
End Function

Function newPJLinkOffBuilder(msgPort As Object, userVariables As Object)
      	PJLinkOffBuilder = { }
      	PJLinkOffBuilder.msgPort = msgPort
      	PJLinkOffBuilder.userVariables = userVariables
      	PJLinkOffBuilder.ProcessEvent = PJLinkOff_ProcessEvent
      	return PJLinkOffBuilder
End Function


Function PJLinkOff_ProcessEvent(event As Object)
      	print "PJLinkOff_ProcessEvent:"
      	print "Type of message is ";type(m)
      	print "Type of event is ";type(event)

 REM set standard PJLink port 4352
 REM define the message "%1POWR 0" in HEX to power OFF the projector

	projector_port=4352
	projector_message$="2531504F575220300D0A"

      	if type(event) = "roAssociativeArray" then
          	if type(event["EventType"]) = "roString"
              		if event["EventType"] = "SEND_PLUGIN_MESSAGE" then
				if event["PluginName"] = "PJLinkOff" then
                      			pluginMessage$ = event["PluginMessage"]
                      			print "Received pluginMessage ";pluginMessage$
					projector_ip$ = pluginMessage$
					print"Connecting to projector at "; projector_ip$ ":"; projector_port
					sock=CreateObject("roTCPStream")
					if sock=invalid then
						print"Failed to create roTCPClient object"
						stop
					endif
					if sock.ConnectTo(projector_ip$, projector_port) then
						print"Connected"
						bytes = CreateObject("roByteArray")
						sleep(500)
						bytes.FromHexString(projector_message$)
						print "Sending PJLink message: "; projector_message$
						sock.SendBlock(bytes)
						return true
					else
						print"Failed to connect to projector"
						sock=invalid
					endif
				endif
			endif
		endif
	endif

	return false
End Function
