//
//  SLIMP3 Firmware Updater.m
//  Slim Server
//
//  Created by Dave Nanian on Sun Oct 26 2003.
//  Copyright (c) 2003 Slim Devices, Inc. All rights reserved.
//

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#import "SLIMP3 Firmware Updater.h"
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/param.h>
#include <unistd.h>
#include <signal.h>

@implementation SLIMP3_Firmware_Updater

-(void)awakeFromNib
{
    [firmwareUpdateProgress setUsesThreadedAnimation:YES];
    
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
}

-(IBAction)updateSLIMP3Firmware:(id)sender
{
    /*
     **  First, preauthorize the user. If they can't authorize, they can't update the firmware. The updater is
     ** going to free the token.
     */

    if ([self authorizeUser] == NO)
	return;
    
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
    
    /*
     **  Set the progress to 0, and display the window. We've set the bar to 120 "increments" to allow
     ** second-by-second updates up to the supposed two minute maximum. Cancel is not supported once
     ** the process has been spawned.
     */
    
    [firmwareUpdateProgress setDoubleValue:(double)0];
    [NSApp beginSheet:updatingFirmware modalForWindow:updaterMainWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
    
    /*
     **  Spin this out into its own thread to allow the progress bar to be updated.
     */
    
    [NSThread detachNewThreadSelector:@selector(firmwareUpdateThread:) toTarget:self withObject:nil];
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
    
    [NSApp beginSheet:updateComplete modalForWindow:updaterMainWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(IBAction)quitFirmwareUpdater:(id)sender;
{
    [[NSApplication sharedApplication] terminate:nil];
}

@end
