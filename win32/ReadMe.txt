============= Change Log ===============


20 August 2002 

Changes by Sam Saffron - sam@wasnotwas.com 

1. Changed Rescan button to Refresh, so window conforms to standard explorer style 
2. Moved Rescan option to Files->Rescan 
3. Started this Changelog in Readme.txt 
4. Removed Source Safe Refs from project 
5. VS is getting confused with the mixed cr / crlf environment CVS should save files with CRLF, 
	they are windows files after all - All commits on the windows dirs should have CRLF 		
6. Go to home page on load - if it loads successfully (I am using wincvs 1.3.8) 
7. Add solution to CVS 
8. Put empty installer script in solution 


21 August 2002 

Changes by Sam Saffron - sam@wasnotwas.com 

1. destroy surrogate perl server process if it exists 
2. set music folder and play list folder (read pref file) 
3. retry when loading home page in case home page doesnt load up 

28 August 20002 

Changes by Sam Saffron - sam@wasnotwas.com 

1. worte the control slim class that allows direct comms with slim server 
2. interim window while loading 
3. fix toolbar to look more standard 
4. Apply settings without refreshing html page ... 

2 Sept 2002 

1. Add command line options (support /play and /add switches now) 
2. Fix bug where http port was fixed to 9000 

========================================












=



===============================================================================




    MICROSOFT FOUNDATION CLASS LIBRARY : SlimServer Project Overview

===============================================================================



The application wizard has created this SlimServer application for 

you.  This application not only demonstrates the basics of using the Microsoft 

Foundation Classes but is also a starting point for writing your application.



This file contains a summary of what you will find in each of the files that

make up your SlimServer application.



SlimServer.vcproj

    This is the main project file for VC++ projects generated using an application wizard. 

    It contains information about the version of Visual C++ that generated the file, and 

    information about the platforms, configurations, and project features selected with the

    application wizard.



SlimServer.h

    This is the main header file for the application.  It includes other

    project specific headers (including Resource.h) and declares the

    CSlimServerApp application class.



SlimServer.cpp

    This is the main application source file that contains the application

    class CSlimServerApp.



SlimServer.rc

    This is a listing of all of the Microsoft Windows resources that the

    program uses.  It includes the icons, bitmaps, and cursors that are stored

    in the RES subdirectory.  This file can be directly edited in Microsoft

    Visual C++. Your project resources are in 1033.



res\SlimServer.ico

    This is an icon file, which is used as the application's icon.  This

    icon is included by the main resource file SlimServer.rc.



res\SlimServer.rc2

    This file contains resources that are not edited by Microsoft 

    Visual C++. You should place all resources not editable by

    the resource editor in this file.

/////////////////////////////////////////////////////////////////////////////



For the main frame window:

    The project includes a standard MFC interface.

MainFrm.h, MainFrm.cpp

    These files contain the frame class CMainFrame, which is derived from

    CMDIFrameWnd and controls all MDI frame features.

res\Toolbar.bmp

    This bitmap file is used to create tiled images for the toolbar.

    The initial toolbar and status bar are constructed in the CMainFrame

    class. Edit this toolbar bitmap using the resource editor, and

    update the IDR_MAINFRAME TOOLBAR array in SlimServer.rc to add

    toolbar buttons.

/////////////////////////////////////////////////////////////////////////////



For the child frame window:



ChildFrm.h, ChildFrm.cpp

    These files define and implement the CChildFrame class, which

    supports the child windows in an MDI application.



/////////////////////////////////////////////////////////////////////////////



The application wizard creates one document type and one view:



SlimServerDoc.h, SlimServerDoc.cpp - the document

    These files contain your CSlimServerDoc class.  Edit these files to

    add your special document data and to implement file saving and loading

    (via CSlimServerDoc::Serialize).

SlimServerView.h, SlimServerView.cpp - the view of the document

    These files contain your CSlimServerView class.

    CSlimServerView objects are used to view CSlimServerDoc objects.

res\SlimServerDoc.ico

    This is an icon file, which is used as the icon for MDI child windows

    for the CSlimServerDoc class.  This icon is included by the main

    resource file SlimServer.rc.

/////////////////////////////////////////////////////////////////////////////



Other Features:



ActiveX Controls

    The application includes support to use ActiveX controls.



Printing and Print Preview support

    The application wizard has generated code to handle the print, print setup, and print preview

    commands by calling member functions in the CView class from the MFC library.



Split Window

    The application wizard has added support for splitter windows for your application documents.



Windows Sockets

    The application has support for establishing communications over TCP/IP networks.

/////////////////////////////////////////////////////////////////////////////



Other standard files:



StdAfx.h, StdAfx.cpp

    These files are used to build a precompiled header (PCH) file

    named SlimServer.pch and a precompiled types file named StdAfx.obj.



Resource.h

    This is the standard header file, which defines new resource IDs.

    Microsoft Visual C++ reads and updates this file.



SlimServer.manifest

	Application manifest files are used by Windows XP to describe an applications 

	dependency on specific versions of Side-by-Side assemblies. The loader uses this 

	information to load the appropriate assembly from the assembly cache or private 

	from the application. The Application manifest  maybe included for redistribution 

	as an external .manifest file that is installed in the same folder as the application 

	executable or it may be included in the executable in the form of a resource. 

/////////////////////////////////////////////////////////////////////////////



Other notes:



The application wizard uses "TODO:" to indicate parts of the source code you

should add to or customize.



If your application uses MFC in a shared DLL, and your application is in a 

language other than the operating system's current language, you will need 

to copy the corresponding localized resources MFC70XXX.DLL from the Microsoft

Visual C++ CD-ROM under the Win\System directory to your computer's system or 

system32 directory, and rename it to be MFCLOC.DLL.  ("XXX" stands for the 

language abbreviation.  For example, MFC70DEU.DLL contains resources 

translated to German.)  If you don't do this, some of the UI elements of 

your application will remain in the language of the operating system.



/////////////////////////////////////////////////////////////////////////////

