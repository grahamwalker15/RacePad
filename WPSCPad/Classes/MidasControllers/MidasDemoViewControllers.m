    //
//  MidasDemoViewControllers.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/23/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasDemoViewControllers.h"

@implementation MidasMasterMenuViewController : MidasBaseViewController

-(IBAction) buttonPressed:(id)sender
{
	if(associatedManager)
	{
		[associatedManager hideAnimated:true Notify:true];
	}
}

@end

@implementation MidasHeadToHeadViewController : MidasBaseViewController
@end

@implementation MidasMyTeamViewController : MidasBaseViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
		
	expanded = false;
	[extensionContainer setHidden:true];
		
	// Tell the RacePadCoordinator that we will be interested in data for views
	// We're not
}

////////////////////////////////////////////////////////////////////////////

- (void) expandView
{
	if(expanded)
		return;
	
	id parentViewController = [[MidasMyTeamManager Instance] parentViewController];
	
	[extensionContainer setHidden:false];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[[MidasMyTeamManager Instance] setPreferredWidth:(288+640)];
	
	if(parentViewController && [parentViewController respondsToSelector:@selector(notifyResizingPopup:)])
		[parentViewController notifyResizingPopup:MIDAS_MY_TEAM_POPUP_];
	
	[UIView commitAnimations];
	
	[expandButton setSelected:true];
	expanded = true;
}

- (void) reduceViewAnimated:(bool)animated
{
	if(!expanded)
		return;
	
	id parentViewController = [[MidasMyTeamManager Instance] parentViewController];
	
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	}
	
	[[MidasMyTeamManager Instance] setPreferredWidth:(288)];
	
	if(parentViewController && [parentViewController respondsToSelector:@selector(notifyResizingPopup:)])
		[parentViewController notifyResizingPopup:MIDAS_MY_TEAM_POPUP_];
	
	if(animated)
	{
		[UIView commitAnimations];
	}
	else
	{
		[extensionContainer setHidden:true];
	}
	
	[expandButton setSelected:false];
	expanded = false;
}

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		if(!expanded)
			[extensionContainer setHidden:true];
	}
}


- (void) onDisplay
{
}

- (void) onHide
{
	if(expanded)
	{
		[self reduceViewAnimated:false];		
	}
}


////////////////////////////////////////////////////////////////////////////

- (IBAction) expandPressed
{
	id parentViewController = [[MidasMyTeamManager Instance] parentViewController];
	
	if(expanded)
	{
		[self reduceViewAnimated:true];		
	}
	else
	{
		if(parentViewController && [parentViewController respondsToSelector:@selector(notifyExclusiveUse:InZone:)])
			[parentViewController notifyExclusiveUse:MIDAS_MY_TEAM_POPUP_ InZone:MIDAS_ZONE_ALL_];
		
		[self expandView];
	}
}

@end

@implementation MidasVIPViewController : MidasBaseViewController
@end

