    //
//  InfoRulesController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/11/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoRulesController.h"

@implementation InfoRulesController


- (void)viewDidLoad
{
	[super viewDidLoad];

	htmlTransition = UIViewAnimationTransitionFlipFromLeft;
	selectedRules = nil;
	
	/*
	[rules1 setOutline:true];
	[rules2 setOutline:true];
	[rules3 setOutline:true];
	[rules4 setOutline:true];
	[rules5 setOutline:true];
	[rules6 setOutline:true];
	[rules7 setOutline:true];
	[rules8 setOutline:true];
	[rules9 setOutline:true];
	[rules10 setOutline:true];
	[rules11 setOutline:true];
	[rules12 setOutline:true];
	*/
	
	placeHolderView = fiaLogo;
	placeHolderAlpha = [placeHolderView alpha];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	selectedRules = nil;
	[fiaLogo setHidden:false];

	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(selectedRules)
		[selectedRules setSelected:false];
	
	selectedRules = nil;
	
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
	CGRect buttonFrame = [rules1 frame];
	CGRect imageFrame = [fiaLogo frame];
	
	float spareWidth = CGRectGetMaxX(bgFrame) - CGRectGetMaxX(buttonFrame);
	float spareHeight = CGRectGetHeight(bgFrame);
	
	float webXMargin = spareWidth * 0.1;
	float webYMargin = spareHeight * 0.1;
	
	float imageXMargin = (spareWidth - CGRectGetWidth(imageFrame)) * 0.5;
	float imageYMargin = (spareHeight - CGRectGetHeight(imageFrame)) * 0.5;
	
	CGRect newWebFrame = CGRectMake(CGRectGetMaxX(buttonFrame) + webXMargin, webYMargin, spareWidth - webXMargin * 2, spareHeight - webYMargin * 2);
	[webView1 setFrame:newWebFrame];
	[webView2 setFrame:newWebFrame];
	
	CGRect newImageFrame = CGRectMake(CGRectGetMaxX(buttonFrame) + imageXMargin, imageYMargin, CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
	[fiaLogo setFrame:newImageFrame];
	
	if(!selectedRules)
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
	
	[selectedRules setSelected:false];
	[sender setSelected:true];
	
	selectedRules = sender;
	
	if( sender == rules1 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoPetronas" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules2 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAabar" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules3 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAutonomy" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules4 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoDeutschePost" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules5 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoMIG" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules6 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAllianz" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules7 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoGraham" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules8 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoHLloyd" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules9 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoMonster" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules10 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoPirelli" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules11 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoStandox" ofType:@"htm"]];
		[self showHTMLContent];
	}
	else if( sender == rules12 )
	{
		[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAlpine" ofType:@"htm"]];
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