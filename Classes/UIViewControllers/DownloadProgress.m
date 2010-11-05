    //
//  DownloadProgress.m
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadProgress.h"
#import "RacePadCoordinator.h"


@implementation DownloadProgress

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[eventName setText:event];
	[sessionName setText:session];
	[progressView setProgress:sizeLoaded/(float)sizeToLoad];
}

- (void)dealloc {
	[event release];
	[session release];
    [super dealloc];
}

- (void) setProject:(NSString *)inEvent SessionName:(NSString *)inSession SizeInMB:(int) sizeInMB
{
	event = [inEvent retain];
	session = [inSession retain];
	sizeToLoad = sizeInMB;
}

- (void) setProgress:(int) sizeInMB
{
	sizeLoaded = sizeInMB;
	[progressView setProgress:sizeLoaded/(float)sizeToLoad];
}

- (void) cancelPressed:(id)sender
{
	if ( sender == cancelButton )
	{
		[[RacePadCoordinator Instance] cancelDownload];
	}
}

@end
