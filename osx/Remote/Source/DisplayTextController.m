#import "DisplayTextController.h"

// --------------------------------------------------------------------------------

@implementation DisplayTextController

- (IBAction)cancel:(id)sender
{
	[NSApp stopModal];
}

// --------------------------------------------------------------------------------

- (IBAction)okay:(id)sender
{
	didOkay = YES;
	[NSApp stopModal];
}

// --------------------------------------------------------------------------------

- (BOOL)didOkay
{
	return didOkay;
}

// --------------------------------------------------------------------------------

- (NSWindow*)window
{
	return window;
}

// --------------------------------------------------------------------------------

- (NSString*)line1
{
	return [line1Field stringValue];
}

// --------------------------------------------------------------------------------

- (NSString*)line2
{
	return [line2Field stringValue];
}

// --------------------------------------------------------------------------------

+ (NSArray*)promptUser
{
	DisplayTextController	*panel = [[[DisplayTextController alloc] init] autorelease];
	NSArray *result = nil;
	
	if ([NSBundle loadNibNamed:@"DisplayTextPanel" owner:panel])
	{
		[NSApp runModalForWindow: [panel window]];

		// Fun modal stuff is going on here...
		
		// See if the user did something
		if ([panel didOkay])
			result = [NSArray arrayWithObjects:[panel line1], [panel line2]];
			
		[[panel window] close];
	}
	
	return result;
}

@end
