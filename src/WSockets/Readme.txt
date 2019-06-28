97-06-16 Stockholm, Sweden.

Whats New (in version 1.20)?

Well, I sent a version 1.11 out to some of you who sent me feedback on WSockets.
That version was left behind by a new version with a new interface, code named
"Stockholm 97", NOT! Just kidding, it is called version 2.0 and some of you
have had a chance to take a look at it. Version 2.0 took all the time and it is
still not near a final release so I thought that I had to do something for you 
all that still use version 1.10. A major problem with 1.10 is that it is not
compatible with Delphi 3. I have also learned a lot about WinSockets during my
work with version 2.0 resulting in an urge to change lots of small things in
version 1.10. So I just had to drop the work on version 2.0 to update version
1.10 to this version: 1.20! My hope is that it will work better for you all
than version 1.10 (and the now not supported prereleased version 1.11). Real 
news about the code is found in section "History" at the end of this file.

Thanks again to You all that have sent me feedback!

WSockets version 1.20 - Delphi 2 and 3 WinSocket Classes:

I hope that my classes in WSockets.pas will make it easier four you all to
develop TCP/UDP/client/server applications. I originally made them because
all other freeware (with source) VCL packages used the application object
in one way or another. Another god reason was to lern more about Delphi
and WinSocket programming.

There is no Windows help file (because I don't know how to make them) and no
proper documentation (because I lack the time), I just hope that you manage
to figure out how to use this stuff by yourself. Use my quick reference
(WSockets.doc) and example Delphi projects...

I made four exaple projects just to show you the simplicity of my WinSocket
API encapsulation in a TCP/UDP/Client/Server application. The objects are
allocated on the fly so you don't have to install the VCL (if you just
want to check this thing out before you try to install it).

This is my first Delphi VCL and I am not sure that I got everything right (yet).
Please let me know if I made som errors or if you got any kind of feedback.

Legal issues:

Copyright (C) 1997 by Robert T. Palmqvist <robert.palmqvist@skanska.se>

This software is provided 'as-is', without any express or implied
warranty.  In no event will the author be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented, you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.

Credits go to:

  Gary T. Desrosiers. His unit "Sockets" inspired me to write my own.

  Martin Hall, Mark Towfig, Geoff Arnold, David Treadwell, Henry Sanders
  and InfoMagic, Inc. for their Windows Help File "WinSock.hlp".

  All the guys at Borland who gave us a marvellous tool named "Delphi"!

Recommended information sources:

  Specification:
    Windows Sockets Version 1.1 Specification

  Textbook:
    Quinn and Shute. "Windows Sockets Network Programming"
    1996 by Addison-Wesley Publishing Company, Inc. ISBN 0-201-63372-8

  World Wide Web:
    http://www.sockets.com
    http://www.stardust.com

  Network News:
    alt.winsock.programming

  Frequently Asked Questions:
    "WinSock Application FAQ" Mailto: info@lcs.com Subject: faq

  Requests for Comments:
    RFC 768 "User Datagram Protocol"
    RFC 791 "Internet Protocol"
    RFC 793 "Transmission Control Protocol"

/Robert

History (style conventions: [! Bug | ? Request | * Change | + Added | - Removed]):

Version 1.00

Initial Release.

! Found a message handling bug under Windows NT.
? TClientList.IndexOf method requested.

Version 1.10

* Code reorganized and Windows NT message handling bug removed.
+ Added public method "IndexOf" to "TClientList" class.
? Window Message "FD_WRITE" call-back requested

Version 1.20

! All read and write operations changed to prevent WSAEWOULDBLOCK errors
  (Writing text will act blocking and not return until all data is sent
   sending buffers will return with information about how much was sent)
* Changed source code to support both Delphi 2 and Delphi 3
  (due to differences in the runtime library, read: WinSock.pas)
* Changed name on class "TCustomSocket" to "TCustomWSocket"
  (due to name collision with Delphi 3 C/S class "TCustomSocket")
* Internal code changes in the "TClientList" class
* Changed internal code and interface of "TCustomWSocket.SocketClose"
* use of "TCustomWSocket.SocketQueueSize" replaced with use of FReadBuffer field
  (To minimize read operation overhead)
* Improved state checking and error handling
* Changed code to minimize "WSAASyncSelect" calls
- Deleted "Authorized" property (not 100% fault proof and seldom used)

