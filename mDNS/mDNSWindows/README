This directory contains support files for running mDNS on Microsoft Windows.

mDNSWin32.c & mDNSWin32.h are the Platform Support files that go below
mDNS Core.

Tool.c is an example client that uses the services of mDNS Core.

ToolWin32.mcp is a CodeWarrior project (CodeWarrior for Windows version 8)
that builds Tool.c to make rendezvous.exe, a small Windows command-line
tool to do all the standard Rendezvous stuff on Windows. It has the
following features:

- Browse for browsing and/or registration domains.
- Browse for services.
- Lookup Service Instances.
- Register domains for browsing and/or registration.
- Register services.

For example, if you have a Windows machine running a Web server,
then you can make it advertise that it is offering HTTP on port 80
with the following command:

rendezvous -rs "Windows Web Server" "_http._tcp." "local." 80 ""

To search for AFP servers, use this:

rendezvous -bs "_afpovertcp._tcp." "local."

You can also do multiple things at once (e.g. register a service and
browse for it so one instance of the app can be used for testing).
Multiple instances can also be run on the same machine to discover each
other. There is a -help command to show all the commands, their
parameters, and some examples of using it.
