//
//  MainWindowController.h
//  SliMP3 Remote
//
//  Created by Dave Camp on Sun Dec 22 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SliMP3Connection.h"
#import "ThreadNotificationCenter.h"

@interface MainWindowController : NSWindowController
{
    IBOutlet NSButton *previousButton;
    IBOutlet NSButton *playButton;
    IBOutlet NSButton *nextButton;
    IBOutlet NSSlider *volumeSlider;

    IBOutlet NSButton *powerButton;

    IBOutlet NSTableView *tracksView;

    IBOutlet NSTextField *trackField;
    IBOutlet NSTextField *timeField;
	
    IBOutlet NSButton *shuffleButton;
    IBOutlet NSButton *repeatButton;

    IBOutlet NSTextField *statusField;

    IBOutlet NSProgressIndicator *spinner;

	SliMP3Connection			*connection;
	ThreadNotificationCenter	*connectionNotifications;
	
	NSTimer		*statusTimer;
	NSImage		*pauseIcon;
	NSImage		*playIcon;
	NSImage		*pauseSmallIcon;
	NSImage		*playSmallIcon;
	NSImage		*speakerIcon;
	
	PlayerMode	mode;
	NSArray		*playlist;
	int			track;

	NSString	*serverAddress;
	int			serverPort;
	
	BOOL		powerOn;
	BOOL		windowIsSmall;
	BOOL		windowIsZooming;
}

- (id)init;
- (id)initWithServer:(NSString*)address port:(int)port;
- (void)dealloc;

- (void)awakeFromNib;

- (IBAction)previousTrack:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)power:(id)sender;
- (IBAction)sleep:(id)sender;
- (IBAction)volume:(id)sender;
- (IBAction)shuffle:(id)sender;
- (IBAction)repeat:(id)sender;
- (IBAction)repeatOne:(id)sender;
- (IBAction)repeatAll:(id)sender;
- (IBAction)setDisplayText:(id)sender;

@end

@interface MainWindowController(NSTableDataSource)
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
@end
