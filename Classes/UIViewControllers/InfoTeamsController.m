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
	[super viewDidLoad];

	selectedTeam = -1;
	
	[tableBG removeFromSuperview];
	[teams setBackgroundView:tableBG];
	[teams setSeparatorColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8]];	
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
	
	float spareWidth = CGRectGetMaxX(bgFrame) - CGRectGetMaxX(teamsFrame);
	float spareHeight = CGRectGetHeight(bgFrame);
	
	float xMargin = spareWidth * 0.05;
	float yMargin = spareHeight * 0.1;
	
	CGRect newInfoFrame = CGRectMake(CGRectGetMaxX(teamsFrame) + xMargin, yMargin, spareWidth - xMargin * 2, spareHeight - yMargin * 2);
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
	return nil;//@"Teams";
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
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamRBR" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 1:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamMcLaren" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 2:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamFerrari" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 3:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamMGP" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 4:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamRenault" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 5:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamFIndia" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 6:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamWilliams" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 7:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamSauber" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 8:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamToroRosso" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 9:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamLotus" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 10:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamHRT" ofType:@"htm"]];
			[self showHTMLContent];
			break;
			
		case 11:
			[self setHtmlFile:[[NSBundle mainBundle] pathForResource:@"InfoTeamVirgin" ofType:@"htm"]];
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
