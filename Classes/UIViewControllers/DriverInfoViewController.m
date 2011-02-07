    //
//  DriverInfoViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/7/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverInfoViewController.h"

#import "RacePadDatabase.h"

@implementation DriverInfoViewController

@synthesize parentPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        parentPopover = nil;
    }
    return self;
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

- (bool) setDriverIndex:(int)index
{
	// Get the driver name
	DriverName *driver = [[[RacePadDatabase Instance]driverNames] driver:index];
	
	if(!driver)
		return false;
	
	NSString * name = [driver name];
	if(!name || [name length] < 1)
		return false;
	
	NSString * abbName = [driver abbr];
	if(!abbName || [abbName length] < 1)
		return false;
	
	NSRange spaceRange = [name rangeOfString:@" "];
	
	if(spaceRange.location >= [name length])
		return false;
	
	NSString * firstname = [name substringToIndex:spaceRange.location];
	NSString * surname = [name substringFromIndex:(spaceRange.location + 1)];
	NSString * teamname = [driver team];
	
	[driverFirstName setText:firstname];
	[driverSurname setText:surname];
	[team setText:teamname];
	
	// Get image list for the car images
	RacePadDatabase *database = [RacePadDatabase Instance];
	ImageListStore * image_store = [database imageListStore];
	ImageList *imageList = nil;//image_store ? [image_store findList:@"MiniCars"] : nil;
	
	if(imageList)
	{
		UIImage * image = [imageList findItem:abbName];
		if(image)
			[photo setImage:image];
		else
			[photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
	}
	else
	{
		[photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
	}

		
	return true;
}

- (IBAction) closePressed:(id)sender
{
	if(parentPopover)
	{
		[parentPopover dismissPopoverAnimated:false];
	}
}

@end
