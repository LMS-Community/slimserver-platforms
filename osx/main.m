#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

extern int NSApplicationMain(int argc, const char *argv[]);

int main(int argc, const char *argv[])
{
    return NSApplicationMain(argc, argv);
}


@interface HostLookup : NSObject

+ (NSString *)myHostName;

@end

@implementation HostLookup

+ (NSString *)myHostAddress
{
    NSHost *host;
    host = [NSHost currentHost];
    return [NSString stringWithFormat:@"%@",[host address]];
}

+ (NSString *)myHostName
{
    NSHost *host;
    host = [NSHost currentHost];
    return [NSString stringWithFormat:@"%@",[host name]];
}

+ (void)offIcon
{
	NSImage *myImage = [NSImage imageNamed: @"slimp3off"];
	[NSApp setApplicationIconImage: myImage];
}

+ (void)onIcon
{
	NSImage *myImage = [NSImage imageNamed: @"slimp3icon"];
	[NSApp setApplicationIconImage: myImage];
}

@end
