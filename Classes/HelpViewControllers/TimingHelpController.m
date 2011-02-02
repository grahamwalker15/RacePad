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
			[html appendString:@"Welcome to RacePad Help."];
			[html appendString:@"<p>Tap on any red question mark buttons to get specific information about that area of the screen."];
			break;
			
		case 1:
			[html appendString:@"The left hand columns show drivers in current race or session order."];
			[html appendString:@"<p>The numbers are their position, followed by their car number."];
			[html appendString:@"<p>Abbreviations are used for driver names. These are usually the first three letters of a driver's surname. "];
			[html appendString:@"A full list of abbreviations can be found in the Info screen."];
			break;
			
		case 2:
			[html appendString:@"These columns show the type of tyre that the driver is currently using, together with the number of laps covered on those tyres."];
			[html appendString:@"<p>The tyres may be Option (the softer dry tyre), Prime (the harder dry), Intermediate (for light rain) or Wet (for heavy rain)."];
			[html appendString:@"<p>In a dry race, drivers must use both Option and Prime tyres. "];
			[html appendString:@"In a wet race, it is not compulsory to change tyres."];
			  
			break;
			
		case 3:
			[html appendString:@"<h3>Page 3</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 4:
			[html appendString:@"<h3>Page 4</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 5:
			[html appendString:@"<h3>Page 5</h3>"];
			[html appendString:@"<p>Racepad Help"];
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
	
	[webView loadHTMLString:html baseURL:nil];
	
	[html release];	
}

@end
