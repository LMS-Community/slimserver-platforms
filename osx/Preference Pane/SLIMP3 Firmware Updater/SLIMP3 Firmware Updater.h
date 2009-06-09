//
//  SLIMP3 Firmware Updater.m
//  SqueezeCenter
//
//  Created by Dave Nanian on Sun Oct 26 2003.
//  Copyright 2003-2007 Logitech
//

#import <Cocoa/Cocoa.h>

#define SLIMLocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

@interface SLIMP3_Firmware_Updater : NSObject
{
    IBOutlet NSButton *updateFirmwareButton;
    IBOutlet NSTextField *firmwareVersion;
    
    IBOutlet NSWindow *updateFirmware;
    IBOutlet NSWindow *updatingFirmware;
    IBOutlet NSWindow *updateComplete;
    
    IBOutlet NSButton *doFirmwareUpdate;
    
    IBOutlet NSProgressIndicator *firmwareUpdateProgress;
    IBOutlet NSTextField *macAddress;
    IBOutlet NSTextField *ipAddress;
    IBOutlet NSTextField *updateCompleteMessage;
    IBOutlet NSWindow *updaterMainWindow;
    
    AuthorizationRef myAuthorizationRef;

    NSThread *firmwareUpdateThread;
}

-(void)updateUI;
-(void)firmwareUpdateThread:(id)userObject;

-(IBAction)updateSLIMP3Firmware:(id)sender;
-(IBAction)dismissUpdateComplete:(id)sender;

-(IBAction)quitFirmwareUpdater:(id)sender;

@end
