    //
//  InfoStandingsController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/12/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoStandingsController.h"


@implementation InfoStandingsController


- (void)viewDidLoad
{
	selectedButton = nil;
		
	//placeHolderView = fiaLogo;
	//placeHolderAlpha = [placeHolderView alpha];
	
	[super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	// Start with the drivers table - by simulating a button press
	[self buttonPressed:drivers];

	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(selectedButton)
		[selectedButton setSelected:false];
	
	selectedButton = nil;
	
	[super viewWillDisappear:animated];
}

- (void)dealloc
{
    [super dealloc];
}


/////////////////////////////////////////////////////////////////////////////////

- (void) positionOverlays
{
	CGRect bgFrame = [backgroundView frame];
	CGRect buttonFrame = [drivers frame];
	CGRect imageFrame = [fiaLogo frame];
	
	float spareWidth = CGRectGetMaxX(bgFrame) - CGRectGetMaxX(buttonFrame);
	float spareHeight = CGRectGetHeight(bgFrame);
	
	float webXMargin = spareWidth * 0.05;
	float webYMargin = spareHeight * 0.05;
	
	float imageXMargin = (spareWidth - CGRectGetWidth(imageFrame)) * 0.5;
	float imageYMargin = (spareHeight - CGRectGetHeight(imageFrame)) * 0.5;
	
	CGRect newWebFrame = CGRectMake(CGRectGetMaxX(buttonFrame) + webXMargin, webYMargin, spareWidth - webXMargin * 2, spareHeight - webYMargin * 2);
	[webView1 setFrame:newWebFrame];
	[webView2 setFrame:newWebFrame];
	
	CGRect newImageFrame = CGRectMake(CGRectGetMaxX(buttonFrame) + imageXMargin, imageYMargin, CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
	[fiaLogo setFrame:newImageFrame];
	
	if(!selectedButton)
	{
		[webView1 setHidden:true];
		[webView2 setHidden:true];
		[fiaLogo setHidden:false];
	}
}

- (IBAction) buttonPressed:(id)sender;
{
	// Do nothing if we're still animating a previous transition
	if(animatingViews)
		return;
	
	[selectedButton setSelected:false];
	[sender setSelected:true];
	
	selectedButton = sender;
	
	if( sender == drivers )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoDriverStandings" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == constructors )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamStandings" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else
	{
		[webView1 setHidden:true];
		[webView2 setHidden:true];
		[fiaLogo setHidden:false];
	}
}

@end
