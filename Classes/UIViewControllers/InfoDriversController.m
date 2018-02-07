//
//  InfoDriversController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoDriversController.h"

#import "RacePadDatabase.h"

@implementation InfoDriversController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
	}
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[tableBG removeFromSuperview];
	[drivers setBackgroundView:tableBG];
	[drivers setSeparatorColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8]];
	
	UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"LightTexture.png"]];
	[driverInfoBase setBackgroundColor:background];
	[background release];

	[self setDriverIndex:0];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////


- (void) positionOverlays
{
	CGRect bgFrame = [backgroundView frame];
	CGRect driversFrame = [drivers frame];
	CGRect infoFrame = [driverInfoBase frame];
	
	float spareWidth = CGRectGetMaxX(bgFrame) - CGRectGetMaxX(driversFrame);
	float spareHeight = CGRectGetHeight(bgFrame);
	
	float xMargin = (spareWidth - CGRectGetWidth(infoFrame)) * 0.5;
	float yMargin = (spareHeight - CGRectGetHeight(infoFrame)) * 0.25;
	
	CGRect newInfoFrame = CGRectMake(CGRectGetMaxX(driversFrame) + xMargin, yMargin, CGRectGetWidth(infoFrame), CGRectGetHeight(infoFrame));
	[driverInfoBase setFrame:newInfoFrame];
}

////////////////////////////////////////////////////////////////////////////
// Table view delegate routines

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[RacePadDatabase Instance]driverNames] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MyIdentifier = @"RacePadInfoDrivers";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
    }
	
	int driverIndexAtRow = indexPath.row;
		
	DriverName *driver = [[[RacePadDatabase Instance]driverNames] driver:driverIndexAtRow];
	cell.textLabel.text = driver.name;
	cell.detailTextLabel.text = driver.team;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;//@"Drivers";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int selectedDriverIndex = indexPath.row;		
	//[drivers deselectRowAtIndexPath:[drivers indexPathForSelectedRow] animated:false];
	//[drivers selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];
	[self setDriverIndex:selectedDriverIndex];
}

- (void) setDriverIndex:(int)index
{
	// Get the driver name
	DriverName *driver = [[[RacePadDatabase Instance]driverNames] driver:index];
	
	if(!driver)
	{
		[self emptyDriverInfoTable];
		return;
	}
	
	NSString * name = [driver name];
	if(!name || [name length] < 1)
	{
		[self emptyDriverInfoTable];
		return;
	}
	
	NSString * abbName = [driver abbr];
	if(!abbName || [abbName length] < 1)
	{
		[self emptyDriverInfoTable];
		return;
	}
	
	NSRange spaceRange = [name rangeOfString:@" "];
	
	if(spaceRange.location >= [name length])
	{
		[self emptyDriverInfoTable];
		return;
	}
	
	NSString * firstname = [name substringToIndex:spaceRange.location];
	NSString * surname = [name substringFromIndex:(spaceRange.location + 1)];
	NSString * teamname = [driver team];
	
	[driverFirstName setText:firstname];
	[driverSurname setText:surname];
	[team setText:teamname];
	
	// Get image list for the car images
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
	
	return;
}

- (void) emptyDriverInfoTable
{
	[driverFirstName setText:@"No"];
	[driverSurname setText:@"Drivers"];
	[team setText:@""];

	[photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
	[helmet setImage:[UIImage imageNamed:@"NoHelmet.png"]];
	[car setImage:nil];
	
	[age setText:@""];
	[races setText:@""];
	[championships setText:@""];
	[wins setText:@""];
	[poles setText:@""];
	[fastestLaps setText:@""];
	[lastPos setText:@""];
	[points setText:@""];
	[lastPoints setText:@""];
}

@end
