//
//  Test.h
//  SlimServer Preference Tester
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright (c) 2002-2003 Slim Devices, Inc. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <Cocoa/Cocoa.h>

@interface Test : NSObject
{
    IBOutlet NSWindow *theWindow;
}
- (void) awakeFromNib;
@end
