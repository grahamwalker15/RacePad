//
//  SettingsViewController.m
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (BOOL) wantTimeControls
{
	return NO;
}

- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible.
{
	// [[TabletState Instance] startTracking:self TrackType:TS_LOCATION];
}

- (void)viewWillDisappear:(BOOL)animated // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	// [[TabletState Instance] stopTracking];
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


- (void)dealloc
{
    [super dealloc];
}

- (IBAction)exitPressed:(id)sender
{
}

- (IBAction)restartPressed:(id)sender
{
}

- (void) addSurveyPoint
{
	double x, y;
	double radius;
	[[TabletState Instance] currentPosition: &x Lat: &y Accuracy: &radius];
	
	NSString * text = [[NSString alloc] initWithFormat: @"%10.6f : %10.6f (%7.3f)", x, y, radius];
	[surveyPosition setText: text];
}

- (IBAction) recordSurveyPressed:(id)sender
{
	[self addSurveyPoint];
}

- (IBAction) surveyTextChanged:(id)sender
{
	[self addSurveyPoint];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	double x, y;
	double radius;
	[[TabletState Instance] currentPosition: &x Lat: &y Accuracy: &radius];
	
	static int counter = 0;
	counter++;

	NSString * text = [[NSString alloc] initWithFormat: @"%10.6f : %10.6f (%7.3f) : %d", x, y, radius, counter];
	[surveyPosition setText: text];
}

@end
