//
//  ConnectPanelController.m
//  SliMP3 Remote
//
//  Created by Dave Camp on Sun Dec 22 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//

#import "ConnectPanelController.h"

@implementation ConnectPanelController

- (void)dealloc
{
	[serverAddress release];
	serverAddress = nil;
}

// --------------------------------------------------------------------------------

- (void)awakeFromNib
{
	NSString	*string = [[NSUserDefaults standardUserDefaults] stringForKey:@"ServerAddress"];
	if (string)
		[addressField setStringValue:string];
}

// --------------------------------------------------------------------------------

- (IBAction)address:(id)sender
{
	
}

// --------------------------------------------------------------------------------

- (IBAction)cancel:(id)sender
{
	[NSApp stopModal];
}

// --------------------------------------------------------------------------------

- (IBAction)connect:(id)sender
{
	NSHost		*host = nil;
	NSString	*string = [addressField stringValue];
	
	host = [NSHost hostWithAddress:string];
	if (!host)
		host = [NSHost hostWithName:string];
	if (!host)
	{
		NSRunAlertPanel(@"Unable to locate server.", @"No such host \"%@\".", nil, nil, nil, string);
	}
	else
	{
		serverAddress = [[host address] retain];
		
		// Save this as the default
		[[NSUserDefaults standardUserDefaults] setObject:string forKey:@"ServerAddress"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	
		doConnect = YES;
		[NSApp stopModal];
	}
}

// --------------------------------------------------------------------------------

- (NSWindow*)window
{
	return (window);
}

// --------------------------------------------------------------------------------

- (IBAction)port:(id)sender
{
	
}

// --------------------------------------------------------------------------------

- (BOOL)doConnect
{
	return (doConnect);
}

// --------------------------------------------------------------------------------

- (NSString*)serverAddress
{
	return serverAddress;
}

// --------------------------------------------------------------------------------

- (int)serverPort
{
	return [portField intValue];
}

@end
