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
/* RegistrationController */

#import <Cocoa/Cocoa.h>

@interface RegistrationController : NSObject
{
    IBOutlet NSTableColumn 	*typeColumn;
    IBOutlet NSTableColumn 	*nameColumn;
    IBOutlet NSTableColumn 	*portColumn;
    IBOutlet NSTableColumn 	*domainColumn;
    IBOutlet NSTableColumn 	*textColumn;

    IBOutlet NSTableView	*serviceDisplayTable;

    IBOutlet NSTextField	*serviceTypeField;
    IBOutlet NSTextField	*serviceNameField;
    IBOutlet NSTextField	*servicePortField;
    IBOutlet NSTextField	*serviceDomainField;
    IBOutlet NSTextField	*serviceTextField;
    
    NSMutableArray		*srvtypeKeys;
    NSMutableArray		*srvnameKeys;
    NSMutableArray		*srvportKeys;
    NSMutableArray		*srvdomainKeys;
    NSMutableArray		*srvtextKeys;

    NSMutableDictionary		*registeredDict;
}

- (IBAction)registerService:(id)sender;
- (IBAction)unregisterService:(id)sender;

- (IBAction)addNewService:(id)sender;
- (IBAction)removeSelected:(id)sender;

@end
