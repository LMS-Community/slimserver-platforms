//
//  Installer.h
//  SqueezeCenter
//
//  Created by Dave Nanian on Fri Jan 03 2003.
//  Copyright 2003-2007 Logitech
//

#define LocalizedPrefString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]

#import "Installer_Prefix.h"

#define kInstallGlobal 0
#define kInstallLocal 1

@interface Slim_Installer : NSObject
{
    IBOutlet NSPopUpButton *installType;
    IBOutlet NSButton *installButton;
    IBOutlet NSWindow *waitSheet;
    IBOutlet NSWindow *installWindow;
    IBOutlet NSProgressIndicator *progressIndicator;

    bool foundGlobal;
    bool foundLocal;
    
    AuthorizationRef myAuthorizationRef;

    NSTask *preflightTask;
}

-(IBAction)doInstall:(id)sender;
-(IBAction)quitInstall:(id)sender;
-(IBAction)installTypeChanged:(id)sender;
-(IBAction)cancelWait:(id)sender;

@end
