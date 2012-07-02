//
//  ServerPref.h
//  UE Music Library
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright 2002-2012 Logitech
//

#import <PreferencePanes/PreferencePanes.h>
#import <Foundation/NSPathUtilities.h>
#import <WebKit/WebKit.h>
#import <SBJson.h>

#define LocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

#define statusUrl @"http://localhost:9000/EN/settings/server/status.html?simple=1&os=osx"

#define versionFile @"Caches/UEMusicLibrary/updates/server.version"
#define prefsFile @"Application Support/UEMusicLibrary/server.prefs"
#define pluginPrefs @"Application Support/UEMusicLibrary/plugin/"
#define logDir @"Logs/UEMusicLibrary"

#define kNoAutomaticStartup 0
#define kStartupAtLogin 1
#define kStartupAtBoot 2

@interface Slim_ServerPref : NSPreferencePane 
{
	bool serverState;
	bool webState;
	bool isScanning;
	
	NSTimer *updateTimer;
	
	NSMutableDictionary *scStrings;
	
	IBOutlet NSTabView *prefsTab;

	IBOutlet NSButton *toggleServerButton;
	IBOutlet NSTextField *serverStateLabel;
	IBOutlet NSTextField *musicLibraryStats;
	IBOutlet NSTextField *scVersion;

	IBOutlet NSPopUpButton *startupType;
	
	IBOutlet NSTableView *mediaDirsTable;
	IBOutlet NSButton *addMediadir;
	IBOutlet NSButton *removeMediadir;
	IBOutlet NSButton *useiTunes;
	
	IBOutlet NSPopUpButton *scanModeOptions;
	IBOutlet NSButton *rescanButton;
	IBOutlet NSProgressIndicator *scanSpinny;
	IBOutlet NSProgressIndicator *scanProgress;
	IBOutlet NSTextField *scanProgressDesc;
	IBOutlet NSTextField *scanProgressDetail;
	IBOutlet NSTextField *scanProgressError;
	IBOutlet NSTextField *scanProgressTime;
	IBOutlet NSTextField *musicLibraryName;
	
	IBOutlet NSButton *cleanupPrefs;
	IBOutlet NSButton *cleanupCache;
	IBOutlet NSButton *doCleanup;
	
	IBOutlet WebView *statusView;

	AuthorizationRef myAuthorizationRef;
	NSMutableData *receivedData;
}

-(void)mainViewDidLoad;
-(void)showRevision;

-(bool)serverState;
-(void)setServerState:(bool)newState;
-(bool)webState;
-(void)setWebState:(bool)newState;
-(bool)changeAutoStartupFrom:(int)oldState to:(int)newState;
-(IBAction)libraryNameChanged:(id)sender;
-(void)updateMusicLibraryStats;
-(void)_updateMusicLibraryStats:(NSDictionary *)libraryStats;

-(IBAction)doAddMediadir:(id)sender;
-(IBAction)doRemoveMediadir:(id)sender;
-(void)getMediaDirs;
-(IBAction)useiTunesChanged:(id)sender;

-(int)numberOfRowsInTableView:(NSTabView *)tv;
-(id)tableView:(NSTabView *)tv objectValueForTableColumn:(NSTableColumn *)dirsColumn row:(int)rowIndex;
-(IBAction)saveMediadirs:(id)sender;
NSMutableArray *mediaDirs;

-(IBAction)rescan:(id)sender;
-(void)scanPoll;
-(void)_scanPollResponse:(NSDictionary *)pollResult;

-(int)serverPID;
-(int)serverPort;
-(void)updateUI;

-(IBAction)toggleServer:(id)sender;
-(NSString *)getUpdateInstaller;
-(void)checkUpdateInstaller;

-(IBAction)changeStartupPreference:(id)sender;

-(IBAction)showServerLog:(id)sender;
-(IBAction)showScannerLog:(id)sender;
-(IBAction)selectLogSet:(id)sender;
-(void)showLog:(NSString *)whichLog;

/* cleanup tab */
-(IBAction)cleanupBtnHandler:(id)sender;
-(void)doRunCleanup;
-(NSString *)getCleanupParams;

-(void)asyncJsonRequest:(NSString *)query;
-(void)asyncJsonRequest:(NSString *)query timeout:(int)timeout;
-(NSDictionary *)jsonRequest:(NSString *)query;
-(NSMutableURLRequest *)_baseRequest:(NSString *)query;
-(NSMutableURLRequest *)_baseRequest:(NSString *)query port:(int)port;
-(NSDictionary *)_parseJsonResponse:(NSData *)data;
-(NSString *)getSCString:(NSString *)stringToken;
-(NSString *)getPref:(NSString *)pref fileName:(NSString *)prefsFileName;
-(NSString *)getPref:(NSString *)pref;

-(NSString *)findFile:(NSArray *)paths fileName:(NSString *)fileName;

@end
