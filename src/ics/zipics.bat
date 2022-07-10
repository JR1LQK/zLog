if exist ics.zip del ics.zip
if exist ics7spec.zip del ics7spec.zip
wzzip -P ics7spec.zip @zipics7.lst
wzzip -P ics.zip @zipicsd.lst
wzzip -P ics.zip @zipicsb.lst
del ics7spec.zip
ren ics.zip ics.zip
pause
