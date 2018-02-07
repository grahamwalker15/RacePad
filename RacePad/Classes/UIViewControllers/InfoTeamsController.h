//
//  InfoTeamsController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/12/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoChildController.h"

@interface InfoTeamsController : InfoChildController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UITableView * teams;
	
	int selectedTeam;
}

- (void) setTeamIndex:(int)index;

@end
