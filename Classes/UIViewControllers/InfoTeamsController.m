    //
//  InfoTeamsController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/12/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoTeamsController.h"

#import "RacePadDatabase.h"

@implementation InfoTeamsController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		selectedTeam = -1;
	}
    return self;
}

- (void)viewDidLoad
{
	selectedTeam = -1;
	[super viewDidLoad];
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
	CGRect teamsFrame = [teams frame];
	CGRect infoFrame = [webView1 frame];
	
	float spareWidth = CGRectGetMaxX(bgFrame) - CGRectGetMaxX(teamsFrame);
	float spareHeight = CGRectGetHeight(bgFrame);
	
	float xMargin = (spareWidth - CGRectGetWidth(infoFrame)) * 0.5;
	float yMargin = (spareHeight - CGRectGetHeight(infoFrame)) * 0.25;
	
	CGRect newInfoFrame = CGRectMake(CGRectGetMaxX(teamsFrame) + xMargin, yMargin, CGRectGetWidth(infoFrame), CGRectGetHeight(infoFrame));
	[webView1 setFrame:newInfoFrame];
	[webView2 setFrame:newInfoFrame];
}

////////////////////////////////////////////////////////////////////////////
// Table view delegate routines

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MyIdentifier = @"RacePadInfoTeams";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
    }
	
	int indexAtRow = indexPath.row;
	
	switch (indexAtRow)
	{
		case 0:
			cell.textLabel.text = @"Red Bull";
			break;
			
		case 1:
			cell.textLabel.text = @"McLaren";
			break;
			
		case 2:
			cell.textLabel.text = @"Ferrari";
			break;
			
		case 3:
			cell.textLabel.text = @"Mercedes GP";
			break;
			
		case 4:
			cell.textLabel.text = @"Renault";
			break;
			
		case 5:
			cell.textLabel.text = @"Force India";
			break;
			
		case 6:
			cell.textLabel.text = @"Williams";
			break;
			
		case 7:
			cell.textLabel.text = @"Sauber";
			break;
			
		case 8:
			cell.textLabel.text = @"Toro Rosso";
			break;
			
		case 9:
			cell.textLabel.text = @"Lotus";
			break;
			
		case 10:
			cell.textLabel.text = @"HRT";
			break;
			
		case 11:
			cell.textLabel.text = @"Virgin";
			break;
			
		default:
			cell.textLabel.text = nil;
			break;
	}
			
	cell.detailTextLabel.text = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Teams";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int selectedIndex = indexPath.row;
	[self setTeamIndex:selectedIndex];
}

- (void) setTeamIndex:(int)index
{
	// Do nothing if we're still animating a previous transition
	if(animatingViews)
		return;
	
	selectedTeam = index;
	
	switch (index)
	{
		case 0:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoPetronas" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 1:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAabar" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 2:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAutonomy" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 3:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoDeutschePost" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 4:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoMIG" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 5:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoGraham" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 6:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoPirelli" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 7:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoMonster" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 8:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAllianz" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 9:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoStandox" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 10:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoHLloyd" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 11:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoAlpine" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		default:
			[webView1 setHidden:true];
			[webView2 setHidden:true];
			//[fiaLogo setHidden:false];
			break;
	}
}

@end
