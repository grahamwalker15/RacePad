    //
//  MapHelpController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/1/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "MapHelpController.h"


@implementation MapHelpController

- (void) getHTMLForView:(UIWebView *)webView WithIndex:(int)index
{
	if(!webView)
		return;
	
	NSMutableString * html = [[NSMutableString alloc] init];
	[html appendString:@"<html><head><meta name=""RacePad Help"" content=""width=300""/></head><body>"];
	
	switch(index)
	{
		case 0:
			[html appendString:@"<h3>Track Map</h3>"];
			[html appendString:@"The Track view shows the location of all cars using data transmitted from their GPS devices, "];
			[html appendString:@"together with a leader board which shows the current order in the race or other session."];
			
			[html appendString:@"<p><table>"];
			[html appendString:@"<td width = 20><image src = ""HelpButtonHTML.png""></td>"];
			[html appendString:@"<td width = 10>&nbsp</td>"];
			[html appendString:@"<td>Press the red question mark buttons to get more information about each area of the screen.<td>"];
			[html appendString:@"<p></table>"];
			break;
			
		case 1:
			[html appendString:@"The leader board shows all drivers in their current positions."];
			[html appendString:@"<p>In the race, this will be position on track."];
			[html appendString:@"<br>In other sessions, the drivers are listed in order of their best lap times."];
			[html appendString:@"<br>Before the session starts, they are simply in order of car number."];
			[html appendString:@"<p>Tap on any driver in the list to bring up an inset map zoomed in on his car."];		
			break;
			
		case 2:
			[html appendString:@"The inset map is zoomed in on the location of the driver selected on the leader "];
			[html appendString:@"board. You can change the driver at any time by tapping on a new one on the leader board."];

			[html appendString:@"<p>You can zoom further in, or pull out, by placing two fingers on the small map and moving them together, or apart."];
			 
			[html appendString:@"<br>You can also drag the map around the screen."];
			 
			[html appendString:@"<p>To close the map, double click anywhere in the box."];
			break;
			
		case 3:
			[html appendString:@"The main map shows the current location of all cars."];
			[html appendString:@"<br>The turn numbers are shown in light blue. You will hear these referred to on the radio."];
			[html appendString:@"<br>The end of each sector is marked - S1, S2 and FIN."];
			[html appendString:@"<br>The yellow markers, SC1 and SC2, are used under safety car. See the Rules section "];
			[html appendString:@"under the Info tab for more information about safety cars."];
			[html appendString:@"<p>Cars are colour coded in various ways:"];
			[html appendString:@"<br>Our team cars are shown in red and blue."];
			[html appendString:@"<br>The current leader has white text on a black background."];
			[html appendString:@"<br>Cars in the pits have a light blue background."];
			[html appendString:@"<br>Cars on out laps from the pits have a yellow flashing outline."];
			[html appendString:@"<br>In practice and qualifying, cars on slow laps have an orange outline. These are "];
			[html appendString:@"usually pit in laps."];
			break;
			
		case 4:
			[html appendString:@"These buttons show progress in the session, and the current track status."];
			
			[html appendString:@"<p>During the race, the current lap number for the leader is displayed, together with "];
			[html appendString:@"the total number of laps to be covered."];
			
			[html appendString:@"<p>The background colour indicates the current track state. White indicates normal "];
			[html appendString:@"running, yellow means that there is a yellow flag somewhere on the circuit, and red "];
			[html appendString:@"means that the session has been red flagged."];
			[html appendString:@"<br>If the safety car is deployed, an "];
			[html appendString:@"additional SC box is shown. When the race is finished, a checkered flag is shown."];
			
			[html appendString:@"<p>In practice and qualifying, the elapsed time in the current session is displayed."];
			
			[html appendString:@"<p>See the Rules section under the Info tab, for more information on session lengths and "];
			[html appendString:@"flag rules."];
			break;
			
		case 5:
			[html appendString:@"Tap the <image src = ""PopupImageHTML.png""> button to bring up a list of race incidents. "];
			[html appendString:@"<p>Tap on any incident from the list to jump to the time of the incident."];
			[html appendString:@"<p>Once you have finished viewing an incident, tap anywhere in the middle of the screen to bring "];
			[html appendString:@"up the play controls, then tap the Go Live button to return to live action.."];
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
