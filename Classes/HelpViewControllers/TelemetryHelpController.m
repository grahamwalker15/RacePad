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
			[html appendString:@"<h3>Page 1</h3>"];
			[html appendString:@"<p>G forces"];
			break;
			
		case 2:
			[html appendString:@"<h3>Page 2</h3>"];
			[html appendString:@"<p>Driver activity"];
			break;
			
		case 3:
			[html appendString:@"<h3>Page 3</h3>"];
			[html appendString:@"<p>Track map"];
			break;
			
		case 4:
			[html appendString:@"<h3>Page 4</h3>"];
			[html appendString:@"<p>Commentary"];
			break;
			
		case 5:
			[html appendString:@"<h3>Page 5</h3>"];
			[html appendString:@"<p>Pit stop strategy"];
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
