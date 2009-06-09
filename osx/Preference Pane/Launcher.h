//
//  Launcher.h
//  SqueezeCenter
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright 2002-2007 Logitech
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
