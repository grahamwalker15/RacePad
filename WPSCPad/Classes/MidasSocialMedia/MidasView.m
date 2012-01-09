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
    
    [self.entryName addObject:@"John J"];
    [self.entryName addObject:@"Freddie F1"];
    [self.entryName addObject:@"Mary Jane"];
    [self.entryName addObject:@"Chris"];
    [self.entryName addObject:@"Hazel I"];
    [self.entryName addObject:@"Jake BBCF1"];
    [self.entryName addObject:@"Eddie I BBCF1"];
    [self.entryName addObject:@"Chris F1 Fan"];
    [self.entryName addObject:@"Marky Boy"];
    [self.entryName addObject:@"Kylie M"];
    [self.entryName addObject:@"R Schumacher"];
    
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.entryImage addObject:[UIImage imageNamed:@"user1.png"]];
    
    [self.entryComment addObject:@"John J Comment"];
    [self.entryComment addObject:@"Freddie F1 Comment"];
    [self.entryComment addObject:@"Mary Jane Comment Mary Jane Comment Mary Jane Comment"];
    [self.entryComment addObject:@"Chris Comment"];
    [self.entryComment addObject:@"Hazel I Comment Hazel I Comment Hazel I Comment"];
    [self.entryComment addObject:@"Jake BBCF1 Comment"];
    [self.entryComment addObject:@"Eddie I BBCF1 Comment"];
    [self.entryComment addObject:@"Chris F1 Fan Comment"];
    [self.entryComment addObject:@"Marky Boy Comment"];
    [self.entryComment addObject:@"Kylie M Comment"];
    [self.entryComment addObject:@"R Schumacher Comment"];
    
    [self.entryUserId addObject:@"@johnj "];
    [self.entryUserId addObject:@"@freddief1 "];
    [self.entryUserId addObject:@"@maryjane "];
    [self.entryUserId addObject:@"@chris "];
    [self.entryUserId addObject:@"@hazeli "];
    [self.entryUserId addObject:@"@jakebbc1 "];
    [self.entryUserId addObject:@"@eddiebbc1 "];
    [self.entryUserId addObject:@"@chrisf1 "];
    [self.entryUserId addObject:@"@markyboy "];
    [self.entryUserId addObject:@"@kyliem "];
    [self.entryUserId addObject:@"@rschumacher "];
    
    [self.entryReplied addObject:@"NO"];
    [self.entryReplied addObject:@"NO"];
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

- (UIColor *)getTextColour {
    UIColor *ret = [UIColor whiteColor];    
    return ret;
}

- (UIColor *)getCellBackColour {
    UIColor *ret = [UIColor colorWithRed: 0.35 green: 0.35 blue: 0.35 alpha: 1];    
    return ret;
}

- (CGRect)getSendTextFrame {
    return CGRectMake(12, 50, 276, 31);
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
    UIColor *ret = [UIColor blackColor];    
    return ret;
}

- (BOOL)canPostReply{
    return NO;
}

@end
