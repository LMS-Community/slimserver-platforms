//
//  Slim Installer.h
//  Slim Server
//
//  Created by Dave Nanian on Fri Jan 03 2003.
//  Copyright (c) 2003 Slim Devices, Inc. All rights reserved.
//

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

    bool foundSlimGlobal;
    bool foundSlimLocal;
    
    AuthorizationRef myAuthorizationRef;

    NSTask *preflightTask;
}

-(IBAction)doInstall:(id)sender;
-(IBAction)quitInstall:(id)sender;
-(IBAction)installTypeChanged:(id)sender;
-(IBAction)cancelWait:(id)sender;

@end
