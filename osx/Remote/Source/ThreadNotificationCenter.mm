//
//  ThreadNotificationCenter.m
//  SliMP3 Remote
//
//  Created by Dave Camp on Fri Dec 27 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//

/*
	Notes:
		This class derives from and expands on the new example code provided in the Dec 2002 Developer Tools package: <file:///Developer/Documentation/Cocoa/TasksAndConcepts/ProgrammingTopics/Notifications/index.html> "Delivering Notifications To Particular Threads"
		
		It solves the problem of getting notifications from one thread to another, waking up the receiving thread, and delivering the notification at idle time, much like an OS event.
		
		An instance of ThreadNotificationCenter should be created by the thread that wants to recieve notifications from other threads. Once created, the ThreadNotificationCenter can be passed to as many other threads as needed. The other threads can treat ThreadNotificationCenter as any other NoticiationCenter object and post notifications at their leisure. They will be delivered asynchronously to the thread that created the ThreadNotificationCenter at run loop idle time (i.e. when the run loop is not in the middle of processing another input source).
		
		The recieving thread simply add's itself as an observer to ThreadNotificationCenter as it would any other notification center.
		
	Future Improvements:
		ThreadNotificationCenter is hard wired to post at idle and coaslesce by name and sender. These should be options configurable at init time.
*/

#import "ThreadNotificationCenter.h"


@implementation ThreadNotificationCenter

// --------------------------------------------------------------------------------
// This is called to signal us that a message has been queued up by the other thread

- (void)handleMachMessage:(void *)msg
{
    [notificationLock lock];
    while ([notificationArray count])
	{
        NSNotification *note = [[notificationArray objectAtIndex:0] retain];
        [notificationArray removeObjectAtIndex:0];
        [notificationLock unlock];
		
		// Post the notification into the default queue
		[notificationQueue enqueueNotification:note postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:NULL]; 
        [note release];
		
        [notificationLock lock];
    };
    [notificationLock unlock];
}

// --------------------------------------------------------------------------------
// This should be called from the main thread (i.e. the thread that wants to receive 
// notifications from another thread

- (id)init
{
	self = [super init];

	notificationArray  = [[NSMutableArray alloc] init];
	notificationLock   = [[NSLock alloc] init];
	notificationThread = [[NSThread currentThread] retain];
	notificationQueue = [[NSNotificationQueue alloc] initWithNotificationCenter:self];
	
	notificationPort = [[NSMachPort alloc] init];
	[notificationPort setDelegate:self];
	[[NSRunLoop currentRunLoop] addPort:notificationPort forMode:(NSString*) kCFRunLoopCommonModes];
	
	return self;
}

// --------------------------------------------------------------------------------

- (void)dealloc
{
	[notificationLock lock];
	{
		[notificationArray release];
		notificationArray = nil;

		[notificationThread release];
		notificationThread = nil;
		
		// It's not terribly clear if I'm just supposed to invalidate the port
		// or also release it...
		[notificationPort invalidate];
		[notificationPort release];
		notificationPort = nil;
	}
	[notificationLock unlock];
	[notificationLock release];
	notificationLock = nil;
}

// --------------------------------------------------------------------------------
// Post a notification. Notes from the original thread pass through as expected.
// Notes from other threads are queued up and processed later on the original thread.

- (void)postNotification:(NSNotification *)note
{
	if ([NSThread currentThread] != notificationThread)
	{
		// Forward the notification to the correct thread
		[notificationLock lock];
		[notificationArray addObject:note];
		[notificationLock unlock];
		[notificationPort sendBeforeDate:[NSDate date]
				components:nil
				from:nil
				reserved:0];
	}
	else
	{
		// We are on the right thread, pass the notification through
		[super postNotification:note];
	}
}

// --------------------------------------------------------------------------------

- (void)postNotificationName:(NSString *)aName object:(id)anObject
{
	[self postNotification:[NSNotification notificationWithName:aName object:anObject]];
}

// --------------------------------------------------------------------------------

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
	[self postNotification:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

@end
