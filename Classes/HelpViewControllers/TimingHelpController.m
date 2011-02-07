//
//  TimingHelpController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/1/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "TimingHelpController.h"


@implementation TimingHelpController

- (void) getHTMLForView:(UIWebView *)webView WithIndex:(int)index
{
	if(!webView)
		return;
	
	NSMutableString * html = [[NSMutableString alloc] init];
	[html appendString:@"<html><head><meta name=""RacePad Help"" content=""width=300""/></head><body>"];
	
	switch(index)
	{
		case 0:
			[html appendString:@"<h3>Timing</h3>"];
			[html appendString:@"On the timing screen, you will find the positions of all drivers in the race or session, "];
			[html appendString:@"together with all official timing information."];
			
			[html appendString:@"<p>You can also see details of every lap covered by each driver."];
			
			[html appendString:@"<p><table>"];
			[html appendString:@"<td width = 20><image src = ""HelpButtonHTML.png""></td>"];
			[html appendString:@"<td width = 10>&nbsp</td>"];
			[html appendString:@"<td>Press the red question mark buttons to get more information about each area of the screen.<td>"];
			[html appendString:@"<p></table>"];
			break;
			
		case 1:
			[html appendString:@"These columns show drivers in current race or session order."];
			[html appendString:@"<p>On the left is their helmet design followed by their position, car number "];
			[html appendString:@"and abbreviated name."]; 
			[html appendString:@"<p>The abbreviation is usually the first three letters of a driver's surname. "];
			[html appendString:@"A full list of abbreviations can be found in the Info screen."];
			[html appendString:@"<p>Double tab on a driver's name to see a full list of all of his lap times."];
			break;
			
		case 2:
			[html appendString:@"The tyre columns show both the type of tyre that the driver is currently using, and the number of laps covered on those tyres."];
			[html appendString:@"<p>The tyre type may be ""Option"" (the softer dry tyre), ""Prime"" (the harder dry), ""Inter"" (intermediate, for light rain) or ""Wet"" (for heavy rain)."];
			[html appendString:@"<p>In a dry race, drivers must use both Option and Prime tyres. "];
			[html appendString:@"<p>In a wet race, it is not compulsory to change tyres."];
			break;
			
		case 3:
			[html appendString:@"During the race, the lap time column shows the time for the last lap completed for the driver."];				
			[html appendString:@"<br>During practice and qualifying, the time for the last completed lap is shown while "];
			[html appendString:@"the driver is out on track. When he is in the pits, it will show the driver's best "];
			[html appendString:@"time achieved in the session so far."];
			[html appendString:@"<p>All lap and sector times are colour coded:"];
			[html appendString:@"<br><font color = #DD00DD>Purple</font> indicates the best overall time of the session so far"];
			[html appendString:@"<br><font color = #00DD00>Green</font> indicates the driver's personal best time of the session so far"];
			[html appendString:@"<br><font color = #DD0000>Red</font> indicates an in or out lap"];
			[html appendString:@"<br>White is the normal colour otherwise"];
			break;
			
		case 4:
			[html appendString:@"The Gap column shows the gap from this driver to the leader."];
			[html appendString:@"<br>The Interval column shows the gap to the driver ahead."];
			[html appendString:@"<p>In the race, these are the time gaps on track at the end of the previous lap."];
			[html appendString:@"<br>In practice and qualifying, the gaps between the best lap times of the drivers are shown."];
			[html appendString:@"<p>In the race, the current lap number for the leader is shown against his name, in the gap column."];
			break;
			
		case 5:
			[html appendString:@"The track is divided into three official sections, called sectors. These columns show "];
			[html appendString:@"the times for the driver for each of these sectors, together with the speed in "];
			[html appendString:@"kilometers per hour at the end of each."];
			[html appendString:@"<p>No data is shown for a sector until the driver has completed that sector on his current lap."];
			[html appendString:@"<p>The times are colour coded as follows:"];
			[html appendString:@"<br><font color = #DD00DD>Purple</font> indicates the best overall time of the session so far"];
			[html appendString:@"<br><font color = #00DD00>Green</font> indicates the driver's personal best time of the session so far"];
			[html appendString:@"<br><font color = #DD0000>Red</font> indicates an in or out lap"];
			[html appendString:@"<br>White is the normal colour otherwise"];
			break;
			
		case 6:
			[html appendString:@"<h3>Page 6</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 7:
			[html appendString:@"<h3>Page 7</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 8:
			[html appendString:@"<h3>Page 8</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 9:
			[html appendString:@"<h3>Page 9</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 10:
			[html appendString:@"<h3>Page 10</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
	}
	
	[html appendString:@"</body</html>"];
	
	[webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
	
	[html release];	
}

@end
