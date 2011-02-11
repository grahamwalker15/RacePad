    //
//  InfoPartnersController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/9/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoPartnersController.h"


@implementation InfoPartnersController

- (void)viewDidLoad
{
	selectedPartner = nil;
	[super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
 }

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
	CGRect logoFrame = [partner11 frame];
	CGRect infoFrame = [webView frame];
		
	float x = (CGRectGetWidth(bgFrame) - CGRectGetWidth(infoFrame)) * 0.5;
	float y = CGRectGetMaxY(logoFrame) + 20 ;
	
	CGRect newInfoFrame = CGRectMake(x, y, CGRectGetWidth(infoFrame), CGRectGetMaxY(infoFrame) - y);
	[webView setFrame:newInfoFrame];
}

- (IBAction) buttonPressed:(id)sender;
{
	[selectedPartner setAlpha:0.7];
	[sender setAlpha:1.0];
	
	selectedPartner = sender;
	
	/*
	if( sender == driversButton )
	{
		[self showChildController:driversController];
	}
	else if( sender == teamsButton )
	{
		[htmlController setHtmlFile:@"teams.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == circuitsButton )
	{
		[htmlController setHtmlFile:@"circuits.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == standingsButton )
	{
		[htmlController setHtmlFile:@"standings.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == rulesButton )
	{
		[htmlController setHtmlFile:@"rules.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == partnersButton )
	{
		[htmlController setHtmlFile:@"sponsors.htm"];
		[self showChildController:htmlController];
	}
	else
	{
		[htmlController setHtmlFile:@"home.htm"];
		[self showChildController:htmlController];
	}
	 */
}


@end
