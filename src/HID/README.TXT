Method GetPhysicalDescriptor has been replaced by string property
PhysicalDescriptor.
ReadFileEx and WriteFileEx implemented. HidOverlappedHandle,
NumOverlappedBuffers, OpenFileEx and CloseFileEx accompany
these new methods.
The internal access to the device registry entries
is now made with SetupDiGetDeviceRegistryProperty and
is therefore Win2K safe.
The property HardWareKey has been deleted because it is not
needed anymore.
DeviceStrings and LinkCollectionNodes have been changed
to indexed properties. Their base index now starts correctly with 1.
Two utility functions HidCheck and HidError have been added and
documented in the help.
Added NumCheckedInDevices, NumCheckedOutDevices and NumUnpluggedDevices.
Various small improvements and bugfixes.
-----------------------------------------------------------------------------
Bugfixes since last version:
The events are set to nil in the destructor. This prevents
strange problems with debugging.
The index of the DeviceStrings now corresponds with their index
when read in from the device. This now correctly represents
device strings with nonconsecutive indices.
DeviceIoControl has been added as a method.

A new sample ReadWriteDemo has been added.
> This sample and its data is rigged to the www.lvr.com
> hid sample for the cypress evaluation board.
Bugfixes since last version:
PAS\HID.PAS:
All params like "Report: PChar" changed to "var Report"
This allows the use of buffers or records for the reports
without any compiler warnings.
DEMOS\HIDCLASS\HidControllerClass.pas:
Propagated the untyped Report params up to the methods.
Added ReadFile and WriteFile methods.
The list of the language names (LanguageStrings) has
been introduced.
Fixed the central function FillInList to correctly use
the SetupDi* functions.
Added an exception to TJvHidDeviceController to prevent
instanciating a second one.
Various minor fixes. Help file completed.
-----------------------------------------------------------------------------
Hid.pas is a conversion of HIDPI.H and HIDSDI.H since both function groups
reside in HID.DLL and HIDSDI.H includes HIDPI.H anyway.
I added HidD_Hello() to the conversion.
This is the undocumented easter egg function of HID.DLL.
See Hid.pas for details.

HidToken.pas is a simple conversion of hidtoken.h.
It contains only consts and some converted checking macros.

HidUsage.pas is a more than complete conversion from hidusage.h
The TUsage and PUsage types have been moved to Hid.pas.
This eliminates the need to include HidUsage.pas in all HID projects.
So HidToken.pas and HidUsage.pas are only needed in projects where
the named constants are needed.

Some sets of constants have been completed (mainly keys).
The constants are for Usage, UsagePage and Usage values.
That is they describe the real data you will get from USB devices.

For real information read "USB HID Usage Tables 1.1rc3.pdf"
or newer versions thereof from www.usb.org.

I added some comments marked (rom) to clarify some things.
Changes from Windows 98 DDK to Windows 2000 DDK i marked (Win2000).
The new functions documented in the Windows 2000 DDK have been implemented
already in the HID.DLL of Windows 98 SE.
The function declarations are inside a {$IFDEF WIN2000}.

You will need SetupApi.pas from the SetupApi conversion and DBT.pas from the DBT conversion.

The component in Demos\HidClass gives you access to the complete HID API.
There is no need to use the functions directly.

known issues:
some of the new constants in HidUsage.pas may be named incorrectly
as a german i do not know all the real english key names
