//
//  SLIMP3 Installer.h
//  SliMP3 Server
//
//  Created by Dave Nanian on Fri Jan 03 2003.
//  Copyright (c) 2003 Slim Devices, Inc. All rights reserved.
//

#import "Installer_Prefix.h"

#define kInstallGlobal 0
#define kInstallLocal 1

@interface SLIMP3_Installer : NSObject
{
    IBOutlet NSPopUpButton *installType;
    IBOutlet NSButton *installButton;
    IBOutlet NSWindow *waitSheet;
    IBOutlet NSWindow *installWindow;
    IBOutlet NSProgressIndicator *progressIndicator;

    bool foundSLIMP3Global;
    bool foundSLIMP3Local;
    
    AuthorizationRef myAuthorizationRef;

    NSTask *preflightTask;
}

-(IBAction)doInstall:(id)sender;
-(IBAction)quitInstall:(id)sender;
-(IBAction)installTypeChanged:(id)sender;
-(IBAction)cancelWait:(id)sender;

@end
