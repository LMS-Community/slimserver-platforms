/* DisplayTextController */

#import <Cocoa/Cocoa.h>

@interface DisplayTextController : NSObject
{
    IBOutlet NSButton *cancelButton;
    IBOutlet NSTextField *line1Field;
    IBOutlet NSTextField *line2Field;
    IBOutlet NSButton *okButton;
    IBOutlet NSWindow *window;
	
	BOOL	didOkay;
}

+ (NSArray*)promptUser;

- (IBAction)cancel:(id)sender;
- (IBAction)okay:(id)sender;

@end
