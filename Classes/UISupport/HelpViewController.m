    //
//  HelpViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 1/25/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

@synthesize parentPopover;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
        // Custom initialization
		parentPopover = nil;
		
		helpButtonCurrent = nil;
		helpTextCurrent = nil;
		helpTextPrevious = nil;

    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewDidLoad
{
	UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"PredictionBG.png"]];
	[backgroundView setBackgroundColor:background];
	[background release];

	[self getHTMLForView:helpTextDefault WithIndex:0];
	[self getHTMLForView:helpText1 WithIndex:1];
	[self getHTMLForView:helpText2 WithIndex:2];
	[self getHTMLForView:helpText3 WithIndex:3];
	[self getHTMLForView:helpText4 WithIndex:4];
	[self getHTMLForView:helpText5 WithIndex:5];
	[self getHTMLForView:helpText6 WithIndex:6];
	[self getHTMLForView:helpText7 WithIndex:7];
	[self getHTMLForView:helpText8 WithIndex:8];
	[self getHTMLForView:helpText9 WithIndex:9];
	[self getHTMLForView:helpText10 WithIndex:10];

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	if(helpButtonCurrent)
		[helpButtonCurrent setSelected:false];

	if(helpTextCurrent)
		[helpTextCurrent setHidden:true];
	
	if(helpTextDefault)
		[helpTextDefault setHidden:false];
	
	helpTextCurrent = helpTextDefault;
	helpButtonCurrent = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
	if(helpButtonCurrent)
		[helpButtonCurrent setSelected:false];
	
	if(helpTextCurrent)
		[helpTextCurrent setHidden:true];
	
	helpButtonCurrent = nil;
	helpTextCurrent = nil;

	[super viewDidUnload];
 }


- (void)dealloc
{
    [super dealloc];
}

- (IBAction) helpButtonPressed:(id)sender
{
	if(helpButtonCurrent)
		[helpButtonCurrent setSelected:false];
	
	helpButtonCurrent = (UIButton *)sender;

	if(helpButtonCurrent)
		[helpButtonCurrent setSelected:true];
	
	helpTextPrevious = helpTextCurrent;
	
	if(sender == helpButton1)
		helpTextCurrent = helpText1;
	else if(sender == helpButton2)
		helpTextCurrent = helpText2;
	else if(sender == helpButton3)
		helpTextCurrent = helpText3;
	else if(sender == helpButton4)
		helpTextCurrent = helpText4;
	else if(sender == helpButton5)
		helpTextCurrent = helpText5;
	else if(sender == helpButton6)
		helpTextCurrent = helpText6;
	else if(sender == helpButton7)
		helpTextCurrent = helpText7;
	else if(sender == helpButton8)
		helpTextCurrent = helpText8;
	else if(sender == helpButton9)
		helpTextCurrent = helpText9;
	else if(sender == helpButton10)
		helpTextCurrent = helpText10;
	
	// Do nothing if there's no change
	if(helpTextCurrent == helpTextPrevious)
		return;
	
	// Otherwise, animate swap of text views
	[[helpTextPrevious superview] bringSubviewToFront:helpTextPrevious];
	[helpTextCurrent setHidden:false];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
	[helpTextPrevious setAlpha:0.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:helpTextPrevious cache:true];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(textSwapAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void) textSwapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[helpTextPrevious setHidden:true];
		[helpTextPrevious setAlpha:1.0];
	}
}

- (IBAction) closePressed:(id)sender
{
	if(parentPopover)
	{
		[parentPopover dismissPopoverAnimated:true];
	}
}

///////////////////////////////////////////////////////////////////////////////
// Virtual method for loading text into web views

- (void) getHTMLForView:(UIWebView *)webView WithIndex:(int)index
{
	if(!webView)
		return;
	
	NSMutableString * html = [[NSMutableString alloc] init];
	[html appendString:@"<html><head><meta name=""RacePad Help"" content=""width=300""/></head><body>"];
	
	switch(index)
	{
		case 0:
			[html appendString:@"Welcome to RacePad Help."];
			[html appendString:@"<p>Tap on any red question mark buttons to get specific information about that area of the screen."];
			break;
			
		case 1:
			[html appendString:@"<h3>Page 1</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 2:
			[html appendString:@"<h3>Page 2</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 3:
			[html appendString:@"<h3>Page 3</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 4:
			[html appendString:@"<h3>Page 4</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 5:
			[html appendString:@"<h3>Page 5</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 6:
			[html appendString:@"<h3>Page 6</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 7:
			[html appendString:@"<h3>Page 7</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
						
		case 8:
			[html appendString:@"<h3>Page 8</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 9:
			[html appendString:@"<h3>Page 9</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
			
		case 10:
			[html appendString:@"<h3>Page 10</h3>"];
			[html appendString:@"<p>Racepad Help"];
			break;
	}
	
	[html appendString:@"</body</html>"];

	[webView loadHTMLString:html baseURL:nil];
	
	[html release];	
}

@end
