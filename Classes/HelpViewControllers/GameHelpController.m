    //
//  GameHelpController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/1/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "GameHelpController.h"


@implementation GameHelpController

- (void) getHTMLForView:(UIWebView *)webView WithIndex:(int)index
{
	if(!webView)
		return;
	
	NSMutableString * html = [[NSMutableString alloc] init];
	[html appendString:@"<html><head><meta name=""RacePad Help"" content=""width=300""/></head><body>"];
	
	switch(index)
	{
		case 0:
			[html appendString:@"<h3>The Game</h3>"];
			[html appendString:@"This game allows you to compete in the race weekend, trying to out-do fellow guests "];
			[html appendString:@"by making the best prediction of the top 10. In each session."];
			[html appendString:@"<p>Simply drag and drop drivers into your prediction, and send it off."];
			[html appendString:@"<p>You can then follow your progress in a league table kept up to date throughout the session."];
			
			[html appendString:@"<p><table>"];
			[html appendString:@"<td width = 20><image src = ""HelpButtonHTML.png""></td>"];
			[html appendString:@"<td width = 10>&nbsp</td>"];
			[html appendString:@"<td>Press the red question mark buttons to get more information about each area of the screen.<td>"];
			[html appendString:@"<p></table>"];
			break;
			
		case 1:
			[html appendString:@"<h3>Page 1</h3>"];
			[html appendString:@"<p>Login"];
			break;
			
		case 2:
			[html appendString:@"<h3>Page 2</h3>"];
			[html appendString:@"<p>Your prediction"];
			break;
			
		case 3:
			[html appendString:@"<h3>Page 3</h3>"];
			[html appendString:@"<p>Driver lists and information."];
			break;
			
		case 4:
			[html appendString:@"<h3>Page 4</h3>"];
			[html appendString:@"<p>Send"];
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
	
	[webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
	
	[html release];	
}

@end
