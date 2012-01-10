//
//  MidasFollowDriverViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/7/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasFollowDriverViewController.h"

#import "MidasPopupManager.h"

@implementation MidasFollowDriverViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self addTapRecognizerToView:container];
	[self addTapRecognizerToView:heading];
	
	expanded = false;
	[extensionContainer setHidden:true];
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

- (void) expandView
{
	if(expanded)
		return;
	
	BasePadViewController * parentController = [[MidasFollowDriverManager Instance] parentViewController];

	[extensionContainer setHidden:false];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[[MidasFollowDriverManager Instance] setPreferredWidth:(590+382-10)];

	if(parentController && [parentController respondsToSelector:@selector(notifyResizingPopup:)])
		[parentController notifyResizingPopup:MIDAS_FOLLOW_DRIVER_POPUP_];

	[UIView commitAnimations];
		
	[expandButton setSelected:true];
	expanded = true;
}

- (void) reduceView;
{
	if(!expanded)
		return;
	
	BasePadViewController * parentController = [[MidasFollowDriverManager Instance] parentViewController];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[[MidasFollowDriverManager Instance] setPreferredWidth:(382)];
	
	if(parentController && [parentController respondsToSelector:@selector(notifyResizingPopup:)])
		[parentController notifyResizingPopup:MIDAS_FOLLOW_DRIVER_POPUP_];
	
	[UIView commitAnimations];
	
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

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading)
	{
		[[MidasFollowDriverManager Instance] hideAnimated:true Notify:true];
	}
}

////////////////////////////////////////////////////////////////////////////

- (IBAction) expandPressed
{
	BasePadViewController * parentController = [[MidasFollowDriverManager Instance] parentViewController];
	
	if(expanded)
	{
		[self reduceView];
	}
	else
	{
		if(parentController && [parentController respondsToSelector:@selector(notifyExclusiveUse:)])
			[parentController notifyExclusiveUse:MIDAS_FOLLOW_DRIVER_POPUP_];
	
		[self expandView];
	}
}


@end
