//
//  SliMP3_ServerPref.m
//  SliMP3 Server
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright (c) 2002-2003 Slim Devices, Inc. All rights reserved.
//

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/param.h>
#include <unistd.h>
#include <signal.h>

#import "Slim_ServerPref.h"

@implementation SliMP3_ServerPref

-(void)mainViewDidLoad
{
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
    NSMutableDictionary *defaultValues;
    BOOL rewrite = NO;

    if (prefs != nil)
	defaultValues = [[prefs mutableCopy] autorelease];
    else
	defaultValues = [NSMutableDictionary dictionary];

    if ([defaultValues objectForKey:@"StartupMenuTag"] == nil)
    {
	[defaultValues setObject:[NSNumber numberWithInt:kSLIMNoAutomaticStartup] forKey:@"StartupMenuTag"];
	rewrite = YES;
    }
    // rewrite prefs with defaults (yuk)

    if (rewrite)
    {
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:defaultValues forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
    }

    [startupType selectItemAtIndex:[startupType indexOfItemWithTag:[[defaultValues objectForKey:@"StartupMenuTag"] intValue]]];
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self updateUI];
}

-(int)serverPID
{
    NSString *pathToScript = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Get SLIMP3 Server.sh"];

    /*
    **  Run a simple shell script to get the server's PID, if it's running.
    */

    NSTask *pipeTask = [[NSTask alloc] init];
    NSPipe *outputPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    NSData *inData = nil;
    NSMutableString *pidString = [NSMutableString string];
    int pid;

    [pipeTask setStandardOutput:outputPipe];
    [pipeTask setLaunchPath:pathToScript];
    [pipeTask launch];

    /*
    **	There's a pretty serious bug in the availableData API: it leaks approximately 4K
    ** when there's no data to read and it returns an NSData that's "empty". To get around
    ** this serious bug, I've switched to waiting until the process ends, and reading the
    ** whole thing at once.
    **
    **	Nasty.
    */
    
#ifdef SLIMP3_AVAILABLE_DATA_LEAK_FIXED
    while ((inData = [readHandle availableData]) && [inData length])
	[pidString appendString:[NSString stringWithCString:[inData bytes] length:[inData length]]];
#else
    [pipeTask waitUntilExit];

    inData = [readHandle readDataToEndOfFile];

    if ([inData length])
	[pidString appendString:[NSString stringWithCString:[inData bytes] length:[inData length]]];
#endif
    
    [pipeTask release];

    if (sscanf([pidString UTF8String], "%d", &pid) == 1)
	return pid;
    else
	return 0;
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

-(void)updateUI
{
    if ([updatingFirmware isVisible])
	[firmwareUpdateProgress setDoubleValue:[firmwareUpdateProgress doubleValue] + 1];
    else
    {
	bool currentServerState = ([self serverPID] != 0);

	if (currentServerState != [self serverState])
	{
	    [self setServerState:currentServerState];
	    [webLaunchButton setEnabled:currentServerState];
	    [updateFirmwareButton setEnabled:!currentServerState];

	    if (currentServerState)
	    {
		[toggleServerButton setTitle:SLIMLocalizedPrefString(@"Stop Server", "Stop Server")];
		[serverStateDescription setStringValue:SLIMLocalizedPrefString(@"Stop Server Description", "Descriptive text")];
		[serverStateImage setImage:[NSImage imageNamed:@"slimp3icon"]];
	    }
	    else
	    {
		[toggleServerButton setTitle:SLIMLocalizedPrefString(@"Start Server", "Start Server")];
		[serverStateDescription setStringValue:SLIMLocalizedPrefString(@"Start Server Description", "Descriptive text")];
		[serverStateImage setImage:[NSImage imageNamed:@"slimp3off"]];
	    }
	    [toggleServerButton setEnabled:YES];
	}
    }
}

-(void)openWebInterface:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost:9000"]];
}

-(void)aboutSliMP3:(id)sender
{
    [NSApp beginSheet:aboutBox modalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(IBAction)dismissAboutBox:(id)sender
{
    [aboutBox orderOut:sender];
    [NSApp endSheet:aboutBox returnCode:1];
}

-(IBAction)changeStartupPreference:(id)sender
{
    NSMutableDictionary *prefs = [[[[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]] mutableCopy] autorelease];

    int previousStartupValue = [[prefs objectForKey:@"StartupMenuTag"] intValue];

    if ([self changeAutoStartupFrom:previousStartupValue to:[sender tag]])
    {
	[prefs setObject:[NSNumber numberWithInt:[sender tag]] forKey:@"StartupMenuTag"];

	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefs forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	[[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
	[startupType selectItemAtIndex:[startupType indexOfItemWithTag:previousStartupValue]];
}

-(bool)changeAutoStartupFrom:(int)previousStartupType to:(int)newStartupType
{
    /*
     **  If we're set up to start at boot, get authentication credentials before continuing.
     */

    if (newStartupType == kSLIMStartupAtBoot || previousStartupType == kSLIMStartupAtBoot)
    {
	if (![self authorizeUser])
	    return NO;
	else
	{
	    /*
	     **  Now that we're authorized, add or remove our StartupItems entry.
	     */

	    NSString *scriptToRun = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent: (newStartupType == kSLIMStartupAtBoot) ? @"Create SLIMP3 Startup.sh" : @"Remove SLIMP3 Startup.sh"];

	    OSStatus myStatus;
	    AuthorizationFlags myFlags = kAuthorizationFlagDefaults;
	    FILE *myCommunicationsPipe = NULL;
	    char myReadBuffer[128];
	    const char *myArguments[] = { NULL };

	    /*
	     **  OK, run the script with administrator privs, based on the token we retrieved earlier.
	     */

	    myStatus = AuthorizationExecuteWithPrivileges (myAuthorizationRef, (char *) [scriptToRun UTF8String], myFlags, (char **) myArguments, &myCommunicationsPipe);

	    if (myStatus == errAuthorizationSuccess)
	    {
		for (;;)
		{
		    int bytesRead = read (fileno (myCommunicationsPipe), myReadBuffer, sizeof (myReadBuffer));

		    if (bytesRead < 1)
			break;
		}
		AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);
	    }
	    else
	    {
		AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);
		return NO;
	    }
	}
    }
    /*
     **  We always remove our login item, just in case the entry is there. (Otherwise, we end up with two.)
     */

    NSString *pathToServer = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/SLIMP3 Launcher.app"];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSMutableArray *allLoginItems, *objectsToRemove = [[NSMutableArray alloc] init];
    NSMutableDictionary *loginwindow = [[userDefaults persistentDomainForName:@"loginwindow"] mutableCopy];
    NSDictionary *currentStartupDictionary;
    int currItem, totalItems;

    allLoginItems = [[loginwindow objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy];

    /*
     **  If there are no login items, it'll end up nil. So, we allocate our own.
     */

    if (allLoginItems == nil)
	allLoginItems = [[NSMutableArray alloc] init];

    /*
     **  Remove all instances of our server startup.
     */

    totalItems = [allLoginItems count];

    for (currItem = 0 ; currItem < totalItems ; currItem++)
    {
	NSString *path;

	currentStartupDictionary = [allLoginItems objectAtIndex:currItem];
	path = [currentStartupDictionary objectForKey:@"Path"];

	if (path != nil && [path isEqualToString:pathToServer])
	    [objectsToRemove addObject:currentStartupDictionary];
    }
    [allLoginItems removeObjectsInArray:objectsToRemove];
    [objectsToRemove release];

    if (newStartupType == kSLIMStartupAtLogin)
    {
	/*
	 **  Ensure we start up when this user logs in.
	 */

	[allLoginItems insertObject:[NSDictionary dictionaryWithObjectsAndKeys:pathToServer,@"Path",[NSNumber numberWithBool:NO],@"Hide", nil] atIndex:0];
    }
    if ([allLoginItems count] == 0)
	[loginwindow removeObjectForKey:@"AutoLaunchedApplicationDictionary"];
    else
	[loginwindow setObject:allLoginItems forKey:@"AutoLaunchedApplicationDictionary"];

    [userDefaults removePersistentDomainForName:@"loginwindow"];
    [userDefaults setPersistentDomain:loginwindow forName:@"loginwindow"];
    [userDefaults synchronize];
    [userDefaults release];
    [allLoginItems release];
    [loginwindow release];

    return YES;
}

-(void)toggleServer:(id)sender
{
    NSString *pathToServer = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/SLIMP3 Launcher.app"];

    /*
     **  Disable the button...it'll get re-enabled when the server state changes in updateUI.
     */

    [toggleServerButton setEnabled:NO];

    int pid = [self serverPID];
    
    if (pid != 0)
    {
#ifndef SLIMP3_DIRECT_SERVER_KILL
	NSTask *killServerTask = [NSTask launchedTaskWithLaunchPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Stop SLIMP3 Server.sh"] arguments:[NSArray array]];

	[killServerTask waitUntilExit];
#else
	kill (pid, SIGTERM);
#endif
    }
    else
    {
	[[NSWorkspace sharedWorkspace] launchApplication:pathToServer showIcon:NO autolaunch:YES];
    }
    /*
    **  Reactivate our window.
    */

    [[[self mainView] window] makeFirstResponder:[[self mainView] window]];
}

-(IBAction)updateSliMP3Firmware:(id)sender
{
    /*
     **  First, preauthorize the user. If they can't authorize, there's no
     ** point showing the update window. We assume the firmware updater is
     ** going to free the token.
     */
    
    if ([self authorizeUser])
    {
	/*
	**  Get the firmware version number and update the dialog text to
	** reflect. The version is the first line of the file.
	*/

	NSScanner *firmwareVersionScanner = [NSScanner scannerWithString:[NSString stringWithContentsOfFile:[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/firmware/MAIN.HEX"]]];

	NSString *versionString;

	if ([firmwareVersionScanner scanUpToString:@"\n" intoString:&versionString])
	    [firmwareVersion setStringValue:[NSString stringWithFormat:SLIMLocalizedPrefString(@"Firmware version", "Firmware version %@."), versionString]];
	else
	    [firmwareVersion setStringValue:[NSString stringWithString:SLIMLocalizedPrefString(@"Firmware version invalid", "Firmware version invalid.")]];
	
	[NSApp beginSheet:updateFirmware modalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
}

-(IBAction)doFirmwareUpdate:(id)sender
{
    /*
    **  Parse and validate.
    **
    **	MAC address can be entered with or without colons, and with or without spaces, but must be hex digits.
    **  IP address must be entered in dot-form, with or without spaces.
    **
    **  Neither value is checked for range (more significant for IP). IPv6 not supported.
    */

    int mac1, mac2, mac3, mac4, mac5, mac6;

    if (sscanf ([[macAddress stringValue] UTF8String], "%x : %x : %x : %x : %x : %x", &mac1, &mac2, &mac3, &mac4, &mac5, &mac6) != 6 && sscanf ([[macAddress stringValue] UTF8String], "%2x %2x %2x %2x %2x %2x", &mac1, &mac2, &mac3, &mac4, &mac5, &mac6) != 6)
    {
	NSBeep ();
	return;
    }

    NSString *macAddressString = [NSString stringWithFormat:@"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x", mac1, mac2, mac3, mac4, mac5, mac6];

    [macAddress setStringValue:macAddressString];

    int ip1, ip2, ip3, ip4;

    if (sscanf ([[ipAddress stringValue] UTF8String], "%d . %d . %d . %d", &ip1, &ip2, &ip3, &ip4) != 4)
    {
	NSBeep ();
	return;
    }

    NSString *ipAddressString = [NSString stringWithFormat:@"%d.%d.%d.%d", ip1, ip2, ip3, ip4];

    [ipAddress setStringValue:ipAddressString];
    
    [updateFirmware orderOut:sender];
    [NSApp endSheet:updateFirmware returnCode:1];

    /*
    **  Set the progress to 0, and display the window. We've set the bar to 120 "increments" to allow
    ** second-by-second updates up to the supposed two minute maximum. Cancel is not supported once
    ** the process has been spawned.
    */
    
    [firmwareUpdateProgress setDoubleValue:(double)0];
    [NSApp beginSheet:updatingFirmware modalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:nil contextInfo:nil];

    /*
    **  Spin this out into its own thread to allow the progress bar to be updated.
    */

    [NSThread detachNewThreadSelector:@selector(firmwareUpdateThread:) toTarget:self withObject:nil];
}

-(IBAction)cancelFirmwareUpdate:(id)sender
{
    AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);
    
    [updateFirmware orderOut:sender];
    [NSApp endSheet:updateFirmware returnCode:-1];
}

-(IBAction)dismissUpdateComplete:(id)sender
{
    [updateComplete orderOut:sender];
    [NSApp endSheet:updateComplete returnCode:-1];
}

-(void)firmwareUpdateThread:(id)userObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    firmwareUpdateThread = [NSThread currentThread];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firmwareUpdateThreadEnding:) name:NSThreadWillExitNotification object:firmwareUpdateThread];

    NSString *pathToUpdater = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/firmware"];

    OSStatus myStatus;
    AuthorizationFlags myFlags = kAuthorizationFlagDefaults;
    FILE *myCommunicationsPipe = NULL;
    char myReadBuffer[128];
    const char *myArguments[] = { [[macAddress stringValue] UTF8String], [[ipAddress stringValue] UTF8String], NULL };
    NSMutableString *toolOutput = [NSMutableString stringWithCapacity:sizeof(myReadBuffer)];

    /*
     **  OK, run the updater with administrator privs, based on the token we retrieved earlier. Retrieve the
     ** output of the tool (which is assumed to be the message to display to the user), and display it once
     ** execution has finished.
     */
    
    char *currentDirectory = getcwd (NULL, MAXPATHLEN);

    chdir ([pathToUpdater UTF8String]);

    /*
    **  Note -- we don't execute the PERL script directly here, because doing so causes a crash/hang when executing the "system" command.
    ** Instead, the shell script executes the two commands that are done with "system", and the PERL script does the rest.
    */
    
    myStatus = AuthorizationExecuteWithPrivileges (myAuthorizationRef, "Update Firmware.sh", myFlags, (char **) myArguments, &myCommunicationsPipe);

    if (myStatus == errAuthorizationSuccess)
    {
	for (;;)
	{
	    int bytesRead = read (fileno (myCommunicationsPipe), myReadBuffer, sizeof (myReadBuffer));

	    if (bytesRead < 1)
		break;

	    [toolOutput appendString:[NSString stringWithCString:myReadBuffer length:bytesRead]];
	}
    }
    else
    {
	NSBeep ();

	if (myStatus == errAuthorizationToolExecuteFailure)
	    [toolOutput appendString:SLIMLocalizedPrefString(@"Authorization Launch Error", "Unable to update firmware: missing Update Firmware.sh.")];
	else
	    [toolOutput appendString:SLIMLocalizedPrefString(@"Expired Authorization Error", "Unable to update firmware: authorization expired.")];
    }
    chdir (currentDirectory);
    free (currentDirectory);
    
    [updateCompleteMessage setStringValue:toolOutput];
    [pool release];
}

-(void)firmwareUpdateThreadEnding:(NSNotification *)n
{
    [updatingFirmware orderOut:nil];
    [NSApp endSheet:updatingFirmware returnCode:1];

    AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);

    [NSApp beginSheet:updateComplete modalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(bool)serverState
{
    return serverState;
}

-(void)setServerState:(bool)newState
{
    serverState = newState;
}
@end
