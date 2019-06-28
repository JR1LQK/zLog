unit Misc;

interface

uses
	Windows, SysUtils;

function FormatLastError( dwLastError: DWORD;
	 szOutputBuffer: PChar; dwSizeofOutputBuffer: DWORD ): PChar;

const
	MAXOUTPUTSTRINGLENGTH = 4096;

implementation

function MAKELANGID( usPrimaryLanguage, usSubLanguage: Byte ): WORD;
begin
	Result := ((usSubLanguage shl 10) + usPrimaryLanguage);
end;

//
//  FUNCTION: FormatLastError(DWORD, LPSTR, DWORD)
//
//  PURPOSE: Pretty print a system error to a string.
//
//  PARAMETERS:
//    dwLastError          - Actual error code to decipher.
//    szOutputBuffer       - String buffer to pretty print to.
//    dwSizeofOutputBuffer - Size of String buffer.
//
//  RETURN VALUE:
//    Returns the buffer printed to.
//
//  COMMENTS:
//    If szOutputBuffer isn't big enough to hold the whole string,
//    then the string gets truncated to fit the buffer.
//
//    If szOutputBuffer == NULL, then dwSizeofOutputBuffer
//    is ignored, a buffer 'big enough' is LocalAlloc()d and
//    a pointer to it is returned.  However, its *very* important
//    that this pointer be LocalFree()d by the calling application.
//
//
function FormatLastError( dwLastError: DWORD;
	 szOutputBuffer: PChar; dwSizeofOutputBuffer: DWORD ): PChar;
var
	dwRetFM,
	dwFlags: 					DWORD;
	dwGetLastError: 			DWORD;
	szFormatMessageError:	LPSTR;
begin
	dwFlags := FORMAT_MESSAGE_FROM_SYSTEM;

	 // Should we allocate a buffer?
	 if szOutputBuffer = nil then
	 begin
		  // Actually, we make FormatMessage allocate the buffer, if needed.
		  dwFlags := dwFlags + FORMAT_MESSAGE_ALLOCATE_BUFFER;

		  // minimum size FormatMessage should allocate.
		  dwSizeofOutputBuffer := 1;
	 end;

	 // Make FormatMessage pretty print the system error.
	 dwRetFM := FormatMessage(
		  dwFlags, nil, dwLastError,
		  MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
		  PAnsiChar(@szOutputBuffer), dwSizeofOutputBuffer,
		  nil);

	 // FormatMessage failed to print the error.
	 if dwRetFM = 0 then
	 begin
		  dwGetLastError := GetLastError;

		  // If we asked FormatMessage to allocate a buffer, then it
		  // might have allocated one.  Lets be safe and LocalFree it.
		  if (dwFlags and FORMAT_MESSAGE_ALLOCATE_BUFFER) <> 0 then
		  begin
				LocalFree(HLOCAL(szOutputBuffer));

				szOutputBuffer := PChar(LocalAlloc( LPTR, MAXOUTPUTSTRINGLENGTH ));
{				dwSizeofOutputBuffer := MAXOUTPUTSTRINGLENGTH;}

				if szOutputBuffer = nil then
				begin
					 OutputDebugString( 'Out of memory trying to FormatLastError' );
					 result := nil;
					 Exit;
				end;
		  end;

		  szFormatMessageError := PChar(IntToStr(dwGetLastError));{
				FormatLastError( dwGetLastError, nil, 0 );}

		  if szFormatMessageError = nil then
		  begin
				Result := nil;
				Exit;
		  end;

		  wsprintf(szOutputBuffer,
				PChar('FormatMessage failed on error '+IntToStr(dwLastError)+' for the following reason: '+
					szFormatMessageError) );

		  LocalFree( HLOCAL(szFormatMessageError) );
	 end;

	 Result := szOutputBuffer;
end;

end.
