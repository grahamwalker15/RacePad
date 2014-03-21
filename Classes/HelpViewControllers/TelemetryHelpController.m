    //
//  TelemetryHelpController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/1/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "TelemetryHelpController.h"


@implementation TelemetryHelpController

- (void) getHTMLForView:(UIWebView *)webView WithIndex:(int)index
{
	if(!webView)
		return;
	
	NSMutableString * html = [[NSMutableString alloc] init];
	[html appendString:@"<html><head><meta name=""RacePad Help"" content=""width=300""/></head><body>"];
	
	switch(index)
	{
		case 0:
			[html appendString:@"<h3>Car Tracker</h3>"];
			[html appendString:@"The driver views allow you to follow the race with the driver of your choice."];
			[html appendString:@"<p>You can see telemetry straight from his car, his position on track, a running commentary "];
			[html appendString:@"on how he is doing, plus the same graphic as used on the pit wall to plan pit strategy."];
			
			[html appendString:@"<p><table>"];
			[html appendString:@"<td width = 20><image src = ""HelpButtonHTML.png""></td>"];
			[html appendString:@"<td width = 10>&nbsp</td>"];
			[html appendString:@"<td>Press the red question mark buttons to get more information about each area of the screen.<td>"];
			[html appendString:@"<p></table>"];
			break;
			
		case 1:
			[html appendString:@"This graphic shows the G forces to which the driver is subjected. In high speed "];
			[html appendString:@"corners, the lateral (sideways) force can be up to 5g, meaning that the drivers head "];
			[html appendString:@"(and helmet) feel 5 times heavier than normal."];
			
			[html appendString:@"<p>Longitudinal G forces throw the driver forward into his seat belts under braking and "];
			[html appendString:@"back into the seat under acceleration. Braking forces can also be up to 5g, while "];
			[html appendString:@"acceleration is up to 2g."];
				
			[html appendString:@"<p>In a road car, you are unlikely to experience g forces of over 1g in any direction."];
			break;
			
		case 2:
			[html appendString:@"This graphic shows you what is happening in the cockpit of the car. <p>On the dashboard, you "];
			[html appendString:@"can see the current gear on the left, with the speed on the right. The car has 7 gears. "];
			[html appendString:@"The fastest speed of the season is over 340 kph at Monza, and the slowest is around 40 kph at "];
			[html appendString:@"the hairpin in Monaco. The lights at the top show the engine revs per minute (rpm). The rpm is "];
			[html appendString:@"limited to 18000 under current Formula 1 regulations."];
			[html appendString:@"<p>The steering wheel has many buttons and dials. Other than steering the car, a driver will make other adjustments "];
			[html appendString:@"many times per lap. With the addition in 2011 of KERS and adjustable rear wings, this work load is even greater."];
			[html appendString:@"<p>The pedals at the bottom show braking in red, and acceleration in green."];
			break;
			
		case 3:
			[html appendString:@"The track map is zoomed in on the location of the driver you are following. "];
			[html appendString:@"You can expand the map to show the whole track by tapping the arrow in the bottom left "];
			[html appendString:@"corner, or by double tapping the map. You can shrink it again in the same way."];

			[html appendString:@"<p>The current lap is shown above the map, and the driver's progress through the sectors of the lap is "];
			[html appendString:@"shown below"];
			break;
			
		case 4:
			[html appendString:@"The central panel gives you a running commentary of the race. The progress of the driver whom you "];			
			[html appendString:@"are following is reported, together with any changes involving leaders, and all key incidents in the race."];
			[html appendString:@"<p>You can expand the commentary view to the bottom of the screen by double tapping anywhere in "];
			[html appendString:@"the box. You can shrink it back to it's original size in the same way."];
		break;
			
		case 5:
			[html appendString:@"The bottom graphic shows the time gaps between all cars on the track."];
			[html appendString:@"<p>This graphic is very similar to that used on the pit wall to plan pit stop strategy."];
			[html appendString:@"Cars ahead of our car are on the right, and cars behind are to the left. The actual time gaps are "];
			[html appendString:@"shown on the axis."];
			[html appendString:@"<p>The coloured area in the centre shows the estimated pit stop loss. In the example shown in this image (Spa in Belgium), "];
			[html appendString:@"the estimated loss is 23 seconds."];
			[html appendString:@"<p>If our car were to stop, "];
			[html appendString:@"it would exit the pits behind the cars in the coloured area to the left, but in front of those further to the left."];
			[html appendString:@"<p>If any cars within the coloured area ahead of us stop, they will come out behind us."];
			[html appendString:@"<p>We will generally try to time pit stops so that we will exit the pits with as big a gap as possible ahead of us. "];
			[html appendString:@"We always want to avoid emerging behind slower traffic."];
			[html appendString:@"<p>Cars shown with blue flags are being lapped. Cars with orange arrows are leaders coming through the field."];
			[html appendString:@"<p>Tap on More Detail to see labels for all of the cars."];
			break;
			
		case 6:
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
			
		case 7:
			[html appendString:@"Tap the <image src = ""PopupImageHTML.png""> button to bring up a list of race incidents. "];
			[html appendString:@"<p>Tap on any incident from the list to jump to the time of the incident."];
			[html appendString:@"<p>Once you have finished viewing an incident, tap anywhere in the middle of the screen to bring "];
			[html appendString:@"up the play controls, then tap the Go Live button to return to live action.."];
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
