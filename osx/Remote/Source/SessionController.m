//
//  SessionController.m
//  SliMP3Remote
//
//  Created by Dave Camp on Thu Jan 16 2003.
//  Copyright (c) 2003 David Camp Jr.. All rights reserved.
//

#import "SessionController.h"
#import "MainWindowController.h"
#import "ConnectPanelController.h"

@implementation SessionController

- (id)init
{
	self = [super init];
	sessions = [[NSMutableArray alloc] init];
	
	return self;
}

// --------------------------------------------------------------------------------

- (void)dealloc
{
	[sessions release];
	sessions = NULL;
}

// --------------------------------------------------------------------------------

- (void)awakeFromNib
{
	[self newSession:self];
}

// --------------------------------------------------------------------------------

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	return YES;
}

// --------------------------------------------------------------------------------

- (void)newSession:(id)sender
{
	// Find out what server to connect to
	ConnectPanelController	*connectPanel = [[[ConnectPanelController alloc] init] autorelease];
	BOOL		doConnect = NO;
	NSString	*serverAddress = nil;
	int			serverPort = 0;

	if ([NSBundle loadNibNamed:@"ConnectPanel" owner:connectPanel])
	{
		[NSApp runModalForWindow: [connectPanel window]];

		// Fun modal stuff is going on here...
		
		// See if the user canceled
		if ([connectPanel doConnect])
		{
			doConnect = YES;
			serverAddress = [[[connectPanel serverAddress] retain] autorelease];
			serverPort = [connectPanel serverPort];
		}
			
		[[connectPanel window] orderOut: self];
	}

	if (doConnect)
	{
		MainWindowController	*controller = [[[MainWindowController alloc] initWithServer:serverAddress port:serverPort] autorelease];
	
		if ([NSBundle loadNibNamed:@"LargeWindow" owner:controller])
		{
			[sessions addObject:controller];
			[controller setNextResponder:self];
		}
	}
}

// --------------------------------------------------------------------------------

- (IBAction)about:(id)sender
{
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"Version", nil, nil];
	[NSApp orderFrontStandardAboutPanelWithOptions:dict];
}

@end
