//
//  ThreadNotificationCenter.h
//  SliMP3 Remote
//
//  Created by Dave Camp on Fri Dec 27 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ThreadNotificationCenter : NSNotificationCenter
{
	NSNotificationQueue	*notificationQueue;
	NSMutableArray		*notificationArray;
	NSThread			*notificationThread;
	NSLock				*notificationLock;
	NSMachPort			*notificationPort;
}

- (void)postNotification:(NSNotification *)note;
- (void)postNotificationName:(NSString *)aName object:(id)anObject;
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
