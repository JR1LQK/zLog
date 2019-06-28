This commponent was based on the COMM32 component written
by David Wann of Stamina Software.

As good as Davids Wann's Component is, I felt in need a few Enharncments.

I have added a DataBits Property, which is imperative to most Comm's
applications.
An Application I have written needs DataBits, so there was my 
insperation to add it.

To this I have added drop down lists for the Comm Port, and Baud Rate
and of course to the new Databits Property.


		What files do I install ?
		*************************

Copy the VSSCOMM32.PAS & VSSCOMM32.RES to your Component directory.



		How to use this component ?
		***************************

There is a quick wee demo I put togeither called VSSCMDEMO.
Open the VSSCMDEMO.DPR, and then edit the properties in the componet
to suite your modem.
then Compile it.
        
	OK, But how do I use the Component in My Own App. ?
	***************************************************

you need to open the Comm Port first.

USE :- the "StartComm" function to open the port

Next write something to it :-

USE :- the "WriteCommData" function to write to the port.
	
	i.e. VSSCOMM321.WriteCommData (StringToWrite,LenghtofStringToWrite);

StringToWrite = the string of data you want to write to the comm Port.

lengthofStringToWrite = the length of (StringToWrite);

	or more easily as an example :-
	
	Procedure WriteMyDataToComm (blah, blah, blah);
	var
		senddata: String;
	begin
		senddata := 'This is a Test'	
		VSSCOMM321.WriteCommData (Pchar(Senddata),length(senddata));
	end;

Now Close the Comm Port :-

USE :- The "StopComm" function to close the port.


And thats it, that easy.


If you have any questions or find any bugs, please let me know, or if you 
make any other enhancments please send me a copy of your component.

As with David Wann's COMM32, this is freeware.


cheers, Jeremy Coulter
	Visual Software Solutions, 1996
	vss@mac.co.nz
	http://www.voyager.co.nz/~jcoulter/index.htm



p.s. I applogize for any spelling mistakes, not my forte.