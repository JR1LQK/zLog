{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  ConCli shows how to use TWSocket in a console mode application
              (for Delphi 2 or Delphi 3 only).
EMail:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@rtfm.be
Creation:     Nov 20, 1997
Version:      1.00
WebSite:      http://www.rtfm.be/fpiette/indexuk.htm
Support:      Use the mailing list twsocket@rtfm.be See website for details.
Legal issues: Copyright (C) 1997 by François PIETTE <francois.piette@ping.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

Updates:


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$APPTYPE CONSOLE}
program ConCli1;

uses
    WSocket,
    Wait;

var
    WSocket1 : TWsocket;
    Wait1    : TWait;
    Buffer   : String;
begin
    Wait1             := TWait.Create(nil);
    WSocket1          := TWsocket.Create(nil);
    WSocket1.Addr     := 'localhost';
    WSocket1.Port     := 'telnet';
    WSocket1.Proto    := 'tcp';
    WSocket1.WaitCtrl := Wait1;
    WSocket1.Connect;
    WSocket1.ReadLine(15, Buffer);
    Writeln('Server banner is: ' + Buffer);
    WSocket1.Close;
    WSocket1.Destroy;
    Wait1.Destroy;

    Writeln('Hit enter...');
    Readln;
end.
