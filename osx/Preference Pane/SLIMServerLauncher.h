//
//  SLIMServerLauncher.h
//  SliMP3 Server
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright (c) 2002-2003 Slim Devices, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef LAUNCHER_RENDEZVOUS
#include "SLIMRendezvousPublisher.h"
#endif

@interface SLIMServerLauncher : NSApplication
{
#ifdef LAUNCHER_RENDEZVOUS
    SLIMRendezvousPublisher	*rendezvousPublisher;
#endif
}

@end
