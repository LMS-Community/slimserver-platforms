//
//  SLIMRendezvousPublisher.m
//  SlimServer
//
//  Created by Dave Nanian on Sat Jan 18 2003.
//  Copyright (c) 2003 Slim Devices, Inc. All rights reserved.
//

#import "SLIMRendezvousPublisher.h"

@implementation SLIMRendezvousPublisher
-(id)init
{
    if (self = [super init])
    {
	Rendezvous= NSClassFromString(@"NSNetService");

	if (Rendezvous != nil)
	{
	    /*
	     **  First, publish the web server generically for Safari, etc.
	     */

	    httpNetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_http._tcp." name:@"slimserver" port:9000];
	    [httpNetService setDelegate:self];

	    /*
	     **  Now, publish the SlimServer specific HTTP service for easy client discovery.
	     */

	    slimSpecificHTTPNetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_slimdevices_slimserver_http._tcp." name:@"slimserver" port:9000];
	    [slimSpecificHTTPNetService setDelegate:self];
	    
	    /*
	     **  Now, publish the SlimServer specific CLI service for easy client discovery.
	     */

	    slimSpecificCLINetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_slimdevices_slimserver_cli._tcp." name:@"slimserver" port:9001];
	    [slimSpecificCLINetService setDelegate:self];
	}
    }
    return self;
}

-(void)dealloc
{
    [(NSNetService *) httpNetService release]; // nil if no rendezvous or publish failure: no error check necessary.
    httpNetService = nil;
    [(NSNetService *) slimSpecificHTTPNetService release];
    slimSpecificHTTPNetService = nil;
    [(NSNetService *) slimSpecificCLINetService release];
    slimSpecificCLINetService = nil;
}

-(void)publish
{
    [httpNetService publish];
    [slimSpecificHTTPNetService publish];
    [slimSpecificCLINetService publish];
}

-(void)stop
{
    [httpNetService stop];
    [slimSpecificHTTPNetService stop];
    [slimSpecificCLINetService stop];
}

/*
 **  Rendezvous response methods:
 */

- (void)netServiceWillPublish:(NSNetService *)sender
{
    // yay; published
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
    NSLog(@"Publish failure with errorDict of %@.\n", errorDict);

    if (sender == httpNetService)
    {
	[httpNetService release];
	httpNetService = nil;
    }
    else if (sender == slimSpecificHTTPNetService)
    {
	[slimSpecificHTTPNetService release];
	slimSpecificHTTPNetService = nil;
    }
    else if (sender == slimSpecificCLINetService)
    {
	[slimSpecificCLINetService release];
	slimSpecificCLINetService = nil;
    }
}

- (void)netServiceDidStop:(NSNetService *)sender
{
    if (sender == httpNetService)
    {
	[httpNetService release];
	httpNetService = nil;
    }
    else if (sender == slimSpecificHTTPNetService)
    {
	[slimSpecificHTTPNetService release];
	slimSpecificHTTPNetService = nil;
    }
    else if (sender == slimSpecificCLINetService)
    {
	[slimSpecificCLINetService release];
	slimSpecificCLINetService = nil;
    }
}

@end
