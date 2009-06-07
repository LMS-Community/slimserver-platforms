#import <Foundation/Foundation.h>
#include "RendezvousPublisher.h"

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSString *pathToServer = [[NSBundle mainBundle] bundlePath];

    /*
     **  Run a simple shell script to check if the server is running. If not, it automatically
     ** launches it as a daemon. The script, and the server it launches, assume that they're
     ** being launched from the server directory.
     **
     **  Storing the script externally allows for easy modification without recompilation of the
     ** entire project.
     **
     **  Note: due to the Rendezvous changes, the server MUST be started as a child of this process,
     ** and should not go into daemon mode. If it does, our launcher will consider the exit of the
     ** process to be the death of the server, and will revoke the Rendezvous service.
     */

    NSTask *launcherTask = [[NSTask alloc] init];

    [launcherTask setCurrentDirectoryPath:pathToServer];
    [launcherTask setLaunchPath:[pathToServer stringByAppendingPathComponent:@"SqueezeCenter.app/Contents/Resources/start-server.sh"]];
    [launcherTask setArguments:[NSArray arrayWithObjects:@"--nodaemon", nil]];

    /*
     **  Exception block traps failed task launch.
     */

    NS_DURING
    {
	[launcherTask launch];

	/*
	 **  Under Jaguar, we need to register for Rendezvous. We launch the process FIRST to ensure its availability before
	 ** announcing the service.
	 */

	RendezvousPublisher *rendezvousPublisher = [[RendezvousPublisher alloc] init];

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
    }
    NS_HANDLER
	NSLog (@"Failed to launch Squeezebox Server: script missing.\n");
    NS_ENDHANDLER

    [launcherTask release];

    [pool release];
    return 0;
}