//
//  ServerPref.h
//  SqueezeCenter
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright 2002-2007 Logitech
//

#import <PreferencePanes/PreferencePanes.h>

#define LocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

#define kNoAutomaticStartup 0
#define kStartupAtLogin 1
#define kStartupAtBoot 2

@interface Slim_ServerPref : NSPreferencePane 
{
    bool serverState;

    IBOutlet NSButton *toggleServerButton;
    IBOutlet NSTextField *serverStateDescription;
    IBOutlet NSButton *webLaunchButton;

    IBOutlet NSPopUpButton *startupType;

    AuthorizationRef myAuthorizationRef;
}

-(void)mainViewDidLoad;

-(bool)serverState;
-(void)setServerState:(bool)newState;
-(bool)changeAutoStartupFrom:(int)oldState to:(int)newState;

-(int)serverPID;
-(void)updateUI;

-(IBAction)openWebInterface:(id)sender;
-(IBAction)toggleServer:(id)sender;

-(IBAction)changeStartupPreference:(id)sender;
@end
