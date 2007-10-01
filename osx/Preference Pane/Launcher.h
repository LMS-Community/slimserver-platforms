//
//  Launcher.h
//  SqueezeCenter
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright (c) 2002-2007 Logitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef LAUNCHER_RENDEZVOUS
#include "RendezvousPublisher.h"
#endif

@interface Launcher : NSApplication
{
#ifdef LAUNCHER_RENDEZVOUS
    RendezvousPublisher	*rendezvousPublisher;
#endif
}

@end
