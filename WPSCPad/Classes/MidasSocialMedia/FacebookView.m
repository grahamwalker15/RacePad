//
//  FacebookView.m
//  F1Test
//
//  Created by Andrew Greenshaw on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookView.h"

#define kTestDataLen    9

@implementation FacebookView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)loadData {
    self.entryTimings = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryTime = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    
    self.dummyEntryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
	
    NSNumber *aNumber = [NSNumber numberWithFloat:1];
    [self.entryTimings addObject:aNumber];
    [self.entryTimings addObject:aNumber];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:3];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:6];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:10];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:12];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:16];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:20];
    [self.entryTimings addObject:aNumber];
	
    [self.dummyEntryName addObject:@"Chris"];
    [self.dummyEntryName addObject:@"Hazel I"];
    [self.dummyEntryName addObject:@"Jake BBCF1"];
    [self.dummyEntryName addObject:@"Eddie I BBCF1"];
    [self.dummyEntryName addObject:@"R Schumacher"];
    [self.dummyEntryName addObject:@"Nigel Mansell"];
    [self.dummyEntryName addObject:@"Chris F1 Fan"];
    [self.dummyEntryName addObject:@"Marky Boy"];
    [self.dummyEntryName addObject:@"Kylie M"];
    
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    
    [self.dummyEntryComment addObject:@"Chris Comment"];
    [self.dummyEntryComment addObject:@"Hazel I Comment Hazel I Comment Hazel I Comment"];
    [self.dummyEntryComment addObject:@"Jake BBCF1 Comment"];
    [self.dummyEntryComment addObject:@"Eddie I BBCF1 Comment"];
    [self.dummyEntryComment addObject:@"R Schumacher Comment"];
    [self.dummyEntryComment addObject:@"Nigel Mansell Comment Nigel Mansell Comment"];
    [self.dummyEntryComment addObject:@"Chris F1 Fan Comment"];
    [self.dummyEntryComment addObject:@"Marky Boy Comment"];
    [self.dummyEntryComment addObject:@"Kylie M Comment"];
    
    [self.dummyEntryUserId addObject:@"@chris "];
    [self.dummyEntryUserId addObject:@"@hazeli "];
    [self.dummyEntryUserId addObject:@"@jakebbc1 "];
    [self.dummyEntryUserId addObject:@"@eddiebbc1 "];
    [self.dummyEntryUserId addObject:@"@rschumacher "];
    [self.dummyEntryUserId addObject:@"@nigelmansell "];
    [self.dummyEntryUserId addObject:@"@chrisf1 "];
    [self.dummyEntryUserId addObject:@"@markyboy "];
    [self.dummyEntryUserId addObject:@"@kyliem "];
}

- (NSString *)getTimeEntry:(int)offset
{
    NSString *currentTime = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    if (offset >= 0)
    {
        currentTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(-2000 + offset * 129)]];
    }
    else
    {
        currentTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
    return currentTime;
}

- (CGRect)getSendTextFrame {
    return CGRectMake(10, 49, 280, 20);
}

- (CGRect)getTimeTextFrame:(CGFloat)height{
    return CGRectMake(43, height + 7, 280, 20);
}

- (CGRect)getNameTextFrame{
    return CGRectMake(0, 0, 1, 1);
}

- (CGRect)getCommentTextFrame:(CGFloat)height{
    return CGRectMake(35, 2, 256, height + 10);
}

- (UIColor *)getCellBackColour {
    UIColor *ret = [UIColor colorWithRed: 0.79 green: 0.79 blue: 0.85 alpha: 1];    
    return ret;
}

- (NSString *)getDefaultText{
    return @"write a comment";
}

- (UIImage *)getHeaderIcon {
    UIImage *ret = [UIImage imageNamed:@"Facebook-front-layer.png"];
    return ret;
}

- (UIImage *)getFooterIcon{
    UIImage *ret = [UIImage imageNamed:@"facebook-selected.png"];
    return ret;
}

- (UIImage *)getFooterText{
    UIImage *ret = [UIImage imageNamed:@"Facebook-title.png"];
    return ret;
}

- (UIImage *)getFooterLogo{
    UIImage *ret = [UIImage imageNamed:@"Facebook-icon.png"];
    return ret;
}

- (UIImage *)getSendLogo{
    UIImage *ret = nil;
    return ret;
}

- (UIImage *)getRepliedIcon{
    UIImage *ret = nil;
    return ret;
}

- (NSString *)getReplyPrefix:(int)row {
    return ([self.entryUserId objectAtIndex:row]);
}

- (NSString *)getCommentText:(int)row {    
    NSString *newcomment = [[NSString alloc] initWithFormat:@"<div><font color=\"blue\">%@</font><font color=\"black\">&nbsp;%@</font></div>", 
                            [self.entryName objectAtIndex:row], [self.entryComment objectAtIndex:row]];
    
    return newcomment;
}

- (NSString *)getUnformattedCommentText:(int)row {    
    NSString *newcomment = [[NSString alloc] initWithFormat:@"%@ %@", 
                            [self.entryName objectAtIndex:row], [self.entryComment objectAtIndex:row]];
    
    return newcomment;
}

- (UIColor *)getSeparatorColour {
    //UIColor *ret = [UIColor whiteColor];    
    UIColor *ret = [UIColor colorWithRed: 0.69 green: 0.69 blue: 0.75 alpha: 1];    
    return ret;
}

- (BOOL)canPostReply{
    return NO;
}

- (BOOL)canLike{
    return YES;
}

- (CGFloat)heightForRowAtIndexPath:(CGFloat)row{
    NSString *text = [self getUnformattedCommentText:row];
    CGFloat height = [self getTextHeight:text];
    int numoflines = height / 15;
    if (numoflines > 1)
    {
        height += 6;
    }
    return height + 30;
}

@end
