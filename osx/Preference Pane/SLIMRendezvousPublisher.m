//
//  SLIMRendezvousPublisher.m
//  SliMP3 Server
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

	    httpNetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_http._tcp." name:@"SLIMP3" port:9000];
	    [httpNetService setDelegate:self];

	    /*
	     **  Now, publish the SLIMP3 specific HTTP service for easy client discovery.
	     */

	    slimp3SpecificHTTPNetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_slimdevices_slimp3_http._tcp." name:@"SLIMP3" port:9000];
	    [slimp3SpecificHTTPNetService setDelegate:self];
	    
	    /*
	     **  Now, publish the SLIMP3 specific CLI service for easy client discovery.
	     */

	    slimp3SpecificCLINetService = [[Rendezvous alloc] initWithDomain:@"" type:@"_slimdevices_slimp3_cli._tcp." name:@"SLIMP3" port:9001];
	    [slimp3SpecificCLINetService setDelegate:self];
	}
    }
    return self;
}

-(void)dealloc
{
    [(NSNetService *) httpNetService release]; // nil if no rendezvous or publish failure: no error check necessary.
    httpNetService = nil;
    [(NSNetService *) slimp3SpecificHTTPNetService release];
    slimp3SpecificHTTPNetService = nil;
    [(NSNetService *) slimp3SpecificCLINetService release];
    slimp3SpecificCLINetService = nil;
}

-(void)publish
{
    [httpNetService publish];
    [slimp3SpecificHTTPNetService publish];
    [slimp3SpecificCLINetService publish];
}

-(void)stop
{
    [httpNetService stop];
    [slimp3SpecificHTTPNetService stop];
    [slimp3SpecificCLINetService stop];
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
    else if (sender == slimp3SpecificHTTPNetService)
    {
	[slimp3SpecificHTTPNetService release];
	slimp3SpecificHTTPNetService = nil;
    }
    else if (sender == slimp3SpecificCLINetService)
    {
	[slimp3SpecificCLINetService release];
	slimp3SpecificCLINetService = nil;
    }
}

- (void)netServiceDidStop:(NSNetService *)sender
{
    if (sender == httpNetService)
    {
	[httpNetService release];
	httpNetService = nil;
    }
    else if (sender == slimp3SpecificHTTPNetService)
    {
	[slimp3SpecificHTTPNetService release];
	slimp3SpecificHTTPNetService = nil;
    }
    else if (sender == slimp3SpecificCLINetService)
    {
	[slimp3SpecificCLINetService release];
	slimp3SpecificCLINetService = nil;
    }
}

@end
