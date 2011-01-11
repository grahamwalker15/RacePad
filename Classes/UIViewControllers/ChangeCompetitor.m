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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
        // Custom initialization
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
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
}


- (void)dealloc
{
	[user release];
	[cancel release];

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
	[user reloadData];
}

-(void) cancelPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void) newUserPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:NO];
	[gameController makeNewUser];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [competitorNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"RacePadGame";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
    }
	
	cell.textLabel.text = [competitorNames objectAtIndex:indexPath.row];
	cell.detailTextLabel.text = nil;
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Competitors";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *currentUser = [competitorNames objectAtIndex:indexPath.row];
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[p setUser:currentUser];
	[gameController lock];
	[self dismissModalViewControllerAnimated:YES];
	[[RacePadCoordinator Instance] requestPrediction:currentUser];
}

- (void) getUser: (GameViewController *)controller
{
	gameController = controller;
	[gameController presentModalViewController:self animated:YES];
}

@end
