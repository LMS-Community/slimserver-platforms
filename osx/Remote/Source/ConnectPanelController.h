//
//  ConnectPanelController.h
//  SliMP3 Remote
//
//  Created by Dave Camp on Sun Dec 22 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface ConnectPanelController : NSObject
{
    IBOutlet NSTextField *addressField;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSButton *connectButton;
    IBOutlet NSTextField *portField;
    IBOutlet NSWindow *window;
	
	BOOL		doConnect;
	NSString	*serverAddress;
}

- (void)awakeFromNib;
- (IBAction)address:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)port:(id)sender;

- (NSWindow*)window;
- (BOOL)doConnect;
- (NSString*)serverAddress;
- (int)serverPort;

@end
