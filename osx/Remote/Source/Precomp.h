/*
 *  Precomp.h
 *  SliMP3 Remote
 *
 *  Created by Dave Camp on Sat Dec 07 2002.
 *  Copyright (c) 2002 David Camp Jr. All rights reserved.
 *
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <Carbon/Carbon.h>

#if !defined(__cplusplus)
	#import <Cocoa/Cocoa.h>
#endif

#if DEBUG
	#define Debug(a)	{a;}
#else
	#define Debug(a)
#endif
