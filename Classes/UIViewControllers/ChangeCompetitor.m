//
//  NewCompetitor.m
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChangeCompetitor.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "GameViewController.h"

@implementation ChangeCompetitor

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


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
}


- (void)dealloc {
	[user release];
	[cancel release];
	[select release];

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[competitorNames release];
	int count = [[[RacePadDatabase Instance]competitorData] rows];
	competitorNames = [[NSMutableArray arrayWithCapacity:count] retain];
	for ( int i = 0; i < count; i++ )
	{
		NSString *s = [[[[RacePadDatabase Instance]competitorData] cell:i Col:1] string];
		[competitorNames addObject:s];
	}
	[competitorNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[user reloadComponent:0];
	[user selectRow:0 inComponent:0 animated:NO];
	if ( [ competitorNames count] )
		currentUser = [competitorNames objectAtIndex:0];
	else
		currentUser = nil;
}

-(void) cancelPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void) selectPressed:(id)sender
{
	[[RacePadCoordinator Instance] requestPrediction:currentUser];
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[p setUser:currentUser];
	[gameController lock];
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [competitorNames count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [competitorNames objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 180;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	currentUser = [competitorNames objectAtIndex:row];
}

- (void) getUser: (GameViewController *)controller
{
	gameController = controller;
	[gameController presentModalViewController:self animated:YES];
}

@end
