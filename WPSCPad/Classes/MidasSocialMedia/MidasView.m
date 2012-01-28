//
//  MidasView.m
//  F1Test
//
//  Created by Andrew Greenshaw on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MidasView.h"

#define kTestDataLen    11

@implementation MidasView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userName.textColor = [UIColor blackColor];
        self.viewType = Midas;
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
	
    NSNumber *aNumber = [NSNumber numberWithFloat:0];
    [self.entryTimings addObject:aNumber];
    [self.entryTimings addObject:aNumber];
    [self.entryTimings addObject:aNumber];
    [self.entryTimings addObject:aNumber];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:3];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:6];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:12];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:16];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:20];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:25];
    [self.entryTimings addObject:aNumber];
	
    [self.dummyEntryName addObject:@"John J"];
    [self.dummyEntryName addObject:@"Freddie F1"];
    [self.dummyEntryName addObject:@"Mary Jane"];
    [self.dummyEntryName addObject:@"Chris"];
    [self.dummyEntryName addObject:@"Hazel I"];
    [self.dummyEntryName addObject:@"Jake BBCF1"];
    [self.dummyEntryName addObject:@"Eddie I BBCF1"];
    [self.dummyEntryName addObject:@"Chris F1 Fan"];
    [self.dummyEntryName addObject:@"Marky Boy"];
    [self.dummyEntryName addObject:@"Kylie M"];
    [self.dummyEntryName addObject:@"R Schumacher"];
    
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    
    [self.dummyEntryComment addObject:@"John J Comment"];
    [self.dummyEntryComment addObject:@"Freddie F1 Comment"];
    [self.dummyEntryComment addObject:@"Mary Jane Comment Mary Jane Comment Mary Jane Comment"];
    [self.dummyEntryComment addObject:@"Chris Comment"];
    [self.dummyEntryComment addObject:@"Hazel I Comment Hazel I Comment Hazel I Comment"];
    [self.dummyEntryComment addObject:@"Jake BBCF1 Comment"];
    [self.dummyEntryComment addObject:@"Eddie I BBCF1 Comment"];
    [self.dummyEntryComment addObject:@"Chris F1 Fan Comment"];
    [self.dummyEntryComment addObject:@"Marky Boy Comment"];
    [self.dummyEntryComment addObject:@"Kylie M Comment"];
    [self.dummyEntryComment addObject:@"R Schumacher Comment"];
    
    [self.dummyEntryUserId addObject:@"@johnj "];
    [self.dummyEntryUserId addObject:@"@freddief1 "];
    [self.dummyEntryUserId addObject:@"@maryjane "];
    [self.dummyEntryUserId addObject:@"@chris "];
    [self.dummyEntryUserId addObject:@"@hazeli "];
    [self.dummyEntryUserId addObject:@"@jakebbc1 "];
    [self.dummyEntryUserId addObject:@"@eddiebbc1 "];
    [self.dummyEntryUserId addObject:@"@chrisf1 "];
    [self.dummyEntryUserId addObject:@"@markyboy "];
    [self.dummyEntryUserId addObject:@"@kyliem "];
    [self.dummyEntryUserId addObject:@"@rschumacher "];
    
}

- (NSString *)getDefaultText{
    return @"message";
}

- (NSString *)getCommentText:(int)row {
    NSString *ret = nil;
    
    NSString *comment = [self.entryComment objectAtIndex:row];
    if ([comment characterAtIndex:0] == '@')
    {
        // Assume starts with a tweet name...
        //(NSRange)rangeOfString:(NSString *)aString
        NSRange rnge = [comment rangeOfString:@" "];
        NSString *tname = [comment substringToIndex:rnge.location];
        NSString *remcomment = [comment substringFromIndex:rnge.location + rnge.length];
        NSString *newcomment = [[NSString alloc] initWithFormat:@"<div><font color=\"blue\">%@</font><font color=\"white\">&nbsp;%@</font></div>", tname, remcomment];
        ret = newcomment;
    }
    else
    {
        ret = [self.entryComment objectAtIndex:row];
    }
    
    return ret;
}

- (CGRect)getTimeTextFrame:(CGFloat)height{
    return CGRectMake(42, 3, 280, 20);
}

- (CGRect)getNameTextFrame{
    return CGRectMake(68, 3, 200, 22);
}

- (CGRect)getCommentTextFrame:(CGFloat)height{
    return CGRectMake(60, 13, 246, height + 15);
}

- (UIColor *)getTextColour {
    UIColor *ret = [UIColor whiteColor];    
    return ret;
}

- (UIColor *)getCellBackColour {
    UIColor *ret = [UIColor colorWithRed: 0.35 green: 0.35 blue: 0.35 alpha: 1];    
    return ret;
}

- (UIImage *)getHeaderIcon {
    UIImage *ret = [UIImage imageNamed:@"Midas-front-layer.png"];
    return ret;
}

- (CGRect)getSendTextFrame {
    return CGRectMake(40, 49, 246, 27);
}

- (UIImage *)getFooterText{
    UIImage *ret = [UIImage imageNamed:@"Midas-title.png"];
    return ret;
}

- (UIImage *)getFooterLogo{
    UIImage *ret = [UIImage imageNamed:@"Midas-icon.png"];
    return ret;
}

- (UIImage *)getSendLogo{
    UIImage *ret = nil;
    return ret;
}

- (UIColor *)getSeparatorColour {
    //UIColor *ret = [UIColor blackColor];    
    UIColor *ret = [UIColor colorWithRed: 0.45 green: 0.45 blue: 0.45 alpha: 1];    
    return ret;
}

- (BOOL)canPostReply{
    return NO;
}

- (CGFloat)heightForRowAtIndexPath:(CGFloat)row{
    NSString *text = [self getUnformattedCommentText:row];
    CGFloat height = [self getTextHeight:text];
    int numoflines = height / 15;
    if (numoflines > 1)
    {
        height += 6;
    }
    if (self.replyRow == row)
    {
        height += 44;
    }
    height += 10;
    
    return height + 20;
}

@end
