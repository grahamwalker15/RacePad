//
//  AccidentBubbleViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AccidentBubbleViewController.h"
#import "AlertData.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import	"AccidentBubble.h"

@implementation AccidentBubbleViewController

@synthesize accidentView;
@synthesize shown;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[accidentView SetHeading:false];
	accidentView.updating = false;
	[accidentView SetBackgroundAlpha:0];
	accidentView.bubbleController = self;
	
	shown = false;
	[(BackgroundView *)[self view] setStyle:BG_STYLE_ROUNDED_STRAP_WHITE_];
	
	// Add gesture recognizers
 	// [self addTapRecognizerToView:commentaryView];
	// [self addLongPressRecognizerToView:commentaryView];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[accidentView SelectRow:-1];
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return NO;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

- (void) resetWidth
{
	int width = 590;
	CGRect frame = [[self view] frame];
	CGRect vFrame = CGRectMake ( frame.origin.x, frame.origin.y, width, [accidentView standardRowHeight] + 8 );
	
	[[self view] setFrame:vFrame];
}

- (void) sizeCommentary: (int) rowCount FromHeight: (int) fromHeight
{
	if ( rowCount <= 0 )
		return;
	
	if ( rowCount > 10 )
		rowCount = 10;
	
	int height = rowCount * [accidentView standardRowHeight];
	int width = 590;
	if ( height <= fromHeight )
		return;
	
	CGRect frame = [[self view] frame];
	CGRect bFrame = [closeButton frame];
	CGRect vFrame;
	vFrame = CGRectMake ( frame.origin.x, frame.origin.y + frame.size.height - height - 8, width, height + 8 );
	CGRect cFrame = CGRectMake ( 4, 4, width - 8, height );
	CGRect nbFrame = CGRectMake ( vFrame.size.width - bFrame.size.width, 0, bFrame.size.width, bFrame.size.height );
	
	[[self view] setFrame:vFrame];
	[accidentView setFrame:cFrame];
	[closeButton setFrame:nbFrame];
}

- (void) popUp
{
	shown = true;
	accidentView.updating = true;
	[accidentView initialDraw];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	[[self view] setAlpha: 1];
	
	[UIView commitAnimations];
}

- (void) popDown: (bool) animate
{
	if ( shown && animate )
	{
		accidentView.updating = false;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		
		[[self view] setAlpha: 0];
		
		[UIView commitAnimations];
	}
	else
	{
		accidentView.updating = false;
		[[self view] setAlpha: 0];
	}
	
	shown = false;
}

- (IBAction) closePressed:(id)sender
{
	[[AccidentBubble Instance] popDown];
}

@end
