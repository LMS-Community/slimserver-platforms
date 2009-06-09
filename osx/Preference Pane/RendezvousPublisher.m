//
//  RendezvousPublisher.m
//  SqueezeCenter
//
//  Created by Dave Nanian on Sat Jan 18 2003.
//  Copyright 2003-2007 Logitech
//

#import "RendezvousPublisher.h"

@implementation RendezvousPublisher
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
	     **  Now, publish the SqueezeCenter specific HTTP service for easy client discovery.
	     */

	    SpecificHTTPNetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_slimdevices_slimserver_http._tcp." name:@"slimserver" port:9000];
	    [SpecificHTTPNetService setDelegate:self];
	    
	    /*
	     **  Now, publish the SqueezeCenter specific CLI service for easy client discovery.
	     */

	    SpecificCLINetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_slimdevices_slimserver_cli._tcp." name:@"slimserver" port:9001];
	    [SpecificCLINetService setDelegate:self];
	}
    }
    return self;
}

-(void)dealloc
{
    [(NSNetService *) httpNetService release]; // nil if no rendezvous or publish failure: no error check necessary.
    httpNetService = nil;
    [(NSNetService *) SpecificHTTPNetService release];
    SpecificHTTPNetService = nil;
    [(NSNetService *) SpecificCLINetService release];
    SpecificCLINetService = nil;
}

-(void)publish
{
    [httpNetService publish];
    [SpecificHTTPNetService publish];
    [SpecificCLINetService publish];
}

-(void)stop
{
    [httpNetService stop];
    [SpecificHTTPNetService stop];
    [SpecificCLINetService stop];
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
    else if (sender == SpecificHTTPNetService)
    {
	[SpecificHTTPNetService release];
	SpecificHTTPNetService = nil;
    }
    else if (sender == SpecificCLINetService)
    {
	[SpecificCLINetService release];
	SpecificCLINetService = nil;
    }
}

- (void)netServiceDidStop:(NSNetService *)sender
{
    if (sender == httpNetService)
    {
	[httpNetService release];
	httpNetService = nil;
    }
    else if (sender == SpecificHTTPNetService)
    {
	[SpecificHTTPNetService release];
	SpecificHTTPNetService = nil;
    }
    else if (sender == SpecificCLINetService)
    {
	[SpecificCLINetService release];
	SpecificCLINetService = nil;
    }
}

@end
