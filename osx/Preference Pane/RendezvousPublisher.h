//
//  RendezvousPublisher.h
//  Squeezebox Server
//
//  Created by Dave Nanian on Sat Jan 18 2003.
//  Copyright 2003-2009 Logitech
//

#import <Foundation/Foundation.h>


@interface RendezvousPublisher : NSObject
{
    Class Rendezvous;
    
    id httpNetService;			// Publishes the web server generically.
    id SpecificHTTPNetService;	// Publishes the web server specifically for name-independent discovery.
    id SpecificCLINetService;	// Publishes the CLI server specifically for name-independent discovery.
}

-(void)publish;
-(void)stop;

@end
