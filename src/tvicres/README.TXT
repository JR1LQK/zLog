                             TVicRes version 1.0

                        Copyright (C) 1998 Victor Ishikeev
                     e-mail: ivi@ufanet.ru, tools@entechtaiwan.com
                     http://www.entechatiwan.com/tools.htm

                                 README
                                 ======

CONTENTS
========

1. OVERVIEW
2. REGISTRATION
3. INSTALLATION
4. PROPERTIES AND METHODS
5. CONTACT INFORMATION


1. OVERVIEW
===========

TVicRes are 32-bit Delphi class allowing you to get info about the hardware 
resources (port i/o areas, physical memory areas, IRQs, DMA channels) used by 
any hardware device installed to the system.

TVicRes includes transparent support for Windows 95/98 and Windows NT 3.5 or 
higher, include Windows NT 5.0 beta.

Evaluation copies of the TVicRes consist of the following directories:

 \DELPHI2\ - vic_res.dcu for Delphi 2
 \DELPHI3\ - vic_res.dcu for Delphi 3
 \DELPHI4\ - vic_res.dcu for Delphi 4
 \SAMPLE\  - compiled and not compiled test example for Delphi2/3/4

2. REGISTRATION
===============

    TVicRes 1.0 is shareware ($15). You must read and accept the terms 
detailed in the license.txt file before you can use this software. An 
order form is provided in the file order.txt for the purpose of registering 
this software.

------ NOTE. All updates - for free! --------

     Registered users will receive "vic_res.pas" file - Delphi source 
code for this component(can be used with C++Builder 1.0/3.0 also).

TVicRes is maintained at the following internet address:

  http://www.entechtaiwan.com/tools.htm
  e-mail: tools@entechtaiwan.com
          ivi@ufanet.ru

where you can find the latest release and links to support and on-line
ordering sites.

3. INSTALLATION
===============

TVicRes are just a class, not component, thus it do not require any special 
installation. Just copy vic_res.dcu for Delphi 2,3 or 4 to your working 
directory and include "Vic_Res" to the "Uses" statement.
For the first testing you can try a test example shipped with this archive.

4. PROPERTIES AND METHODS
=========================

constructor Create;
-------------------
Allows to create a new TVicRes object at run-time.
For example: NewRes := TVicRes.Create;

procedure   GetAllClasses (ClassList: TStrings);
------------------------------------------------

Returns a "Class" names for the all devices installed on your PC.
You can use these values in the SearchByClassName() method.

function    SearchByClassName(Class_Name:String) : BOOL;
-------------------------------------------------------

Allows to find all hardware resources used by devices with the given Class_Name.
Returns TRUE if these devices have founded in the system registry. 
Note! Check out the "Devices" property after searching. It is possible that more 
than one device with this Class_Name are founded!
Returns a HardwareKey and DeviceDesc fields values also.


function    SearchByHardwareKey(HWKey:String) : BOOL;
-----------------------------------------------------

Allows to find all hardware resources used by devices with the given 
HardwareKey (HardwareId in Windows NT). Returns TRUE if these devices have founded 
in the system registry. 
Returns a class name and DeviceDesc fields values also.


function    SearchByDeviceDescriptor(DeviceDesc:String): BOOL;
--------------------------------------------------------------

Allows to find all hardware resources used by devices with the given 
DeviceDesc. Returns TRUE if these devices have founded in the system registry. 
Returns a HardwareKey and DeviceDesc fields values also.

property    DeviceClassName : String; read only;
------------------------------------------------

Returns the current class name.

property    Devices : Word; read only;
--------------------------------------

Shows how many devices was founded after the searching.

property    HardwareKey[Index:Word] : String; read only;
--------------------------------------------------------

Returns a HardwareKey value for the selected device.
Value of Index should be inside 1..Devices.


property    DeviceDescriptor[Index:Word] : String; read only;
-------------------------------------------------------------

Returns a DeviceDescriptor value for the selected device.
Value of Index should be inside 1..Devices.

property    IRQCounter  : Word; read only;
-----------------------------------------

Shows how many IRQs are used by device(s).

property    IRQNumber[Index:Word]  : Word; read only;
-----------------------------------------------------

Returns an IRQ number.
Value of Index should be inside 1..IRQCounter.


property    DMACounter  : Word; read only;
------------------------------------------

Shows how many DMA channels are used by device(s).

property    DMAChannel[Index:Word] : Word; read only;
------------------------------------------------------

Returns a number of DMA channel.
Value of Index should be inside 1..DMACounter.



property    PortCounter : Word read fPortCounter;
-----------------------------------------

Shows how many Port I/O areas are used by device(s).

property    PortBase[Index:Word] : Word; read only;
---------------------------------------------------

Returns a first port address of the port I/O area.
Value of Index should be inside 1..PortCounter.

property    PortEnd[Index:Word] : Word; read only;
--------------------------------------------------

Returns a last port address of the port I/O area.
Value of Index should be inside 1..PortCounter.

property    MemCounter  : Word; read only;
------------------------------------------

Shows how many physical memory areas are used by device(s).

property    MemBase[Index:Word] : DWORD; read only;
---------------------------------------------------

Returns a first address of the physical memory area.
Value of Index should be inside 1..MemCounter.


property    MemEnd[Index:Word] : DWORD read GetMemEnd;
---------------------------------------------------

Returns a last address of the physical memory area.
Value of Index should be inside 1..MemCounter.



5. CONTACT INFORMATION
======================

    Comments, questions and suggestions regarding TVicRes can be directed
by e-mail to ivi@ufanet.ru or tools@entechtaiwan.com.


With best wishes,
Victor Ishikeev
Oct 1998

e-mail: ivi@ufanet.ru, tools@entechtaiwan.com
http://www.entechatiwan.com/tools.htm