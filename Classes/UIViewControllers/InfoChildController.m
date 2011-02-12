//
//  InfoChildController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoChildController.h"
#import "InfoViewController.h"

@implementation InfoChildController

@synthesize htmlFile;
@synthesize htmlTransition;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// This view is always displayed as a subview
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];

		htmlFile = nil;
		webViewCurrent = 0;
		
		webViewFront = nil;
		webViewBack = nil;
		
		htmlTransition = UIViewAnimationTransitionCurlUp;
		placeHolderView = nil;
		placeHolderAlpha = 1.0;
	}
	
    return self;
}

- (void)viewDidLoad
{
	[webView1 setDelegate:self];
	[webView2 setDelegate:self];
	
	[super viewDidLoad];
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
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
	[self positionOverlays];
	
	if(htmlFile)
	{		
		NSURL *url = [NSURL fileURLWithPath:htmlFile];
		NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
		[webView1 loadRequest:request];
		
		[request release];
		
		webViewCurrent = 0;
		webViewFront = nil;
		webViewBack = webView1;
	}
	else
	{
		webViewCurrent = 0;
		webViewFront = nil;
		webViewBack = nil;
	}

}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideOverlays];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self showOverlays];
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[self positionOverlays];
 	[UIView commitAnimations];
	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////

- (void)positionOverlays
{
}

- (void)showOverlays
{
}

- (void)hideOverlays
{
}

- (IBAction)backPressed:(id)sender
{
	[(InfoViewController *)[self parentViewController] hideChildController:true];
}

- (IBAction)previousPressed:(id)sender
{	
}

- (IBAction)nextPressed:(id)sender
{
}

- (void)showHTMLContent
{
	if(htmlFile)
	{
		if( webViewCurrent == 0 )
		{
			webViewFront = nil;
			webViewBack = webView1;
		}
		else if( webViewCurrent == 1)
		{
			webViewFront = webView1;
			webViewBack = webView2;
		}
		else
		{
			webViewFront = webView2;
			webViewBack = webView1;
		}
			
		NSURL *url = [NSURL fileURLWithPath:htmlFile];
		NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
		[webViewBack loadRequest:request];
		[request release];
	}
	else
	{
		webViewCurrent = 0;
		
		webViewFront = nil;
		webViewBack = nil;
		
		[webView1 setHidden:true];
		[webView2 setHidden:true];
		[placeHolderView setHidden:false];
	}
}

////////////////////////////////////////////////////////////////////////////////
//  UIWebViewDelegate routines

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if( webViewCurrent == 0 || !webViewFront || !webViewBack)
		[self fadeWebView:webView];
	else
		[self animateWebView:webView];
}

- (void)fadeWebView:(UIWebView *)webView
{
	animatingViews = true;
	
	[webView setAlpha:0.0];
	[webView setHidden:false];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[placeHolderView setAlpha:0.0];
	[webView setAlpha:1.0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(htmlSwapAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

   
- (void)animateWebView:(UIWebView *)webView
{
	animatingViews = true;
	
	[[webViewBack superview] bringSubviewToFront:webViewBack]; // Hidden, so we don't see it
	[[webViewFront superview] bringSubviewToFront:webViewFront];
	
	[webViewBack setAlpha:1.0];
	[webViewBack setHidden:false];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[webViewFront setAlpha:0.0];
	[UIView setAnimationTransition:htmlTransition forView:webViewFront cache:false];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(htmlSwapAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}
	   
- (void) htmlSwapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[webViewFront setHidden:true];
		[webViewFront setAlpha:1.0];

		[placeHolderView setHidden:true];
		[placeHolderView setAlpha:placeHolderAlpha];
		
		if( webViewBack == webView1)
			webViewCurrent = 1;
		else if( webViewBack == webView2)
			webViewCurrent = 2;
		else
			webViewCurrent = 0;
		
		animatingViews = false;
	}
}

@end
