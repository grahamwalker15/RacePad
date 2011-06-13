    //
//  BasePadTitleBar.m
//  BasePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadTitleBarController.h"
#import "BasePadCoordinator.h"
#import "TitleBarViewController.h"
#import "BasePadSponsor.h"

#import "UIConstants.h"

@implementation BasePadTitleBarController

static BasePadTitleBarController * instance_ = nil;

+(BasePadTitleBarController *)Instance
{
	assert ( instance_ );
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		instance_ = self;
		
		titleBarController = [[TitleBarViewController alloc] initWithNibName:@"TitleBarView" bundle:nil];
		
		helpController = nil;
		helpPopover = nil;
				
		liveMode = true;
	}
	
	return self;
}


- (void)dealloc
{
	[titleBarController release];
	[helpPopover release];
	[helpController release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) onStartUp
{
}

- (void) displayInViewController:(UIViewController *)viewController
{	
	CGRect super_bounds = [viewController.view bounds];
	CGRect title_controller_bounds = [titleBarController.view bounds];
	
	[viewController.view addSubview:titleBarController.view];
	
	CGRect frame = CGRectMake(super_bounds.origin.x, super_bounds.origin.y, super_bounds.size.width, title_controller_bounds.size.height);
	[titleBarController.view setFrame:frame];
	
	[[titleBarController helpButton] addTarget:self action:@selector(HelpPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	float current_time = [[BasePadCoordinator Instance] currentTime];	
	[self updateTime:current_time];
	
	[self updateSponsor];
		
	[[BasePadCoordinator Instance] SetViewDisplayed:titleBarController];
}

- (void) updateSponsor
{
	[[titleBarController sponsorButton] setImage:[[BasePadSponsor Instance]getSponsorLogo:BPS_LOGO_REGULAR_] forState:UIControlStateNormal];
}

- (void) updateLiveIndicator
{
	if([[BasePadCoordinator Instance] liveMode])
		[self showLiveIndicator];
	else
		[self hideLiveIndicator];
		
}

- (void) hideLiveIndicator
{
	if(liveMode)
	{
		NSMutableArray * items = [[NSMutableArray alloc] init];
		
		UIBarButtonItem * liveIndicator = [titleBarController playStateBarItem];
		
		for (UIBarButtonItem * item in [titleBarController allItems])
		{
			if(item != liveIndicator)
				[items addObject:item];
		}
		
		[[titleBarController toolbar] setItems:items animated:true];
		
		liveMode = false;
	}
}

- (void) showLiveIndicator
{
	if(!liveMode)
	{
		[[titleBarController toolbar] setItems:[titleBarController allItems] animated:true];
		liveMode = true;
	}
}

- (void) hide
{
	[[BasePadCoordinator Instance] SetViewHidden:titleBarController];
	[titleBarController.view removeFromSuperview];
}

- (void) updateTime:(float)time
{
	int h = (int)(time / 3600.0); time -= h * 3600;
	int m = (int)(time / 60.0); time -= m * 60;
	int s = (int)(time);
	NSString * time_string = [NSString stringWithFormat:@"%d:%02d:%02d", h, m, s];
	[[titleBarController timeCounter] setTitle:time_string forState:UIControlStateNormal];
}

- (void) setEventName: (NSString *)event
{
	[[titleBarController eventName] setTitle:event forState:UIControlStateNormal];
}

//////////////////////////////////////////////////////////////////////////////////
// Actions
//////////////////////////////////////////////////////////////////////////////////

- (IBAction)PlayPressed:(id)sender
{
}

- (IBAction)HelpPressed:(id)sender
{
	BasePadViewController * currentController = [[BasePadCoordinator Instance] registeredViewController];
	
	if(!currentController)
		return;
	
	HelpViewController * newHelpController = [currentController helpController];
	if(!newHelpController)
		return;
	
	if(!helpController || !helpPopover || helpController != newHelpController)
	{
		if(helpController)
		{
			if(helpController != newHelpController)
			{
				[helpController release];	
				helpController = [newHelpController retain];
			}
		}
		else
		{
			helpController = [newHelpController retain];
		}

		if(helpPopover)
			[helpPopover setContentViewController:helpController];
		else
			helpPopover = [[UIPopoverController alloc] initWithContentViewController:helpController];
	}
	
	[helpPopover setDelegate:self];
	[helpController setParentPopover:helpPopover];

	CGSize popoverSize = CGSizeMake(600,650);
	
	[helpPopover setPopoverContentSize:popoverSize];
	[helpPopover presentPopoverFromBarButtonItem:[titleBarController helpBarButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}

@end
