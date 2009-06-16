//
//  installer.m
//  
//
//  Created by Dave Nanian on Fri Jan 03 2003.
//  Copyright 2003-2009 Logitech
//

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#import "Installer.h"

@implementation Slim_Installer

-(void)awakeFromNib
{
	// bring Window to the front
	[[installButton window] makeKeyAndOrderFront: self];
	
	SInt32 vers;
	Gestalt(gestaltSystemVersion,&vers);
	if (vers < 0x00001030)
	{
		
		NSRunAlertPanel(@"Mac OS X 10.3 Required", @"You must have OS X 10.3 or later to run .", @"Quit", nil, nil);
		
		[[NSApplication sharedApplication] terminate:nil];
		return;
	}
	
	[progressIndicator setUsesThreadedAnimation:YES];

	if ([progressIndicator respondsToSelector:@selector(setDisplayedWhenStopped:)])
		[progressIndicator setDisplayedWhenStopped:NO];
	
	// Search for the preference pane. If found, default our install appropriately.
	NSEnumerator *pathEnum = [NSSearchPathForDirectoriesInDomains (NSAllLibrariesDirectory, NSUserDomainMask | NSLocalDomainMask, YES) objectEnumerator];
	NSString *currDirectory;

	while (currDirectory = [pathEnum nextObject])
	{
		if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:[currDirectory stringByAppendingPathComponent:@"PreferencePanes/Squeezebox Server.prefPane"]])
		{
			if ([currDirectory isEqual:@"/Library"])
				foundGlobal = true;
			else
				foundLocal = true;
		}
	}
	if (foundLocal || foundGlobal)
		[installButton setTitle:LocalizedPrefString(@"Update", "Update")];
}

-(bool)authorizeUser
{
	OSStatus myStatus;
	AuthorizationFlags myFlags = kAuthorizationFlagDefaults;

	myStatus = AuthorizationCreate (NULL, kAuthorizationEmptyEnvironment, myFlags, &myAuthorizationRef);

	if (myStatus != errAuthorizationSuccess)
	{
		NSBeep ();
		return NO;
	}

	AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights myRights = {1, &myItems};

	myFlags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;

	myStatus = AuthorizationCopyRights (myAuthorizationRef, &myRights, NULL, myFlags, NULL);

	if (myStatus != errAuthorizationSuccess)
	{
		NSBeep ();
		AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);
		return NO;
	}
	return YES;
}

-(void)slowSPQuit:(NSTimer *)timer
{
	[NSApp beginSheet:waitSheet modalForWindow:installWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(IBAction)cancelWait:(id)sender
{
	// By the time we get here, the task could have died -- we need to protect against the exception
	// that would result.
	
	NS_DURING
	[preflightTask terminate];
	[waitSheet orderOut:self];
	[NSApp endSheet:waitSheet];
	NS_HANDLER
	NS_ENDHANDLER
}

// Note:
// Ownership unresolved (ditto may make current user owner)
// Checking output for the word "success" isn't good...but I can't
// get the return value from the authorization task.

-(IBAction)doInstall:(id)sender
{
	[sender setEnabled:NO];

	// This should automatically show/hide, but doesn't.
	
	[progressIndicator startAnimation:self];
	[progressIndicator setNeedsDisplay:YES];
	[sender displayIfNeeded];

	// Run the preflight script to ensure we're ready to install.

	NSTimer *preflightTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(slowSPQuit:) userInfo:nil repeats:NO];

	preflightTask = [[NSTask alloc] init];
	[preflightTask setLaunchPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Preflight.sh"]];
	[preflightTask launch];

	// Semi-busy wait to allow the cancel button to work: you'd think that [[NSRunLoop currentRunLoop] runUntilDate:...] would work,
	// but you'd be quite wrong.
	while ([preflightTask isRunning])
	{
		NSEvent *event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.2] inMode:NSDefaultRunLoopMode dequeue:YES];
	
		if (event)
			[NSApp sendEvent:event];
	}
	
	[preflightTimer invalidate];
	
	if ([waitSheet isVisible])
	{
		[waitSheet orderOut:self];
		[NSApp endSheet:waitSheet];
	}
	
	[preflightTask autorelease];
	
	// First, get the install type, and check if we need to be authorized:

	NSString *folderToInstall = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"../Install Files"];
	NSString *installerScript = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"install.sh"];
	NSString *fileInstalled = [[NSString stringWithString:@"/Library/PreferencePanes/Squeezebox Server.prefPane"] retain];
	NSMutableString *scriptOutput = [[NSMutableString alloc] init];

	/*
	** Authorize if we're going to install or remove the global preference pane.
	*/
	
	if ([self authorizeUser] == NO)
	{
		[sender setEnabled:YES];
		[progressIndicator stopAnimation:self];
		[progressIndicator setNeedsDisplay:YES];
		return;
	}

	// We know we're authorized: run the install script, with authorization.

	OSStatus myStatus;
	AuthorizationFlags myFlags = kAuthorizationFlagDefaults;
	FILE *myCommunicationsPipe = NULL;
	char myReadBuffer[128];
	const char *myArguments[] = { [folderToInstall UTF8String], [fileInstalled UTF8String], NULL };

	/*
	 ** OK, run script with administrator privs, based on the token
	 ** we retrieved earlier. We might want to retrieve the
	 ** output of the tool (which is assumed to be the message to display
	 ** to the user), and display it once
	 ** execution has finished...
	 */

	myStatus = AuthorizationExecuteWithPrivileges (myAuthorizationRef, [installerScript UTF8String], myFlags, (char **) myArguments, &myCommunicationsPipe);

	if (myStatus == errAuthorizationSuccess)
	{
		for (;;)
		{
			int bytesRead = read (fileno (myCommunicationsPipe), myReadBuffer, sizeof (myReadBuffer));
	
			if (bytesRead < 1)
				break;
			
			[scriptOutput appendString:[NSString stringWithCString:myReadBuffer length:bytesRead]];
		}
		fclose (myCommunicationsPipe);
	}
	else
	{
		NSBeep ();
		[fileInstalled release];
		fileInstalled = nil;
	}

	/*
	**  Free the authorization reference if we're running authorized to either remote the global prefPane
	** or install it.
	*/
	
	AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);
	
	if ([scriptOutput length] > 0)
	{
		if (NSEqualRanges ([scriptOutput rangeOfString:@"success" options:NSCaseInsensitiveSearch], NSMakeRange (NSNotFound, 0)))
		{
			[fileInstalled release];
			fileInstalled = nil;
		}
		NSBeginAlertSheet (LocalizedPrefString(@"Install Results", "Install Results"), LocalizedPrefString(@"OK", "OK"), nil, nil, [[NSApplication sharedApplication] mainWindow], self, @selector (sheetDidEnd:returnCode:contextInfo:), nil, fileInstalled, @"%@", LocalizedPrefString(scriptOutput, scriptOutput));
	}

	[scriptOutput release];
	scriptOutput = nil;
	[progressIndicator stopAnimation:self];
	[progressIndicator setNeedsDisplay:YES];
	[sender setEnabled:YES];
}

-(void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSString *fileInstalled = (NSString *)contextInfo;

	if (fileInstalled != nil && [[NSWorkspace sharedWorkspace] isFilePackageAtPath:fileInstalled])
	{
		/*
		**  Launch the new preference pane to let the user manipulate it.
		*/
		
		NSTask *postflightTask = [NSTask launchedTaskWithLaunchPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Postflight.sh"] arguments:[NSArray arrayWithObjects:fileInstalled,nil]];
		
		[postflightTask waitUntilExit];
		[self performSelector:@selector(quitInstall:) withObject:nil afterDelay:0.1];
	}
	[fileInstalled release];
}

-(IBAction)quitInstall:(id)sender;
{
	[[NSApplication sharedApplication] terminate:nil];
}

@end
