(* Application.applescript *)

(* ==== Event Handlers ==== *)
on clicked theObject
	(* start/stop button *)
	if name of the theObject is "startstop" then
		if serverrunning() is equal to 0 then
			startserver()
		else
			stopserver()
		end if
	else if name of theObject is "cancelupdate" then
		set the visible of window "updater" to 0
		set the visible of window "updating" to 0
		set the visible of window "main" to 1
	else if name of theObject is "openurl" then
		-- launch the browser with this URL
		set theHost to call method "myHostAddress" of class "HostLookup"
		set theURL to ("http://" & theHost & ":9000/")
		open location (theURL as string)
	else if name of theObject is "update" then
		if contents of text field "mac1" of window "updater" is equal to "" or Â
			contents of text field "mac2" of window "updater" is equal to "" or Â
			contents of text field "mac3" of window "updater" is equal to "" or Â
			contents of text field "mac4" of window "updater" is equal to "" or Â
			contents of text field "mac5" of window "updater" is equal to "" or Â
			contents of text field "mac6" of window "updater" is equal to "" or Â
			contents of text field "updateip" of window "updater" is equal to "" then
			display dialog "Please check the values of your SLIMP3 player's MAC and IP address and try again." buttons {"OK"}
		else
			set macAddress to contents of text field "mac1" of window "updater" & Â
				":" & contents of text field "mac2" of window "updater" & Â
				":" & contents of text field "mac3" of window "updater" & Â
				":" & contents of text field "mac4" of window "updater" & Â
				":" & contents of text field "mac5" of window "updater" & Â
				":" & contents of text field "mac6" of window "updater"
			
			set ipAddress to contents of text field "updateip" of window "updater"
			
			set updatescript to "\"" & (POSIX path of (path to me)) & Â
				"/Contents/server/firmware/update_firmware.pl\" " & macAddress & " " & ipAddress
			
			set the visible of window "updater" to 0
			set the visible of window "updating" to 1
			set failed to false
			try
				set result to do shell script (updatescript as string) with administrator privileges
			on error errText
				display dialog "Update failed: " & errText buttons {"Ok"}
				set failed to true
			end try
			if failed is equal to false then
				display dialog "Your SLIMP3 Player was successfully upgraded!" buttons {"Ok"}
			end if
			set the visible of window "updating" to 0
			set the visible of window "main" to 1
		end if
	end if
end clicked

on updatestatus()
	if serverrunning() is equal to 0 then
		set title of button "startstop" of window "main" to "Start"
		set contents of text field "statustext" of window "main" to "SLIMP3 Server Off"
		set enabled of button "openurl" of window "main" to 0
		set visible of text field "stoptext" of window "main" to 0
		set visible of text field "startinguptext" of window "main" to 0
		set visible of text field "starttext" of window "main" to 1
		set visible of image view "offIcon" of window "main" to 1 -- how do I address the offIcon
		call method "offIcon" of class "HostLookup"
		--		set myimage to call method "imageNamed:" of class "NSImage" with parameter "slimp3off"
	else
		set title of button "startstop" of window "main" to "Stop"
		set contents of text field "statustext" of window "main" to "SLIMP3 Server On"
		set enabled of button "openurl" of window "main" to 1
		set visible of text field "starttext" of window "main" to 0
		set visible of text field "startinguptext" of window "main" to 0
		set visible of text field "stoptext" of window "main" to 1
		set visible of image view "offIcon" of window "main" to 0 -- how do I address the offIcon
		call method "onIcon" of class "HostLookup"
		--		set myimage to call method "imageNamed:" of class "NSImage" with parameter "slimp3icon"
	end if
	--	call method "setApplicationIcon:" with parameter myimage
	update window "main"
end updatestatus

on serverrunning()
	set theResult to (do shell script "ps -ax | grep \"slimp3d\\|slimp3\\.pl\" | grep -v grep | cat")
	
	if theResult is equal to "" then
		set theResult to (do shell script "ps -ax | grep slimp3.pl | grep -v grep | cat")
	end if
	
	if theResult is not equal to "" then
		set thepid to the first word of theResult
		if thepid > 0 then
			return thepid
		end if
	end if
	return 0
end serverrunning

on startserver()
	--updatestatus()
	if serverrunning() is equal to 0 then
		set visible of text field "startinguptext" of window "main" to 1
		set visible of text field "starttext" of window "main" to 0
		set visible of text field "stoptext" of window "main" to 0
		update window "main"
		set mypath to path to me
		set serverpath to "cd '" & (POSIX path of mypath) & "/Contents/server'; ./slimp3.pl --daemon 2> /tmp/slimp3error.log"
		set theResult to do shell script serverpath as string
	end if
	updatestatus()
end startserver

on stopserver()
	--updatestatus()
	set thepid to serverrunning()
	if thepid is not equal to 0 then
		do shell script "kill " & thepid as string
	end if
	updatestatus()
end stopserver

on action theObject
	if name of theObject is "input" then
		set theResult to do shell script (contents of text field "input" of window "main") as string
		set the contents of text view "output" of scroll view "output" of window "main" to theResult
		set needs display of text view "output" of scroll view "output" of window "main" to true
	end if
end action

on will open theObject
	(*	startserver() *)
	updatestatus()
end will open

on will close theObject
	(*	stopserver() *)
end will close

on launched theObject
	(*Add your script here.*)
	startserver()
end launched

on choose menu item theObject
	if name of the theObject is "updatefirmware" then
		if serverrunning() is not equal to 0 then
			set theResult to display dialog Â
				"In order to update your player, the SLIMP3 server will need to be stopped. Do you want to stop the server now?"
			set butt to (button returned of theResult)
			if butt is equal to "OK" then
				stopserver()
				set the visible of window "updater" to 1
				set the visible of window "main" to 0
			end if
		else
			set the visible of window "updater" to 1
			set the visible of window "main" to 0
		end if
	else if the name of theObject is "startstopmenu" then
		if serverrunning() is equal to 0 then
			startserver()
		else
			stopserver()
		end if
	end if
end choose menu item

on idle theObject
	updatestatus()
	return 5
end idle

on update menu item theObject
	if the name of theObject is equal to "startstopmenu" then
		if serverrunning() is equal to 0 then
			set the title of theObject to "Start Server"
		else
			set the title of theObject to "Stop Server"
		end if
	end if
	return 1
end update menu item

on keyboard up theObject event theEvent
	(*Add your script here.*)
end keyboard up

on keyboard down theObject event theEvent
	(*Add your script here.*)
end keyboard down
