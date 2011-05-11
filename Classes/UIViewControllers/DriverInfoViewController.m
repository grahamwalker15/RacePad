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
	
	// Get image list for the driver images
	RacePadDatabase *database = [RacePadDatabase Instance];
	ImageListStore * image_store = [database imageListStore];

	ImageList *photoImageList = image_store ? [image_store findList:@"DriverPhotos"] : nil;
	
	if(photoImageList)
	{
		UIImage * image = [photoImageList findItem:abbName];
		if(image)
			[photo setImage:image];
		else
			[photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
	}
	else
	{
		[photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
	}
	
	ImageList *helmetImageList = image_store ? [image_store findList:@"DriverHelmets"] : nil;
	
	if(helmetImageList)
	{
		UIImage * image = [helmetImageList findItem:abbName];
		if(image)
			[helmet setImage:image];
		else
			[helmet setImage:[UIImage imageNamed:@"NoHelmet.png"]];
	}
	else
	{
		[helmet setImage:[UIImage imageNamed:@"NoHelmet.png"]];
	}
	
	ImageList *carImageList = image_store ? [image_store findList:@"MiniCars"] : nil;
	
	if(carImageList)
	{
		UIImage * image = [carImageList findItem:abbName];
		if(image)
			[car setImage:image];
		else
			[car setImage:nil];
	}
	else
	{
		[car setImage:nil];
	}
	
	DriverInfoRecord * driverInfo = [[[RacePadDatabase Instance]driverInfo] driverInfoByAbbName:abbName];
	
	if(driverInfo)
	{
		[age setText:[NSString stringWithFormat:@"%d", [driverInfo age]]];
		[races setText:[NSString stringWithFormat:@"%d", [driverInfo races]]];
		[championships setText:[NSString stringWithFormat:@"%d", [driverInfo championships]]];
		[wins setText:[NSString stringWithFormat:@"%d", [driverInfo wins]]];
		[poles setText:[NSString stringWithFormat:@"%d", [driverInfo poles]]];
		[fastestLaps setText:[NSString stringWithFormat:@"%d", [driverInfo fastestLaps]]];
		[lastPos setText:[NSString stringWithFormat:@"%d", [driverInfo lastPos]]];

		float pointsVal = [driverInfo points];		
		if((pointsVal - truncf(pointsVal)) < 0.01)
			[points setText:[NSString stringWithFormat:@"%d", (int)pointsVal]];
		else
			[points setText:[NSString stringWithFormat:@"%.1f", pointsVal]];
		
		float lastPointsVal = [driverInfo lastPoints];		
		if((lastPointsVal - truncf(lastPointsVal)) < 0.01)
			[lastPoints setText:[NSString stringWithFormat:@"%d", (int)lastPointsVal]];
		else
			[lastPoints setText:[NSString stringWithFormat:@"%.1f", lastPointsVal]];
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
