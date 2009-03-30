//
//  ServerPref.h
//  SqueezeCenter
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright 2002-2008 Logitech
//

#import <PreferencePanes/PreferencePanes.h>
#import <WebKit/WebKit.h>

#define LocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

#define statusUrl @"http://localhost:9000/EN/settings/server/status.html?simple=1"

#define kNoAutomaticStartup 0
#define kStartupAtLogin 1
#define kStartupAtBoot 2

@interface Slim_ServerPref : NSPreferencePane 
{
    bool serverState;
    bool webState;
	
	IBOutlet NSTabView *prefsTab;

    IBOutlet NSButton *toggleServerButton;
    IBOutlet NSTextField *serverStateDescription;
    IBOutlet NSButton *webLaunchButton;
    IBOutlet NSButton *advLaunchButton;

    IBOutlet NSPopUpButton *startupType;
	IBOutlet WebView *statusView;

    AuthorizationRef myAuthorizationRef;
}

-(void)mainViewDidLoad;

-(bool)serverState;
-(void)setServerState:(bool)newState;
-(bool)webState;
-(void)setWebState:(bool)newState;
-(bool)changeAutoStartupFrom:(int)oldState to:(int)newState;

-(int)serverPID;
-(int)serverPort;
-(void)updateUI;
-(void)cliRequest;

-(IBAction)openWebInterface:(id)sender;
-(IBAction)openSettingsWebInterface:(id)sender;
-(IBAction)toggleServer:(id)sender;

-(IBAction)changeStartupPreference:(id)sender;

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;


@end
