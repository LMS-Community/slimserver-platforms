//
//  ServerPref.h
//  SqueezeCenter
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright 2002-2008 Logitech
//

#import <PreferencePanes/PreferencePanes.h>
#import <Foundation/NSPathUtilities.h>
#import <WebKit/WebKit.h>
#import <JSON/JSON.h>

#define LocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

#define statusUrl @"http://localhost:9000/EN/settings/server/status.html?simple=1"
#define updateCheckUrl @"http://update.squeezenetwork.com/update/?version=%@&geturl=1&os=osx"

#define versionFile @"Caches/SqueezeCenter/updates/squeezecenter.version"
#define prefsFile @"Application Support/SqueezeCenter/server.prefs"
#define logDir @"Logs/SqueezeCenter"

#define kNoAutomaticStartup 0
#define kStartupAtLogin 1
#define kStartupAtBoot 2

@interface Slim_ServerPref : NSPreferencePane 
{
	bool serverState;
	bool webState;
	bool isScanning;
	
	bool hasUpdateInstaller;
	NSString *updateURL;
	
	NSMutableDictionary *scStrings;
	
	IBOutlet NSTabView *prefsTab;

	IBOutlet NSButton *toggleServerButton;
	IBOutlet NSTextField *serverStateDescription;
	IBOutlet NSButton *webLaunchButton;
	IBOutlet NSButton *advLaunchButton;
	IBOutlet NSPopUpButton *startupType;
	IBOutlet NSTextField *updateDescription;
	IBOutlet NSButton *updateButton;
	
	IBOutlet NSPopUpButton *scanModeOptions;
	IBOutlet NSButton *rescanButton;
	IBOutlet NSProgressIndicator *scanSpinny;
	IBOutlet NSProgressIndicator *scanProgress;
	IBOutlet NSTextField *scanProgressDesc;
	IBOutlet NSTextField *scanProgressDetail;
	IBOutlet NSTextField *scanProgressError;
	IBOutlet NSTextField *scanProgressTime;
	
	IBOutlet NSButton *cleanupPrefs;
	IBOutlet NSButton *cleanupFilecache;
	IBOutlet NSButton *cleanupMysql;
	IBOutlet NSButton *cleanupLogs;
	IBOutlet NSButton *cleanupCache;
	IBOutlet NSButton *cleanupAll;
	IBOutlet NSButton *doCleanup;
	IBOutlet NSTextField *cleanupHelpShutdown;
	
	IBOutlet WebView *statusView;

    AuthorizationRef myAuthorizationRef;
}

-(void)mainViewDidLoad;

-(bool)serverState;
-(void)setServerState:(bool)newState;
-(bool)webState;
-(void)setWebState:(bool)newState;
-(bool)changeAutoStartupFrom:(int)oldState to:(int)newState;

-(IBAction)rescan:(id)sender;
-(void)scanPoll;

-(int)serverPID;
-(int)serverPort;
-(void)updateUI;

-(IBAction)openWebInterface:(id)sender;
-(IBAction)openSettingsWebInterface:(id)sender;
-(IBAction)toggleServer:(id)sender;
-(IBAction)updateBtnHandler:(id)sender;
-(NSString *)checkUpdateInstaller;
-(void)installUpdate;

-(IBAction)changeStartupPreference:(id)sender;

-(IBAction)showServerLog:(id)sender;
-(IBAction)showScannerLog:(id)sender;
-(void)showLog:(NSString *)whichLog;

/* cleanup tab */
-(IBAction)cleanupBtnHandler:(id)sender;
-(void)doRunCleanup;
-(NSString *)getCleanupParams;

-(NSDictionary *)jsonRequest:(NSString *)query;
-(NSString *)getSCString:(NSString *)stringToken;
//-(NSString *)getPref:(NSString *)pref;

-(NSString *)findFile:(NSArray *)paths fileName:(NSString *)fileName;

@end
