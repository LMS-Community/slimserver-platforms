//
//  ServerPref.m
//  Squeezebox Server
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
		[defaultValues setObject:[NSNumber numberWithInt:kStartupAtBoot] forKey:@"StartupMenuTag"];
		rewrite = YES;
	}
	else if ([[defaultValues objectForKey:@"StartupMenuTag"] intValue] == kStartupAtLogin)
	{
		[self changeAutoStartupFrom:0 to:kStartupAtLogin];
	}
	
	// rewrite prefs with defaults (yuk)

	if (rewrite)
	{
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:defaultValues forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	}

	[startupType selectItemAtIndex:[startupType indexOfItemWithTag:[[defaultValues objectForKey:@"StartupMenuTag"] intValue]]];
	[musicLibraryName setStringValue:[self getPref:@"libraryname"]];
	
	// SqueezeNetwork settings
	[snUsername setStringValue:[self getPref:@"sn_email"]];
	[snPassword setStringValue:([self getPref:@"sn_password_sha"] != @"" ? snPasswordPlaceholder : @"")];
	
	int option = [[self getPref:@"sn_disable_stats"] intValue];
	[snStatsOptions selectItemAtIndex:(option == 1 ? 1 : 0)];

	// monitor scan progress
	[NSTimer scheduledTimerWithTimeInterval: 1.9 target:self selector:@selector(scanPoll) userInfo:nil repeats:YES];
	
	scStrings = [NSMutableDictionary new];
	
	[scanProgressDesc setStringValue:@""];
	[scanProgressDetail setStringValue:@""];
	[scanProgressError setStringValue:@""];
	
	[musicFolder setStringValue:[self getPref:@"audiodir"]];
	[playlistFolder setStringValue:[self getPref:@"playlistdir"]];
	option = [[self getPref:@"itunes" fileName:@"itunes.prefs"] intValue];
	[useiTunes setState:(option == 1 ? 1 : 0)];

	// check whether an update installer is available
	[NSTimer scheduledTimerWithTimeInterval: 60 target:self selector:@selector(checkUpdateInstaller) userInfo:nil repeats:YES];
	[self checkUpdateInstaller];
	
	if (hasUpdateInstaller) {
		NSBeginAlertSheet (
						   LocalizedPrefString(@"An updated Squeezebox Server version is available and ready to be installed.", @""),
						   LocalizedPrefString(@"Install update", @""),
						   LocalizedPrefString(@"Not now", @""),
						   nil, 
						   [[NSApplication sharedApplication] mainWindow], 
						   self, 
						   @selector(installUpdateConfirmed:returnCode:contextInfo:),
						   NULL, 
						   @"",
						   @""
						   );
	}

	[NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
	[self updateUI];
	[self updateMusicLibraryStats];
	
	[self showRevision];
	
	[self jsonRequest:@"\"pref\", \"wizardDone\", \"1\""];
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

-(void)showRevision
{
	NSString *revisionTxt = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/revision.txt"];

	if (revisionTxt != nil && [[NSFileManager defaultManager] fileExistsAtPath:revisionTxt]) {
		
		NSArray *lines = [[NSString stringWithContentsOfFile:revisionTxt] componentsSeparatedByString:@"\n"];

		if ([lines count] > 0) {
			[scVersion setStringValue:[NSString stringWithFormat:@"%@ / r%@", [scVersion stringValue], [lines objectAtIndex:0]]];
		}
	}
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
			[serverStateLabel setStringValue:LocalizedPrefString(@"The server is running", "The server is running")];
			[toggleServerButton setTitle:LocalizedPrefString(@"Stop Server", "Stop Server")];
		}
		else
		{
			[serverStateLabel setStringValue:LocalizedPrefString(@"The server is stopped", "The server is stopped")];
			[toggleServerButton setTitle:LocalizedPrefString(@"Start Server", "Start Server")];
			isScanning = NO;
		}
		[toggleServerButton setEnabled:YES];
	}
	
	[webLaunchButton setEnabled:currentWebState];
	[advLaunchButton setEnabled:currentWebState];
	
	[snUsername setEnabled:serverState];
	[snPassword setEnabled:serverState];
	[snCheckPassword setEnabled:serverState];
	[snStatsOptions setEnabled:serverState];

	[musicLibraryName setEnabled:serverState];
	[musicFolder setEnabled:serverState];
	[browseMusicFolder setEnabled:serverState];
	[playlistFolder setEnabled:serverState];
	[browsePlaylistFolder setEnabled:serverState];
	[useiTunes setEnabled:serverState];

	[scanModeOptions setEnabled:(serverState && !isScanning)];
	[scanProgress setHidden:!isScanning];
	[scanProgressDesc setHidden:!isScanning];
	[scanProgressDetail setHidden:!isScanning];
	[scanProgressTime setHidden:!isScanning];

	if (isScanning) {
		[rescanButton setTitle:LocalizedPrefString(@"Abort", @"")];
		[scanSpinny startAnimation:self];
		[scanProgressError setStringValue:@""];
	}
	else {
		[rescanButton setTitle:LocalizedPrefString(@"Rescan", @"")];
		[scanSpinny stopAnimation:self];
		[scanProgressDesc setStringValue:@""];
		[scanProgressDetail setStringValue:@""];
		[scanProgressTime setStringValue:@"00:00:00"];
	}
}

-(void)updateMusicLibraryStats
{
	[musicLibraryStats setStringValue:@""];

	NSDictionary *libraryStats = [self jsonRequest:@"\"systeminfo\", \"items\", \"0\", \"999\""];

	NSArray *steps = nil;
	if (libraryStats != nil)
		steps = [libraryStats valueForKey:@"loop_loop"];
		
	if (steps != nil) {
			
		NSString *statsLabel = [self getSCString:@"INFORMATION_MENU_LIBRARY"];
			
		int x;
		NSDictionary *statsItem;
		for (x = 0; x < [steps count]; x++) {

			statsItem = [steps objectAtIndex:x];
				
			if ([[statsItem valueForKey:@"name"] isEqualToString:statsLabel])
				break;
		}
			
		if (x < [steps count]) {
				
			libraryStats = [self jsonRequest:[NSString stringWithFormat:@"\"systeminfo\", \"items\", \"0\", \"999\", \"item_id:%i\"", x]];
				
			if (libraryStats != nil)
				steps = [libraryStats valueForKey:@"loop_loop"];

			if (steps != nil) {
					
				statsLabel = @"";
					
				for (x = 0; x < [steps count]; x++) {
						
					statsItem = [steps objectAtIndex:x];
						
					if ([statsItem valueForKey:@"name"] != nil)
						statsLabel = [statsLabel stringByAppendingString:[NSString stringWithFormat:@"%@\n", [statsItem valueForKey:@"name"]]];
			
				}
					
				[musicLibraryStats setStringValue:statsLabel];
			}
		}
			
	}
}
	
-(void)openWebInterface:(id)sender
{
	int port = [self serverPort];
	if (!port > 0) { port = 9000; }
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://localhost:%i/", port] ]];
}

-(void)openSettingsWebInterface:(id)sender
{
	int port = [self serverPort];
	if (!port > 0) { port = 9000; }
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://localhost:%i/settings/index.html", port] ]];
}

-(IBAction)changeStartupPreference:(id)sender
{
	NSMutableDictionary *prefs = [[[[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]] mutableCopy] autorelease];

	int previousStartupValue = [[prefs objectForKey:@"StartupMenuTag"] intValue];

	if ([self changeAutoStartupFrom:previousStartupValue to:[startupType indexOfSelectedItem]])
	{
		[prefs setObject:[NSNumber numberWithInt:[startupType indexOfSelectedItem]] forKey:@"StartupMenuTag"];
	
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

	NSString *pathToServer = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/Launcher.app"];

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
	NSString *pathToServer = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/server/Launcher.app"];

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


/* SC update related methods */
-(NSString *)checkUpdateInstaller
{
	NSString *pathToUpdate = [self findFile:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) fileName:versionFile];

	if ([pathToUpdate length] == 0)
		pathToUpdate = [self findFile:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES) fileName:versionFile];

	if ([pathToUpdate length] > 0) {
		NSString *fileString = [NSString stringWithContentsOfFile:pathToUpdate];
		NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
	
		if ([lines count] > 0)
		{
			NSString *installer = [lines objectAtIndex:0];
			
			hasUpdateInstaller = (installer != nil && [[NSFileManager defaultManager] fileExistsAtPath:installer]);
			return installer;
		}
	}

	return nil;
}

-(void)installUpdateConfirmed:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertDefaultReturn) {
		NSString *installer = [self checkUpdateInstaller];
		
		if (installer != nil && [[NSFileManager defaultManager] fileExistsAtPath:installer]) {
			
			updateURL = nil;
			
			NSString *pathToScript = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"run-installer.sh"];
			NSTask *updateTask = [NSTask launchedTaskWithLaunchPath:pathToScript arguments:[NSArray arrayWithObjects:installer,nil]];
			[updateTask waitUntilExit];
		}
	}
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


/* button handler to show log files */
-(IBAction)showServerLog:(id)sender
{
	[self showLog:@"server.log"];
}

-(IBAction)showScannerLog:(id)sender
{
	[self showLog:@"scanner.log"];
}

-(void)showLog:(NSString *)whichLog
{	
	NSString *pathToLog;
	
	whichLog = [logDir stringByAppendingPathComponent:whichLog];	

	pathToLog = [self findFile:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) fileName:whichLog];
	
	if ([pathToLog length] == 0)
		pathToLog = [self findFile:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES) fileName:whichLog];
	
	[[NSWorkspace sharedWorkspace] openFile:pathToLog];
}

/* SqueezeNetwork */
-(IBAction)checkSNPassword:(id)sender
{
	NSString *username = [snUsername stringValue];
	NSString *password = [snPassword stringValue];

	if (username != nil && password != nil && username != @"" && password != @"" && password != snPasswordPlaceholder) {
		NSDictionary *snResult = [self saveSNCredentials];
		
		NSString *msg = @"";
	
		if (snResult == nil || [[snResult valueForKey:@"validated"] intValue] == 0)
			msg = @"Invalid SqueezeNetwork username or password.";
		else if (snResult != nil && [[snResult valueForKey:@"validated"] intValue] != 0) 
			msg = @"Connected successfully to SqueezeNetwork.";

		if (snResult != nil && [snResult valueForKey:@"warning"] != nil)
			msg = LocalizedPrefString([snResult valueForKey:@"warning"], @"");

		if (msg != @"")
			NSBeginAlertSheet (LocalizedPrefString(msg, @""), LocalizedPrefString(@"Ok", @""), nil, nil,[[NSApplication sharedApplication] mainWindow], self, nil, NULL, @"", @"");
	}
}

-(IBAction)snCredentialsChanged:(id)sender
{
	[self saveSNCredentials];
}

-(NSDictionary *)saveSNCredentials
{
	NSString *username = [snUsername stringValue];
	NSString *password = [snPassword stringValue];
	
	NSDictionary *snResult = nil;
	
	if (username != nil && password != nil && username != @"" && password != @"" && password != snPasswordPlaceholder)
		snResult = [self jsonRequest:[NSString stringWithFormat:@"\"setsncredentials\", \"%@\", \"%@\"", username, password]];

	return snResult;
}

-(IBAction)snStatsOptionChanged:(id)sender
{
	[self jsonRequest:[NSString stringWithFormat:@"\"pref\", \"sn_disable_stats\", \"%@\"", [snStatsOptions objectValue]]];
}

-(void)openSNSubscription:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"http://www.squeezenetwork.com/" ]];
}

-(void)openSNPasswordReminder:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"http://www.squeezenetwork.com/user/forgotPassword" ]];
}


/* Music Library settings */
-(IBAction)doBrowseMusicFolder:(id)sender
{
	[self browseFolder:musicFolder];
}

-(IBAction)doBrowsePlaylistFolder:(id)sender
{
	[self browseFolder:playlistFolder];
}

-(void)browseFolder:(NSTextField *)path
{
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	[openDlg setCanChooseFiles:NO];
	[openDlg setCanChooseDirectories:YES];
	[openDlg setAllowsMultipleSelection:NO];
	
	if ([openDlg runModalForDirectory:[path stringValue] file:nil] == NSOKButton)
	{
		if (![[openDlg filename] isEqual:[path stringValue]])
		{
			[path setStringValue:[openDlg filename]];
			[self musicFolderChanged:self];
		}
	}
}

-(IBAction)musicFolderChanged:(id)sender
{
	[self jsonRequest:[NSString stringWithFormat:@"\"pref\", \"audiodir\", \"%@\"", [musicFolder stringValue]]];
}

-(IBAction)playlistFolderChanged:(id)sender
{
	[self jsonRequest:[NSString stringWithFormat:@"\"pref\", \"playlistdir\", \"%@\"", [playlistFolder stringValue]]];
}

-(IBAction)useiTunesChanged:(id)sender
{
	[self jsonRequest:[NSString stringWithFormat:@"\"pref\", \"plugin.itunes:itunes\", \"%@\"", ([useiTunes state] == NSOnState ? @"1" : @"0")]];
}

-(IBAction)libraryNameChanged:(id)sender
{
	[self jsonRequest:[NSString stringWithFormat:@"\"pref\", \"libraryname\", \"%@\"", [musicLibraryName stringValue]]];
}

/* rescan buttons and progress */
-(IBAction)rescan:(id)sender
{
	if (isScanning)
	{
		isScanning = NO;
		[self jsonRequest:@"\"abortscan\""];
	}
	else {
		isScanning = YES;
		[self updateUI];

		switch ([scanModeOptions indexOfSelectedItem])
		{
			case 0:
				[self jsonRequest:@"\"rescan\""];
				break;
			case 1:
				[self jsonRequest:@"\"wipecache\""];
				break;
			case 2:
				[self jsonRequest:@"\"rescan\", \"playlists\""];
				break;
		}
	
		isScanning = YES;
	}
	
	[self updateUI];
}

- (void)scanPoll
{
	NSDictionary *pollResult = [self jsonRequest:@"\"rescanprogress\""];

	isScanning = NO;
	
	if (pollResult != nil)
	{
		NSString *scanning = [pollResult valueForKey:@"rescan"];
		NSArray *steps     = [[pollResult valueForKey:@"steps"] componentsSeparatedByString:@","];
		NSString *failure  = [pollResult valueForKey:@"lastscanfailed"];

		isScanning = ([scanning intValue] > 0);
		
		if (scanning != nil && steps != nil)
		{
			[scanProgressError setStringValue:@""];

			NSString *currentStep = [steps lastObject];
			int step = [steps count];
			
			if (currentStep != nil)
				[scanProgressDesc setStringValue:[NSString stringWithFormat:@"%d. %@", step, [self getSCString:[currentStep stringByAppendingString:@"_PROGRESS"]] ] ];
			else 
				[scanProgressDesc setStringValue:@""];

			NSString *detail = [pollResult valueForKey:@"info"];
			if (detail != nil)
				[scanProgressDetail setStringValue:detail];
			else
				[scanProgressDetail setStringValue:@""];

			NSString *currentProgress = [pollResult valueForKey:currentStep];
			if (currentProgress != nil)
				[scanProgress setDoubleValue:[currentProgress doubleValue]];
			else
				[scanProgress setDoubleValue:0];

			NSString *currentTime = [pollResult valueForKey:@"totaltime"];
			if (currentTime != nil)
				[scanProgressTime setStringValue:currentTime];
			else
				[scanProgressTime setStringValue:@"00:00:00"];
		}
		
		else if (failure != nil)
		{
			[scanProgressDetail setStringValue:@""];
			[scanProgressError setStringValue:failure];
		}
	}
}

/* cleanup panel */
-(IBAction)cleanupBtnHandler:(id)sender
{
	if ([[self getCleanupParams] isEqualToString:@""])
		return;

	if ([self serverState]) {
		NSBeginAlertSheet (
						   LocalizedPrefString(@"Squeezebox Server has to be stopped before running the cleanup. Do you want to stop it now?", @""),
						   LocalizedPrefString(@"Run Cleanup", @""),
						   LocalizedPrefString(@"Cancel", @""),
						   nil, 
						   [[NSApplication sharedApplication] mainWindow], 
						   self, 
						   @selector(cleanupStopSC:returnCode:contextInfo:),
						   NULL, 
						   @"",
						   @""
		);

	}
	else {
		[self doRunCleanup];
	}
}

-(void)cleanupStopSC:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertDefaultReturn)
		[self doRunCleanup];
}

-(void)doRunCleanup
{
	[self jsonRequest:@"\"stopserver\""];

	NSString *pathToScript = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"cleanup.sh"];
	NSTask *cleanupTask = [NSTask launchedTaskWithLaunchPath:pathToScript arguments:[NSArray arrayWithObjects:[self getCleanupParams],nil]];
	[cleanupTask waitUntilExit];
}

-(NSString *)getCleanupParams
{
	NSString *params = @"";
	
	if ([cleanupPrefs state] > 0)
		params = [params stringByAppendingString:@" --prefs"];
		
	if ([cleanupCache state] > 0)
		params = [params stringByAppendingString:@" --cache"];
		
	return params;
}	


/* display SC server status in webkit frame */
-(void)tabView:(NSTabView *)sender didSelectTabViewItem:(NSTabViewItem *)item
{
	if ([[item identifier] isEqualToString:@"status"]) {
		[[statusView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:statusUrl]]];
	}
	else if ([[item identifier] isEqualToString:@"1"]) {
		[self updateMusicLibraryStats];
	}
}

/* JSON/RPC (CLI) helper */
-(NSDictionary *)jsonRequest:(NSString *)query
{
	SBJSON *parser = [SBJSON new];

	NSString *post = [NSString stringWithFormat:@"{\"id\":1,\"method\":\"slim.request\",\"params\":[\"\",[%@]]}", query];
	
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];	
	
	// set up our JSON/RPC request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:9000/jsonrpc.js"]];
	
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	// Perform request and get JSON back as a NSData object
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSDictionary *json = [parser objectWithString:json_string error:nil];
	
	if (json != nil) 
		json = [json objectForKey:@"result"];
	
	return json;
}

/* get localized string from Squeezebox Server; cache in a dictionary for future uses */
-(NSString *)getSCString:(NSString *)stringToken
{
	stringToken = [stringToken uppercaseString];
	NSString *s = [scStrings objectForKey:stringToken];
	
	// if we don't have that string in our dictionary yet, fetch it from SC
	if (s == nil)
	{
		// initialize entry with empty value to prevent querying string twice
		[scStrings setObject:@"" forKey:stringToken];
		
		NSDictionary *scString = [self jsonRequest:[NSString stringWithFormat:@"\"getstring\", \"%@\"", stringToken]];
 
		if (scString != nil) 
			s = [scString valueForKey:stringToken];

		// fall back to string token if lookup failed
		if (s == nil || [s isEqualToString:@""]) 
			s = stringToken;
		else 
			[scStrings setObject:s forKey:stringToken];
	}
	
	return s;
}

/* very simplistic method to read an atomic pref from the server.prefs file */
-(NSString *)getPref:(NSString *)pref fileName:(NSString*)prefsFileName
{
	if ([prefsFileName isEqualToString:@""]) {
		prefsFileName = prefsFile;
	}
	else {
		prefsFileName = [pluginPrefs stringByAppendingString:prefsFileName];
	}
	
	NSString *pathToPrefs = [self findFile:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) fileName:prefsFileName];
	
	if ([pathToPrefs length] == 0)
		pathToPrefs = [self findFile:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES) fileName:prefsFile];

	if ([pathToPrefs length] > 0) {
		NSString *fileString = [NSString stringWithContentsOfFile:pathToPrefs];
		NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
		
		if ([lines count] > 0)
		{
			int i;
			for (i = 0; i < [lines count]; i++)
			{
				NSArray *parts = [[lines objectAtIndex:i] componentsSeparatedByString:[NSString stringWithFormat:@"%@: ", pref]];

				NSMutableString *prefix = [NSMutableString stringWithFormat:@"%@", [parts objectAtIndex:0]];
				[prefix replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [prefix length])];
				
				if ([parts count] > 1 && [prefix isEqualToString:@""] ) {
					return [parts objectAtIndex:1];
				}
			}
		}
	}
	
	return @"";
}

-(NSString *)getPref:(NSString *)pref
{
	return [self getPref:pref fileName:@""];
}	

-(NSString *)findFile:(NSArray *)paths fileName:(NSString*)fileName
{
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	if ([paths count] > 0)
	{
		int i;
		for (i = 0; i < [paths count]; i++)
		{
			NSString *p;
			p = [[paths objectAtIndex:i] stringByAppendingPathComponent:fileName];
			
			if ([mgr fileExistsAtPath:p])
				return p;
		}
	}
	
	return nil;
}


@end

