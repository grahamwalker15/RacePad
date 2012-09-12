//
//  MidasVotingView.h
//  MidasDemo
//
//  Created by Gareth Griffith on 8/28/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingView.h"

@class MidasVoting;

@interface MidasVotingView : DrawingView
{
    MidasVoting * midasVoting;
    NSString * driver;
    
    UILabel * votesForLabel;
    UILabel * votesAgainstLabel;
    UILabel * ratingLabel;
}

@property (nonatomic, retain) NSString * driver;
@property (nonatomic, retain) UILabel * votesForLabel;
@property (nonatomic, retain) UILabel * votesAgainstLabel;
@property (nonatomic, retain) UILabel * ratingLabel;

@end

