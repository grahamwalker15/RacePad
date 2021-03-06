    //
//  WeatherViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 6/21/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "WeatherViewController.h"
#import "RacePadCoordinator.h"
#import "RacePadTitleBarController.h"
#import "CommentaryBubble.h"

// Pre IOS 5.0 handling of https
@interface NSURLRequest (DummyInterface)
+ (bool)allowsAnyHTTPSCertificateForHost:(NSString *)host;
+ (void)setAllowsAnyHTTPSCertificate:(bool)allow forHost:(NSString *)host;
@end

@implementation WeatherViewController

- (void)viewDidLoad
{
	[webView setDelegate:self];
	[webView setScalesPageToFit:true];

	NSString * url_string = @"http://172.16.51.200";
	NSURL * url = [[NSURL alloc] initWithString:url_string];
	NSURLRequest * request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	[NSURLRequest setAllowsAnyHTTPSCertificate:true forHost:[url host]];

	NSURLConnection * connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	[connection start];
	
	[webView loadRequest:request];
	
	[url release];
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
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary: true];
	
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_LAP_COUNT_VIEW_];
	
	[webView reload];


	[[CommentaryBubble Instance] allowBubbles:[self view] BottomRight: true];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////

- (IBAction)backPressed:(id)sender
{
}

- (IBAction)previousPressed:(id)sender
{	
}

- (IBAction)nextPressed:(id)sender
{
}

- (void)showHTMLContent
{
}

////////////////////////////////////////////////////////////////////////////////
//  UIWebViewDelegate routines

- (void)webViewDidFinishLoad:(UIWebView *)thisWebView
{
	[thisWebView setNeedsDisplay];
}

- (void)webView:(UIWebView *)thisWebView didFailLoadWithError:(NSError *)error
{
	if(error)
	{
		NSString * description = [NSString stringWithString:[error localizedDescription]];
		
		if(description)
		{
			if([error localizedFailureReason])
			{
				description = [description stringByAppendingString:@" - "];
				description = [description stringByAppendingString:[error localizedFailureReason]];
			}
			
			int x = 0;
			
		}
		
	}
}


////////////////////////////////////////////////////////////////////////////////
//  NSURLConnection delegate routines


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return true;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	//[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge]
	
	[[challenge sender] useCredential:[NSURLCredential credentialWithUser:@"FIA" password:@"9PV842EU" persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
	//[[challenge sender] canallAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	//[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge]
	
	[[challenge sender] useCredential:[NSURLCredential credentialWithUser:@"FIA" password:@"9PV842EU" persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
	//[[challenge sender] canallAuthenticationChallenge:challenge];
}

@end
