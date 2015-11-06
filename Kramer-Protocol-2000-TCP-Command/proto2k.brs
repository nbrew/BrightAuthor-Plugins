' Kramer Protocol 2000 plugin - proto2k
' v0.0.1

Function proto2k_Initialize(msgPort As Object, userVariables As Object, bsp as Object)
  print "proto2k_Initialize - entry"

  proto2k = newproto2k(msgPort, userVariables, bsp)

  return proto2k
End Function

Function newproto2k(msgPort As Object, userVariables As Object, bsp As Object)
  ' print "newproto2k"
  s = {}
  s.msgPort        = msgPort
  s.userVariables  = userVariables
  s.bsp            = bsp
  s.ProcessEvent   = proto2k_ProcessEvent

  s.ip$   = "192.168.1.39"
  s.port  = 5000
  s.debug = true

  ' set IP address from user variables
  if userVariables.DoesExist("proto2k_ip") then
    myvariable = userVariables.Lookup("proto2k_ip")
    if myvariable <> invalid then
      s.ip$ = myvariable.GetCurrentValue()
      s.bsp.diagnostics.printdebug("set proto2k ip address: " + s.ip$)
    endif
  endif

  ' set port
  if userVariables.DoesExist("proto2k_port") then
    myvariable = userVariables.Lookup("proto2k_port")
    if myvariable <> invalid then
      s.port = myvariable.GetCurrentValue()
      s.bsp.diagnostics.printdebug("set proto2k port: "+s.port)
    endif
  endif

  return s
End Function

Function proto2k_ProcessEvent(event As Object) as boolean
  ' print "proto2k_ProcessEvent"
  ' print "  type of message is: ";type(m)
  ' print "  type of event is: ";type(event)
  retval = false

  if type(event) = "roAssociativeArray" then
    if type(event["EventType"]) = "roString" then
      if event["EventType"] = "SEND_PLUGIN_MESSAGE" then
        if event["PluginName"] = "proto2k" then
          pluginMessage$ = event["PluginMessage"]
          print "SEND_PLUGIN/EVENT_MESSAGE:";pluginMessage$
          messageToParse$ = event["PluginName"]+"!"+pluginMessage$
          retval = proto2k_ParsePluginMsg(messageToParse$, m)
        endif
      endif
    endif
  elseif type(event) = "roDatagramEvent" then
    ' UDP Datagrams for proto2k!<command>
    msg$ = event
    if (left(msg$,6) = "proto2k") then
      retval = proto2k_ParsePluginMsg(msg$, m)
    endif
  endif

  return retval
End Function

Function proto2k_ParsePluginMsg(msg As string, s As Object) as boolean
  print "proto2k_ParsePluginMsg"
  retval = false

  r = CreateObject("roRegex", "^proto2k", "i")
  match = r.IsMatch(msg)
  if match then
    retval = true
    command = ""

    r2        = CreateObject("roRegex", "!", "i")
    fields    = r2.split(msg)
    numFields = fields.Count()
    if (numFields < 2) or (numFields > 2) then
      s.bsp.diagnostics.printdebug("proto2k Incorrect number of fields for command:"+msg)
      return retval
    else
      r2 = CreateObject("roRegex", " ", "i")
      fields    = r2.split(fields[1])
      numFields = fields.Count()

      if fields[0] = "recall_preset" then
        if numFields < 2 or numFields > 3 then
          s.bsp.diagnostics.printdebug("proto2k Error: Number of fields for recall_preset must be 2 or 3."+fields[1])
          return retval
        endif

        command ="04p80m0D0A"
        presetNum  = Str(80 + StrToI(fields[1])).Trim()

        ' Set (optional) machine number
        if numFields = 3 then
          machineNum = Str(80 + StrToI(fields[2])).Trim()
        else
          machineNum = "81"
        endif

        r2 = CreateObject("roRegex", "p", "i")
        command = r2.Replace(command, presetNum)
        r2 = CreateObject("roRegex", "m", "i")
        command = r2.Replace(command, machineNum)

      elseif fields[0] = "switch_video" then
        if numFields < 3 or numFields > 4 then
          s.bsp.diagnostics.printdebug("proto2k Error: Number of fields for recall_preset must be 2 or 3."+fields[1])
          return retval
        endif
        command = "01iom"
        input  = Str(80 + StrToI(fields[1])).Trim()
        output = Str(80 + StrToI(fields[2])).Trim()
        if numFields = 3 then
          machineNum = Str(80 + StrToI(fields[3])).Trim()
        else
          machineNum = "81"
        endif

        r2 = CreateObject("roRegex", "i", "i")
        command = r2.Replace(command, input)
        r2 = CreateObject("roRegex", "o", "i")
        command = r2.Replace(command, output)
        r2 = CreateObject("roRegex", "m", "i")
        command = r2.Replace(command, machineNum)
      '
      ' else
      '   ' append %1 and \r\n to the command
      '   ba = CreateObject("roByteArray")
      '   ba.FromAsciiString("%1" + fields[1] + Chr(13) + Chr(10))
      '   command = ba.ToHexString()
      endif
    endif
    ' s.bsp.diagnostics.printdebug("proto2k command found: " +command)
    print "proto2k command assigned: ";command
    retval = proto2k_Send(command, s)
  endif

  return retval
End Function

Function proto2k_Send(hex_msg as string, s As Object) as boolean
  print "Connecting to kramer at ";s.ip$;":";s.port

  sock=CreateObject("roTCPStream")
  if sock=invalid then
    print "Failed to create roTCPClient object"
    stop
  endif

  if sock.ConnectTo(s.ip$, s.port) then
    print "Connected"
    sleep(500)

    bytes = CreateObject("roByteArray")
    bytes.FromHexString(hex_msg)
    print "Sending proto2k message: ";hex_msg
    sock.SendBlock(bytes)
    return true
  else
    print "Failed to connect to kramer"
    sock = invalid
  endif

  return false
End Function
