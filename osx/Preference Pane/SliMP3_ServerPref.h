//
//  SliMP3_ServerPref.h
//  SliMP3 Server
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright (c) 2002-2003 Slim Devices, Inc. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

#define SLIMLocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

#define kSLIMNoAutomaticStartup 0
#define kSLIMStartupAtLogin 1
#define kSLIMStartupAtBoot 2

@interface SliMP3_ServerPref : NSPreferencePane 
{
    bool serverState;

    IBOutlet NSButton *toggleServerButton;
    IBOutlet NSTextField *serverStateDescription;
    IBOutlet NSImageView *serverStateImage;
    IBOutlet NSButton *webLaunchButton;
    IBOutlet NSButton *aboutButton;
    IBOutlet NSButton *updateFirmwareButton;
    IBOutlet NSTextField *firmwareVersion;

    IBOutlet NSWindow *aboutBox;
    IBOutlet NSWindow *updateFirmware;
    IBOutlet NSWindow *updatingFirmware;
    IBOutlet NSWindow *updateComplete;

    IBOutlet NSButton *doFirmwareUpdate;

    IBOutlet NSProgressIndicator *firmwareUpdateProgress;
    IBOutlet NSTextField *macAddress;
    IBOutlet NSTextField *ipAddress;
    IBOutlet NSTextField *updateCompleteMessage;

    IBOutlet NSPopUpButton *startupType;

    AuthorizationRef myAuthorizationRef;
    NSThread *firmwareUpdateThread;
}

-(void)mainViewDidLoad;

-(bool)serverState;
-(void)setServerState:(bool)newState;
-(bool)changeAutoStartupFrom:(int)oldState to:(int)newState;

-(int)serverPID;
-(void)updateUI;
-(void)firmwareUpdateThread:(id)userObject;

-(IBAction)openWebInterface:(id)sender;
-(IBAction)aboutSliMP3:(id)sender;
-(IBAction)dismissAboutBox:(id)sender;
-(IBAction)updateSliMP3Firmware:(id)sender;
-(IBAction)doFirmwareUpdate:(id)sender;
-(IBAction)cancelFirmwareUpdate:(id)sender;
-(IBAction)toggleServer:(id)sender;
-(IBAction)dismissUpdateComplete:(id)sender;

-(IBAction)changeStartupPreference:(id)sender;
@end
