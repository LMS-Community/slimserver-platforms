/*
 * Copyright (c) 2002 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * The contents of this file constitute Original Code as defined in and
 * are subject to the Apple Public Source License Version 1.2 (the
 * "License").  You may not use this file except in compliance with the
 * License.  Please obtain a copy of the License at
 * http://www.apple.com/publicsource and read it before using this file.
 * 
 * This Original Code and all software distributed under the License are
 * distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT.  Please see the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */
/*
 *  BrowserController.h
 *  IP Browser
 *
 *  Created by Rod Lopez <rod@apple.com> on Thu Jul 19 2001.
 *  Copyright (c) 2001 Apple Computer, Inc. All rights reserved.
 *
 *  This is experimental proof-of-concept code. Please excuse the mess.
 */

#import <Cocoa/Cocoa.h>
#import <DNSServiceDiscovery/DNSServiceDiscovery.h>

#include <netinet/in.h>

@interface BrowserController : NSObject
{
    IBOutlet id domainField;
    IBOutlet id nameField;
    IBOutlet id typeField;

    IBOutlet id serviceDisplayTable;
    IBOutlet id typeColumn;
    IBOutlet id nameColumn;
    IBOutlet id serviceTypeField;
    IBOutlet id serviceNameField;

    IBOutlet id ipAddressField;
    IBOutlet id portField;
    IBOutlet id textField;
    
    NSMutableArray *srvtypeKeys;
    NSMutableArray *srvnameKeys;
    NSMutableArray *domainKeys;
    NSMutableArray *nameKeys;
    NSString *Domain;
    NSString *SrvType;
    NSString *SrvName;
    NSString *Name;

    dns_service_discovery_ref 	browse_client;

}

- (IBAction)handleDomainClick:(id)sender;
- (IBAction)handleNameClick:(id)sender;
- (IBAction)handleTypeClick:(id)sender;

- (IBAction)connect:(id)sender;

- (IBAction)handleTableClick:(id)sender;
- (IBAction)removeSelected:(id)sender;
- (IBAction)addNewService:(id)sender;

- (IBAction)update:(NSString *)Type Domain:(NSString *)Domain;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;
- (IBAction)loadDomains:(id)sender;

- (void)updateBrowseWithResult:(int)type name:(NSString *)name type:(NSString *)resulttype domain:(NSString *)domain flags:(int)flags;
- (void)updateEnumWithResult:(int)resultType domain:(NSString *)domain flags:(int)flags;
- (void)resolveClientWithInterface:(struct sockaddr *)interface address:(struct sockaddr *)address txtRecord:(NSString *)txtRecord;

@end