//
//  MatchPadStatsViewController.m
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadStatsViewController.h"
#import "BasePadPopupManager.h"

#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"

#import "MatchPadVideoViewController.h"

@implementation MatchPadStatsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	[super OnTapGestureInView:gestureView AtX:x Y:y];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	[self OnTapGestureInView:gestureView AtX:x Y:y];
}

- (void) willHide
{
	[self hideStatsControllers];
}

-(IBAction)buttonSelected:(id)sender
{
	if(!parentViewController)
		return;
	
	[self hideStatsControllers];

	CGRect superBounds = [parentViewController.view bounds];
	CGRect viewBounds = [self.view bounds];
	float xCentre = (CGRectGetWidth(superBounds) - CGRectGetWidth(viewBounds)) * 0.5;

	if(sender == teamStatsButton || sender == teamStatsLabel)
	{
		if(![[MatchPadTeamStatsManager Instance] viewDisplayed])
		{
			[[MatchPadTeamStatsManager Instance] displayInViewController:parentViewController AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
		}		
	}
	
	if(sender == playerStatsButton || sender == playerStatsLabel)
	{
		if(![[MatchPadPlayerStatsManager Instance] viewDisplayed])
		{
			[[MatchPadPlayerStatsManager Instance] displayInViewController:parentViewController AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
		}		
	}
	
	/*
	if(sender == ballStatsButton || sender == ballStatsLabel)
	{
		if(![[MatchPadBallStatsManager Instance] viewDisplayed])
		{
			[[MatchPadBallStatsManager Instance] displayInViewController:parentViewController AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
		}		
	}
	*/
	
	if(sender == possessionStatsButton || sender == possessionStatsLabel)
	{
		if(![[MatchPadPossessionStatsManager Instance] viewDisplayed])
		{
			[[MatchPadPossessionStatsManager Instance] displayInViewController:parentViewController AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
		}		
	}
	
	if(sender == pitchStatsButton || sender == pitchStatsLabel)
	{
		if(![[MatchPadPitchStatsManager Instance] viewDisplayed])
		{
			[[MatchPadPitchStatsManager Instance] displayInViewController:parentViewController AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
		}		
	}

	if(sender == physicalStatsButton || sender == physicalStatsLabel)
	{
		if(![[MatchPadPhysicalStatsManager Instance] viewDisplayed])
		{
			[[MatchPadPhysicalStatsManager Instance] displayInViewController:parentViewController AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
		}
	}
}

- (void) hideStatsControllers
{
	if([[MatchPadTeamStatsManager Instance] viewDisplayed])
	{
		[[MatchPadTeamStatsManager Instance] hideAnimated:true Notify:false];
	}
	
	if([[MatchPadPlayerStatsManager Instance] viewDisplayed])
	{
		[[MatchPadPlayerStatsManager Instance] hideAnimated:true Notify:false];
	}
	
	if([[MatchPadBallStatsManager Instance] viewDisplayed])
	{
		[[MatchPadBallStatsManager Instance] hideAnimated:true Notify:false];
	}
	
	if([[MatchPadPossessionStatsManager Instance] viewDisplayed])
	{
		[[MatchPadPossessionStatsManager Instance] hideAnimated:true Notify:false];
	}
	
	if([[MatchPadPitchStatsManager Instance] viewDisplayed])
	{
		[[MatchPadPitchStatsManager Instance] hideAnimated:true Notify:false];
	}
    
    if([[MatchPadPhysicalStatsManager Instance] viewDisplayed])
	{
		[[MatchPadPhysicalStatsManager Instance] hideAnimated:true Notify:false];
	}
}


@end

