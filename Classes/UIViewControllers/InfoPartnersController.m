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
	[super viewDidLoad];

	selectedPartner = nil;
	placeHolderView = instruction;
	placeHolderAlpha = [placeHolderView alpha];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
 }

- (void)viewWillAppear:(BOOL)animated
{
	selectedPartner = nil;
	[self positionOverlays];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(selectedPartner)
		[selectedPartner setAlpha:0.7];
	
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
	CGRect logoFrame = [partner16 frame];
	CGRect infoFrame = [webView1 frame];
		
	float x = (CGRectGetWidth(bgFrame) - CGRectGetWidth(infoFrame)) * 0.5;
	float y = CGRectGetMaxY(logoFrame) + 20 ;
	
	CGRect newInfoFrame = CGRectMake(x, y, CGRectGetWidth(infoFrame), CGRectGetMaxY(infoFrame) - y);
	[webView1 setFrame:newInfoFrame];
	[webView2 setFrame:newInfoFrame];
	
	if(!selectedPartner)
	{
		[webView1 setHidden:true];
		[webView2 setHidden:true];
		[instruction setHidden:false];
	}
		
}

- (IBAction) buttonPressed:(id)sender;
{
	// Do nothing if we're still animating a previous transition
	if(animatingViews)
		return;
	
	[selectedPartner setAlpha:0.7];
	[sender setAlpha:1.0];
	
	selectedPartner = sender;
	
	if( sender == partner1 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoPetronas" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner2 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAabar" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner3 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAutonomy" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner4 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoDeutschePost" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner5 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoMIG" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner6 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAllianz" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner7 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoGraham" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner8 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoHLloyd" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner9 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoMonster" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner10 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoPirelli" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner11 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoStandox" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner12 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAlpine" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner13 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoEndless" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner14 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoLincoln" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner15 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoStarTrac" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == partner16 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoSTL" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else
	{
		[webView1 setHidden:true];
		[webView2 setHidden:true];
		[instruction setHidden:false];
	}
}


@end
