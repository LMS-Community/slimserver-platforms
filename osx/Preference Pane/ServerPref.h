//
//  ServerPref.h
//  Logitech Media Server
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright 2002-2012 Logitech
//

#import <PreferencePanes/PreferencePanes.h>
#import <Foundation/NSPathUtilities.h>
#import <WebKit/WebKit.h>
#import <SBJson.h>

#define LocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

#define snPasswordPlaceholder @"SN_PASSWORD_PLACEHOLDER"
#define statusUrl @"http://localhost:9000/EN/settings/server/status.html?simple=1&os=osx"

#define versionFile @"Caches/Squeezebox/updates/server.version"
#define prefsFile @"Application Support/Squeezebox/server.prefs"
#define pluginPrefs @"Application Support/Squeezebox/plugin/"
#define logDir @"Logs/Squeezebox"

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

	IBOutlet NSButton *webLaunchButton;
	IBOutlet NSButton *advLaunchButton;
	IBOutlet NSPopUpButton *startupType;
	
	IBOutlet NSTextField *snUsername;
	IBOutlet NSSecureTextField *snPassword;
	IBOutlet NSButton *snCheckPassword;
	IBOutlet NSPopUpButton *snStatsOptions;
	
	IBOutlet NSButton *browsePlaylistFolder;
	IBOutlet NSTableView *mediaDirsTable;
	IBOutlet NSButton *addMediadir;
	IBOutlet NSButton *removeMediadir;
	IBOutlet NSTextField *playlistFolder;
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

-(IBAction)checkSNPassword:(id)sender;
-(IBAction)snCredentialsChanged:(id)sender;
-(NSDictionary *)saveSNCredentials;
-(IBAction)snStatsOptionChanged:(id)sender;
-(IBAction)openSNSubscription:(id)sender;
-(IBAction)openSNPasswordReminder:(id)sender;

-(IBAction)doAddMediadir:(id)sender;
-(IBAction)doRemoveMediadir:(id)sender;
-(void)getMediaDirs;
-(IBAction)doBrowsePlaylistFolder:(id)sender;
-(IBAction)useiTunesChanged:(id)sender;

-(IBAction)playlistFolderChanged:(id)sender;
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

-(IBAction)openWebInterface:(id)sender;
-(IBAction)openSettingsWebInterface:(id)sender;
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
