//
//  MidasDemoViewControllers.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/23/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasDemoViewControllers.h"

#import	"BasePadPrefs.h"

@implementation MidasHeadToHeadViewController : MidasBaseViewController
@end

@implementation MidasMyTeamViewController : MidasBaseViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
		
	expanded = false;
	[extensionContainer setHidden:true];
		
	[self addTapRecognizerToView:container];

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
	
	[[MidasMyTeamManager Instance] setPreferredWidth:(250+373)];
	
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
	
	[[MidasMyTeamManager Instance] setPreferredWidth:(250)];
	
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
	if(!expanded)
		[extensionContainer setHidden:true];
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

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == container)
	{
		if(expanded)
			[self reduceViewAnimated:true];		
		else
			[self expandView];
	}
	else
	{
		[super OnTapGestureInView:gestureView AtX:x Y:y];
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

@implementation MidasSetupViewController

static MidasSetupViewController * setupInstance_ = nil;

+(MidasSetupViewController *)Instance
{
	if(!setupInstance_)
		setupInstance_ = [[MidasSetupViewController alloc] initWithNibName:@"MidasSetup" bundle:nil];
	
	return setupInstance_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[sm_name_edit_ setText:[[BasePadPrefs Instance] getPref:@"socialMediaFullName"]];
	[sm_nickname_edit_ setText:[[BasePadPrefs Instance] getPref:@"socialMediaNickname"]];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible.
{
	[sm_name_edit_ setText:[[BasePadPrefs Instance] getPref:@"socialMediaFullName"]];
	[sm_nickname_edit_ setText:[[BasePadPrefs Instance] getPref:@"socialMediaNickname"]];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Overridden to allow any orientation.
	if(interfaceOrientation == UIInterfaceOrientationPortrait)
		return NO;
	
	if(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;
	
	if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		return YES;
	
	if(interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		return YES;
	
	return NO;
	
}

-(IBAction)TextFieldChanged:(id)sender
{
	NSString *text = [sender text];
	
	if(sender == sm_name_edit_)
		[[BasePadPrefs Instance] setPref:@"socialMediaFullName" Value:text ];		
	else if(sender == sm_nickname_edit_)
		[[BasePadPrefs Instance] setPref:@"socialMediaNickname" Value:text ];
	
	[[BasePadPrefs Instance] save];
}

-(IBAction)closePressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

@end

