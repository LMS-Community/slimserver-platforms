//
//  ServerPref.m
//  SqueezeCenter
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright 2002-2007 Logitech
//

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/param.h>
#include <unistd.h>
#include <signal.h>

#import "ServerPref.h"

@implementation Slim_ServerPref

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
		[defaultValues setObject:[NSNumber numberWithInt:kNoAutomaticStartup] forKey:@"StartupMenuTag"];
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
	NSString *pathToScript = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"get-server.sh"];

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
	
#ifdef AVAILABLE_DATA_LEAK_FIXED
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


-(int)serverPort
{
	NSString *pathToScript = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"check-web.pl"];
	
	/*
	 **  Run a simple shell script to get the server's HTTP port, if it's running.
	 */
	
	NSTask *pipeTask = [[NSTask alloc] init];
	NSPipe *outputPipe = [NSPipe pipe];
	NSFileHandle *readHandle = [outputPipe fileHandleForReading];
	NSData *inData = nil;
	NSMutableString *portString = [NSMutableString string];
	int port;
	
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
	
#ifdef AVAILABLE_DATA_LEAK_FIXED
	while ((inData = [readHandle availableData]) && [inData length])
		[portString appendString:[NSString stringWithCString:[inData bytes] length:[inData length]]];
#else
	[pipeTask waitUntilExit];
	
	inData = [readHandle readDataToEndOfFile];
	
	if ([inData length])
		[portString appendString:[NSString stringWithCString:[inData bytes] length:[inData length]]];
#endif
	
	[pipeTask release];
	
	if (sscanf([portString UTF8String], "%d", &port) == 1)
		return port;
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
	bool currentServerState = ([self serverPID] != 0);
	bool currentWebState = currentServerState && [self serverPort];
	
	if (currentServerState != [self serverState])
	{
		[self setServerState:currentServerState];
					
		if (currentServerState)
		{
			[toggleServerButton setTitle:LocalizedPrefString(@"Stop Server", "Stop Server")];
			[serverStateDescription setStringValue:LocalizedPrefString(@"Stop Server Description", "Descriptive text")];
		}
		else
		{
			[toggleServerButton setTitle:LocalizedPrefString(@"Start Server", "Start Server")];
			[serverStateDescription setStringValue:LocalizedPrefString(@"Start Server Description", "Descriptive text")];
		}
		[toggleServerButton setEnabled:YES];
	}
	
	[webLaunchButton setEnabled:currentWebState];
}

-(void)openWebInterface:(id)sender
{
	int port = [self serverPort];
	char* url = malloc(100);

	if (!port) { port = 9000; }
		sprintf(url, "http://localhost:%i", port);
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: [NSString stringWithCString:url] ]];

	free((void*)url);
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

	if (newStartupType == kStartupAtBoot || previousStartupType == kStartupAtBoot)
	{
		if (![self authorizeUser])
			return NO;
		else
		{
			/*
			 **  Now that we're authorized, add or remove our StartupItems entry.
			 */
	
			NSString *scriptToRun = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent: (newStartupType == kStartupAtBoot) ? @"create-startup.sh" : @"remove-startup.sh"];
	
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

	NSString *pathToServer = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/SqueezeCenter.app"];

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

	if (newStartupType == kStartupAtLogin)
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
	NSString *pathToServer = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/SqueezeCenter.app"];

	/*
	 **  Disable the button...it'll get re-enabled when the server state changes in updateUI.
	 */

	[toggleServerButton setEnabled:NO];

	int pid = [self serverPID];
	
	if (pid != 0)
	{
#ifndef DIRECT_SERVER_KILL
		NSTask *killServerTask = [NSTask launchedTaskWithLaunchPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"stop-server.sh"] arguments:[NSArray array]];

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

-(bool)serverState
{
	return serverState;
}

-(void)setServerState:(bool)newState
{
	serverState = newState;
}

-(bool)webState
{
	return webState;
}

-(void)setWebState:(bool)newState
{
	webState = newState;
}

@end
