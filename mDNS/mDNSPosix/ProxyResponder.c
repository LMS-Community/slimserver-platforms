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

#include <stdio.h>			// For printf()
#include <stdlib.h>			// For exit() etc.
#include <string.h>			// For strlen() etc.
#include <unistd.h>			// For select()
#include <errno.h>			// For errno, EINTR
#include <arpa/inet.h>		// For inet_addr()
#include <netinet/in.h>		// For INADDR_NONE
#include <netdb.h>			// For gethostbyname()

#include "mDNSClientAPI.h"  // Defines the interface to the client layer above
#include "mDNSPosix.h"      // Defines the specific types needed to run mDNS on this platform
#include "ExampleClientApp.h"

//*************************************************************************************************************
// Globals
static mDNS mDNSStorage;       // mDNS core uses this to store its globals
static mDNS_PlatformSupport PlatformStorage;  // Stores this platform's globals

//*************************************************************************************************************
// Proxy Host Registration

typedef struct
	{
	mDNSIPAddr ip;
	domainlabel hostlabel;		// Conforms to standard DNS letter-digit-hyphen host name rules
	ResourceRecord RR_A;		// 'A' (address) record for our ".local" name
	ResourceRecord RR_PTR;		// PTR (reverse lookup) record
	} ProxyHost;

mDNSlocal void HostNameCallback(mDNS *const m, ResourceRecord *const rr, mStatus result)
	{
	ProxyHost *f = (ProxyHost*)rr->Context;
	if (result == mStatus_NoError)
		debugf("Host name successfully registered: %##s", &rr->name);
	else
		{
		debugf("Host name conflict for %##s", &rr->name);
		mDNS_Deregister(m, &f->RR_A);
		mDNS_Deregister(m, &f->RR_PTR);
		exit(-1);
		}
	}

mDNSlocal mStatus mDNS_RegisterProxyHost(mDNS *m, ProxyHost *p)
	{
	char buffer[32];
	
	mDNS_SetupResourceRecord(&p->RR_A,   mDNSNULL, zeroIPAddr, kDNSType_A,   60, kDNSRecordTypeUnique,      HostNameCallback, p);
	mDNS_SetupResourceRecord(&p->RR_PTR, mDNSNULL, zeroIPAddr, kDNSType_PTR, 60, kDNSRecordTypeKnownUnique, HostNameCallback, p);

	p->RR_A.name.c[0] = 0;
	AppendDomainLabelToName(&p->RR_A.name, &p->hostlabel);
	AppendStringLabelToName(&p->RR_A.name, "local");

	mDNS_sprintf(buffer, "%d.%d.%d.%d.in-addr.arpa.", p->ip.b[3], p->ip.b[2], p->ip.b[1], p->ip.b[0]);
	ConvertCStringToDomainName(buffer, &p->RR_PTR.name);

	p->RR_A.  rdata->u.ip   = p->ip;
	p->RR_PTR.rdata->u.name = p->RR_A.name;

	mDNS_Register(m, &p->RR_A);
	mDNS_Register(m, &p->RR_PTR);

	debugf("Made Proxy Host Records for %##s", &p->RR_A.name);
	
	return(mStatus_NoError);
	}

//*************************************************************************************************************
// Service Registration

// This sample ServiceCallback just calls mDNS_RenameAndReregisterService to automatically pick a new
// unique name for the service. For a device such as a printer, this may be appropriate.
// For a device with a user interface, and a screen, and a keyboard, the appropriate
// response may be to prompt the user and ask them to choose a new name for the service.
mDNSlocal void ServiceCallback(mDNS *const m, ServiceRecordSet *const sr, mStatus result)
	{
	switch (result)
		{
		case mStatus_NoError:      debugf("Callback: %##s Name Registered",   &sr->RR_SRV.name); break;
		case mStatus_NameConflict: debugf("Callback: %##s Name Conflict",     &sr->RR_SRV.name); break;
		case mStatus_MemFree:      debugf("Callback: %##s Memory Free",       &sr->RR_SRV.name); break;
		default:                   debugf("Callback: %##s Unknown Result %d", &sr->RR_SRV.name, result); break;
		}

	if (result == mStatus_NoError)
		{
		char buffer[256];
		ConvertDomainNameToCString_unescaped(&sr->RR_SRV.name, buffer);
		printf("Service %s now registered and active\n", buffer);
		}

	if (result == mStatus_NameConflict)
		{
		char buffer1[256], buffer2[256];
		ConvertDomainNameToCString_unescaped(&sr->RR_SRV.name, buffer1);
		mDNS_RenameAndReregisterService(m, sr);
		ConvertDomainNameToCString_unescaped(&sr->RR_SRV.name, buffer2);
		printf("Name Conflict! %s renamed as %s\n", buffer1, buffer2);
		}
	}

// RegisterService() is a simple wrapper function which takes C string
// parameters, converts them to domainname parameters, and calls mDNS_RegisterService()
mDNSlocal void RegisterService(mDNS *m, ServiceRecordSet *recordset,
	const char name[], const char type[], const char domain[],
	const domainname *host, mDNSu16 PortAsNumber, const char txtinfo[])
	{
	domainlabel n;
	domainname t, d;
	mDNSIPPort port;
	unsigned char buffer[256];

	ConvertCStringToDomainLabel(name, &n);
	ConvertCStringToDomainName(type, &t);
	ConvertCStringToDomainName(domain, &d);
	port.b[0] = (mDNSu8)(PortAsNumber >> 8);
	port.b[1] = (mDNSu8)(PortAsNumber     );
	if (txtinfo)
		{
		strncpy(buffer+1, txtinfo, sizeof(buffer)-1);
		buffer[0] = strlen(txtinfo);
		}
	else
		buffer[0] = 0;
	
	mDNS_RegisterService(m, recordset, &n, &t, &d, host, port, buffer, buffer[0]+1, ServiceCallback, mDNSNULL);

	ConvertDomainNameToCString_unescaped(&recordset->RR_SRV.name, buffer);
	printf("Made Service Records for %s\n", buffer);
	}

mDNSlocal void NoSuchServiceCallback(mDNS *const m, ResourceRecord *const rr, mStatus result)
	{
	switch (result)
		{
		case mStatus_NoError:      debugf("Callback: %##s Name Registered",   &rr->name); break;
		case mStatus_NameConflict: debugf("Callback: %##s Name Conflict",     &rr->name); break;
		case mStatus_MemFree:      debugf("Callback: %##s Memory Free",       &rr->name); break;
		default:                   debugf("Callback: %##s Unknown Result %d", &rr->name, result); break;
		}

	if (result == mStatus_NoError)
		{
		char buffer[256];
		ConvertDomainNameToCString_unescaped(&rr->name, buffer);
		printf("Non-existence assertion %s now registered and active\n", buffer);
		}

	if (result == mStatus_NameConflict)
		{
		domainlabel n;
		domainname t, d;
		char buffer1[256], buffer2[256];
		ConvertDomainNameToCString_unescaped(&rr->name, buffer1);
		DeconstructServiceName(&rr->name, &n, &t, &d);
		IncrementLabelSuffix(&n, mDNStrue);
		mDNS_RegisterNoSuchService(m, rr, &n, &t, &d, NoSuchServiceCallback, mDNSNULL);
		ConvertDomainNameToCString_unescaped(&rr->name, buffer2);
		printf("Name Conflict! %s renamed as %s\n", buffer1, buffer2);
		}
	}

mDNSlocal void RegisterNoSuchService(mDNS *m, ResourceRecord *const rr,
	const char name[], const char type[], const char domain[])
	{
	domainlabel n;
	domainname t, d;
	unsigned char buffer[256];
	ConvertCStringToDomainLabel(name, &n);
	ConvertCStringToDomainName(type, &t);
	ConvertCStringToDomainName(domain, &d);
	mDNS_RegisterNoSuchService(m, rr, &n, &t, &d, NoSuchServiceCallback, mDNSNULL);
	ConvertDomainNameToCString_unescaped(&rr->name, buffer);
	printf("Made Non-existence Record for %s\n", buffer);
	}

//*************************************************************************************************************
// Main

mDNSexport int main(int argc, char **argv)
	{
	mStatus status;
	ProxyHost proxyhost;
	ServiceRecordSet proxyservice;
	ResourceRecord proxyrecord;
	
	if (argc < 3) goto usage;
	
	proxyhost.ip.NotAnInteger = inet_addr(argv[1]);
	if (proxyhost.ip.NotAnInteger == INADDR_NONE)
		{
		struct hostent *h = gethostbyname(argv[1]);
		if (h) proxyhost.ip.NotAnInteger = *(long*)h->h_addr;
		}
	if (proxyhost.ip.NotAnInteger == INADDR_NONE)
		{
		fprintf(stderr, "%s is not valid host address\n", argv[1]);
		return(-1);
		}

	status = mDNS_Init(&mDNSStorage, &PlatformStorage,
		mDNS_Init_NoCache, mDNS_Init_ZeroCacheSize,
		mDNS_Init_DontAdvertiseLocalAddresses,
		mDNS_Init_NoInitCallback, mDNS_Init_NoInitCallbackContext);
	if (status) { fprintf(stderr, "Daemon start: mDNS_Init failed %ld\n", status); return(status); }

	if (proxyhost.ip.NotAnInteger == 0)
		{
		RegisterNoSuchService(&mDNSStorage, &proxyrecord, argv[2], argv[3], "local.");
		}
	else
		{
		ConvertCStringToDomainLabel(argv[2], &proxyhost.hostlabel);
		mDNS_RegisterProxyHost(&mDNSStorage, &proxyhost);
	
		if (argc >=6)
			{
			char *txt = (argc >=7) ? argv[6] : NULL;
			RegisterService(&mDNSStorage, &proxyservice, argv[3], argv[4], "local.",
							&proxyhost.RR_A.name, atoi(argv[5]), txt);
			}
		}

	ExampleClientEventLoop(&mDNSStorage);

	mDNS_Close(&mDNSStorage);
	return(0);

usage:
	fprintf(stderr, "%s ip hostlabel srvname srvtype port txt\n", argv[0]);
	fprintf(stderr, "e.g. %s 169.254.12.34 thehost \"My Printer\" _printer._tcp. 515 rp=lpt1\n", argv[0]);
	fprintf(stderr, "or   %s 0.0.0.0 \"My Printer\" _printer._tcp. (assertion of non-existence)\n", argv[0]);
	return(-1);
	}
