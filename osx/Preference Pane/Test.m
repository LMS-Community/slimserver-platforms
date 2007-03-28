//
//  Test.m
//  SlimServer Preference Tester
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright (c) 2002-2005 Logitech. All rights reserved.
//

#import "Test.h"

int main(int argc, const char *argv[])
{
    return NSApplicationMain(argc, argv);
}

@implementation Test
- (void) awakeFromNib
{
    NSRect aRect;
    NSString *pathToPrefPaneBundle;
    NSBundle *prefBundle;
    Class prefPaneClass;
    NSPreferencePane *prefPaneObject;
    NSView *prefView;
    pathToPrefPaneBundle = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SlimServer.prefPane"];
    prefBundle = [NSBundle bundleWithPath: pathToPrefPaneBundle];
    prefPaneClass = [prefBundle principalClass];
    prefPaneObject = [[prefPaneClass alloc] initWithBundle: prefBundle];
    
    if([prefPaneObject loadMainView])
    {
	[prefPaneObject willSelect];
	prefView = [prefPaneObject mainView];
	/* Add view to window */
	aRect = [prefView frame];
	// Yeah, this is awful. Deal...
	aRect.size.height = aRect.size.height + 22;
	[theWindow setFrame: aRect display: YES];
	[[theWindow contentView] addSubview: prefView];
	[prefPaneObject didSelect];
    }
    else
    {
	/* Nothing much to do here */
	NSLog(@"Error loading SlimServer.prefPane.");
    }
}
@end
