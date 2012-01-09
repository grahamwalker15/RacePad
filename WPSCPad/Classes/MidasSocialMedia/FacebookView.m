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
    self.entryTime = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    
    for (int i = 0; i < kTestDataLen; i++)
    {
        [self.entryTime addObject:[self getTimeEntry:i]];
    }
    
    [self.entryName addObject:@"Chris"];
    [self.entryName addObject:@"Hazel I"];
    [self.entryName addObject:@"Jake BBCF1"];
    [self.entryName addObject:@"Eddie I BBCF1"];
    [self.entryName addObject:@"R Schumacher"];
    [self.entryName addObject:@"Nigel Mansell"];
    [self.entryName addObject:@"Chris F1 Fan"];
    [self.entryName addObject:@"Marky Boy"];
    [self.entryName addObject:@"Kylie M"];
    
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    
    [self.entryComment addObject:@"Chris Comment"];
    [self.entryComment addObject:@"Hazel I Comment Hazel I Comment Hazel I Comment"];
    [self.entryComment addObject:@"Jake BBCF1 Comment"];
    [self.entryComment addObject:@"Eddie I BBCF1 Comment"];
    [self.entryComment addObject:@"R Schumacher Comment"];
    [self.entryComment addObject:@"Nigel Mansell Comment Nigel Mansell Comment"];
    [self.entryComment addObject:@"Chris F1 Fan Comment"];
    [self.entryComment addObject:@"Marky Boy Comment"];
    [self.entryComment addObject:@"Kylie M Comment"];
    
    [self.entryUserId addObject:@"@chris "];
    [self.entryUserId addObject:@"@hazeli "];
    [self.entryUserId addObject:@"@jakebbc1 "];
    [self.entryUserId addObject:@"@eddiebbc1 "];
    [self.entryUserId addObject:@"@rschumacher "];
    [self.entryUserId addObject:@"@nigelmansell "];
    [self.entryUserId addObject:@"@chrisf1 "];
    [self.entryUserId addObject:@"@markyboy "];
    [self.entryUserId addObject:@"@kyliem "];
    
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
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
    return CGRectMake(12, 50, 276, 31);
}

- (CGRect)getTimeTextFrame:(CGFloat)height{
    return CGRectMake(47, height + 10, 280, 20);
}

- (CGRect)getNameTextFrame{
    return CGRectMake(0, 0, 1, 1);
}

- (CGRect)getCommentTextFrame:(CGFloat)height{
    return CGRectMake(38, 2, 256, height + 10);
}

- (UIColor *)getCellBackColour {
    UIColor *ret = [UIColor colorWithRed: 0.75 green: 0.75 blue: 0.85 alpha: 1];    
    return ret;
}

- (NSString *)getDefaultText{
    return @"write a comment";
}

- (UIImage *)getHeaderIcon {
    UIImage *ret = [UIImage imageNamed:@"Twitter-front-layer.png"];
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
    UIColor *ret = [UIColor whiteColor];    
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
    return height + 36;
}

@end
