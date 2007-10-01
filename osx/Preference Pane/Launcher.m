//
//  Launcher.m
//  SqueezeCenter
//
//  Created by Dave Nanian on Wed Oct 16 2002.
//  Copyright (c) 2002-2007 Logitech. All rights reserved.
//

#import "Launcher.h"

int main(int argc, const char *argv[])
{
    return NSApplicationMain(argc, argv);
}

@implementation Launcher

-(void)finishLaunching
{
    NSString *pathToServer = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];

    /*
    **  Run a simple shell script to check if the server is running. If not, it automatically
    ** launches it as a daemon. The script, and the server it launches, assume that they're
    ** being launched from the server directory. (The script, however, is stored in the launcher's
    ** Resource path.)
    **
    **  Storing the script externally allows for easy modification without recompilation of the
    ** entire project.
    **
    **  Note: due to the Rendezvous changes, if publishing with Rendezvous
    ** the server MUST be started as a child of this process,
    ** and should not go into daemon mode. If it does, our launcher will consider the exit of the
    ** process to be the death of the server, and will revoke the Rendezvous service.
    */

    NSTask *launcherTask = [[NSTask alloc] init];

    [launcherTask setCurrentDirectoryPath:pathToServer];
    [launcherTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"start-server.sh"]];

#ifdef LAUNCHER_RENDEZVOUS
    [launcherTask setArguments:[NSArray arrayWithObjects:@"--nodaemon", nil]];
#endif
    
    /*
    **  Exception block traps failed task launch.
    */
    
    NS_DURING
    {
	[launcherTask launch];
#ifdef LAUNCHER_RENDEZVOUS
	/*
	 **  Under Jaguar, we need to register for Rendezvous. We launch the process FIRST to ensure its availability before
	 ** announcing the service.
	 */

	rendezvousPublisher = [[RendezvousPublisher alloc] init];

	[rendezvousPublisher publish];
	
	/*
	**  Note: despite the fact that this looks like a simple block, the documentation implies a busy-wait. Tests show a complete
	** block, but we might need to find a better way if something gets changed by Apple.
	*/
	
	[launcherTask waitUntilExit];

	/*
	**  Our server has stopped -- unpublish the Rendezvous services.
	*/
	
	[rendezvousPublisher stop];
	[rendezvousPublisher release];
#endif
    }
    NS_HANDLER
	NSLog (@"Failed to launch SqueezeCenter: start-server.sh missing.\n");
    NS_ENDHANDLER

    [launcherTask release];
	
    /*
    **  Our work done, we simply exit.
    */
    
    [super terminate:nil];
}

@end
