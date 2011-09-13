//
//  CommentaryBubbleViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CommentaryBubbleViewController.h"
#import "CommentaryData.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import	"CommentaryBubble.h"

@implementation CommentaryBubbleViewController

@synthesize commentaryView;
@synthesize shown;
@synthesize growUp;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[commentaryView SetHeading:false];
	commentaryView.smallFont = true;
	commentaryView.updating = false;
	[commentaryView SetBackgroundAlpha:0];
	commentaryView.bubbleController = self;
	
	shown = false;
	[(BackgroundView *)[self view] setStyle:BG_STYLE_ROUNDED_STRAP_];
	
	// Add gesture recognizers
 	// [self addTapRecognizerToView:commentaryView];
	// [self addLongPressRecognizerToView:commentaryView];

}

- (void)viewWillAppear:(BOOL)animated
{
	[commentaryView SelectRow:-1];
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
	int width = 490;
	CGRect frame = [[self view] frame];
	CGRect vFrame = CGRectMake ( frame.origin.x, frame.origin.y, width, [commentaryView RowHeight] + 8 );
	
	[[self view] setFrame:vFrame];
}

- (void) sizeCommentary: (int) rowCount FromHeight: (int) fromHeight
{
	if ( rowCount <= 0 )
		return;
	
	if ( rowCount > 5 )
		rowCount = 5;
	
	int height = rowCount * [commentaryView RowHeight];
	int width = 490;
	if ( height <= fromHeight )
		return;
	
	CGRect frame = [[self view] frame];
	CGRect bFrame = [closeButton frame];
	CGRect vFrame;
	if ( growUp )
		vFrame = CGRectMake ( frame.origin.x, frame.origin.y + frame.size.height - height - 8, width, height + 8 );
	else
		vFrame = CGRectMake ( frame.origin.x, frame.origin.y, width, height + 8 );
	CGRect cFrame = CGRectMake ( 4, 4, width - 8, height );
	CGRect nbFrame = CGRectMake ( vFrame.size.width - bFrame.size.width, 0, bFrame.size.width, bFrame.size.height );

	[[self view] setFrame:vFrame];
	[commentaryView setFrame:cFrame];
	[closeButton setFrame:nbFrame];
}

- (void) popUp
{
	shown = true;
	commentaryView.updating = true;
	[commentaryView initialDraw];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[[self view] setAlpha: 1];
	[UIView commitAnimations];
}

- (void) popDown: (bool) animate
{
	if ( shown && animate )
	{
		commentaryView.updating = false;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[[self view] setAlpha: 0];
		[UIView commitAnimations];
	}
	else
	{
		commentaryView.updating = false;
		[[self view] setAlpha: 0];
	}
	shown = false;
}

- (IBAction) closePressed:(id)sender
{
	[[CommentaryBubble Instance] popDown];
}

@end
