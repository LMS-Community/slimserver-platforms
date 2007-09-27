//
//  SLIMRendezvousPublisher.h
//  SqueezeCenter
//
//  Created by Dave Nanian on Sat Jan 18 2003.
//  Copyright (c) 2003-2007 Logitech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SLIMRendezvousPublisher : NSObject
{
    Class Rendezvous;
    
    id httpNetService;			// Publishes the web server generically.
    id slimSpecificHTTPNetService;	// Publishes the web server specifically for name-independent discovery.
    id slimSpecificCLINetService;	// Publishes the CLI server specifically for name-independent discovery.
}

-(void)publish;
-(void)stop;

@end
