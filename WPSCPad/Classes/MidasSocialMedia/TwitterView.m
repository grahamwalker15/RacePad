//
//  TwitterView.m
//  F1Test
//
//  Created by Andrew Greenshaw on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterView.h"

#define kTestDataLen    15

@implementation TwitterView

@synthesize lastTweetId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewType = Twitter;
    }
    return self;
}

#ifdef USE_REAL_TWITTER

- (void)sendTweet:(NSString *)tweet {
    if (([tweet length] > 0) && [TWTweetComposeViewController canSendTweet]) 
    {
        // Create account store, followed by a twitter account identifier
        // At this point, twitter is the only account type available
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
        [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
         {
             // Did user allow us access?
             if (granted == YES)
             {
                 // Populate array with all available Twitter accounts
                 NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                 
                 // Sanity check
                 if ([arrayOfAccounts count] > 0) 
                 {
                     // Keep it simple, use the first account available
                     ACAccount *twitAccount = [arrayOfAccounts objectAtIndex:0];
                     NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                     [params setObject:tweet forKey:@"status"];
                     
                     NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
                     TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodPOST];
                     
                     [request setAccount:twitAccount];  
                     
                     [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                      {
                          //NSString *output = [NSString stringWithFormat:@"HTTP Response with %i", [urlResponse statusCode]];
                          //NSLog(@"send tweet resp = %@", output);
                      }];
                 }
             }
         }];
    }
}

- (IBAction)sendButtonTweet:(id)sender
{
    [self sendTweet:self.sendText.text];
    [self hideView:0.4];
    self.sendText.text = @"";
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
}

- (void)scrollToEnd {
    if ([self.entryTime count] > 0)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.socialTable scrollToRowAtIndexPath :ipath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}
- (void)updateTable:(id)object
{
    [self.socialTable reloadData];
    [self.socialTable beginUpdates];
    [self.socialTable endUpdates];
}

- (void)addEntry:(NSString *)text {
    [self sendTweet:text];
}

- (void)loadTweets
{
    if (self.replying == NO) // will have to get the updates next time if replying....
    {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
        [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
         {
             // Did user allow us access?
             if (granted == YES)
             {
                 // Populate array with all available Twitter accounts
                 NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                 
                 // Sanity check
                 if ([arrayOfAccounts count] > 0) 
                 {
                     // Keep it simple, use the first account available
                     ACAccount *twitAccount = [arrayOfAccounts objectAtIndex:0];
                     
                     //NSLog(@"User = %@", twitAccount.username);
                     //NSLog(@"User Id = %@", twitAccount.identifier);
                     
                     NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                     [params setObject:@"1" forKey:@"include_entities"];
                     [params setObject:@"14" forKey:@"count"];
                     if (self.lastTweetId > 0L)
                     {
                         // Only want tweets since last one (ie latest)
                         NSString *count = [[NSString alloc] initWithFormat:@"%llu", self.lastTweetId];
                         [params setObject:count forKey:@"since_id"];
                     }
                     
                     //  The endpoint that we wish to call
                     NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
                     
                     //  Build the request with our parameter 
                     TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodGET];
                     
                     // Post the request
                     [request setAccount:twitAccount];
                     
                     // Block handler to manage the response
                     [request performRequestWithHandler:^(NSData *rponseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                      {
                          NSString *responseString = [[NSString alloc] initWithData:rponseData encoding:NSUTF8StringEncoding];
                          //NSLog(@"resp %@", responseString);
                          //NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
                          if (error != nil) 
                          {
                              // inspect the contents of error 
                              NSLog(@"%@", error);
                          } 
                          else 
                          {
                              NSError *jsonError = nil;
                              NSArray *timeline = [responseString JSONValue];
                              if (jsonError == nil && timeline && [timeline count] > 0) 
                              {                          
                                  // at this point, we have an object that we can parse
                                  for (int i = [timeline count] - 1; i >= 0; i--)
                                  {
                                      NSDictionary *aTweet = [timeline objectAtIndex:i];
                                      NSDictionary *aUser = [aTweet objectForKey:@"user"];
                                      NSLog(@"%@", aTweet);
                                      //NSLog(@"%@", [aTweet objectForKey:@"text"]);
                                      //NSLog(@"%@", [aTweet objectForKey:@"created_at"]);
                                      //NSLog(@"%@", [aUser objectForKey:@"name"]);
                                      //NSLog(@"%@", [aUser objectForKey:@"screen_name"]);
                                      //NSLog(@"%@", [aUser objectForKey:@"profile_image_url"]);
                                      
                                      NSString *ltime = [aTweet objectForKey:@"created_at"];
                                      NSRange rnge = NSMakeRange(11, 5);
                                      [self.entryTime insertObject:[ltime substringWithRange:rnge] atIndex:0];
                                      [self.entryName insertObject:[aUser objectForKey:@"name"] atIndex:0];
                                      [self.entryImage insertObject:[aUser objectForKey:@"profile_image_url"] atIndex:0];
                                      NSString *text = [aTweet objectForKey:@"text"];
                                      text = [text stringByReplacingOccurrencesOfString:@" \n" withString:@" "];
                                      text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                                      [self.entryComment insertObject:text atIndex:0];
                                      NSString *userId = [[NSString alloc] initWithFormat:@"@%@ ", [aUser objectForKey:@"screen_name"]];
                                      [self.entryUserId insertObject:userId atIndex:0];
                                      [self.entryReplied insertObject:@"NO" atIndex:0];                                  
									  
                                      NSURL *url = [NSURL URLWithString:[self.entryImage objectAtIndex:0]];
                                      NSData *data = [NSData dataWithContentsOfURL:url];
                                      UIImage *tmpImage = [UIImage imageWithData:data];                                          
                                      [self.entryImage replaceObjectAtIndex:0 withObject:tmpImage];
                                      
                                      if (i == 0)
                                      {
                                          // Save tweet id
                                          NSString *tweetId = [aTweet objectForKey:@"id"];
                                          if (tweetId)
                                          {
                                              self.lastTweetId = [tweetId longLongValue] + 1L;
                                          }
                                      }
                                  }
                                  [self performSelectorOnMainThread:@selector(updateTable:) withObject:nil waitUntilDone:NO];
                              } 
                              else 
                              { 
                                  // inspect the contents of jsonError
                                  //NSLog(@"%@", jsonError);
                              }
                          }
                      }];
                 }
             }
         }];
    }
}

#endif

- (void)loadData {
    self.lastTweetId = 0;
    self.entryTimings = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryTime = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryReplied = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
	
    self.dummyEntryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
	
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 0 * 60 + 15)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 0 * 60 + 35)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 0 * 60 + 55)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 2 * 60 + 15)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 3 * 60 + 31)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 3 * 60 + 52)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 4 * 60 + 19)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 4 * 60 + 31)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 10 * 60 + 25)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 10 * 60 + 41)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 10 * 60 + 45)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 12 * 60 + 5)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 12 * 60 + 15)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 12 * 60 + 35)]];
    [self.entryTimings addObject:[NSNumber numberWithFloat:(14*3600 + 13 * 60 + 0)]];
	
    [self.dummyEntryName addObject:@"David Coulthard"];
    [self.dummyEntryName addObject:@"Martin Brundle"];
    [self.dummyEntryName addObject:@"Marussia Racing"];
    [self.dummyEntryName addObject:@"Martin Brundle"];
    [self.dummyEntryName addObject:@"Fan Forum"];
    [self.dummyEntryName addObject:@"Tim Lovejoy"];
    [self.dummyEntryName addObject:@"David Coulthard"];
    [self.dummyEntryName addObject:@"Jake Humphrey"];
    [self.dummyEntryName addObject:@"Tim Lovejoy"];
    [self.dummyEntryName addObject:@"Fan Forum"];
    [self.dummyEntryName addObject:@"Tim Lovejoy"];
    [self.dummyEntryName addObject:@"Tim Lovejoy"];
    [self.dummyEntryName addObject:@"Fan Forum"];
    [self.dummyEntryName addObject:@"Jake Humphrey"];
    [self.dummyEntryName addObject:@"Marussia Racing"];
    
    [self.dummyEntryUserId addObject:@"@coulthardF1 "];
    [self.dummyEntryUserId addObject:@"@mbrundleF1 "];
    [self.dummyEntryUserId addObject:@"@MarussiaF1 "];
    [self.dummyEntryUserId addObject:@"@mbrundleF1 "];
    [self.dummyEntryUserId addObject:@"@planetf1 "];
    [self.dummyEntryUserId addObject:@"@timlovejoy "];
	[self.dummyEntryUserId addObject:@"@coulthardF1 "];
	[self.dummyEntryUserId addObject:@"@JakeHumphrey "];
    [self.dummyEntryUserId addObject:@"@timlovejoy "];
    [self.dummyEntryUserId addObject:@"@planetf1  "];
    [self.dummyEntryUserId addObject:@"@timlovejoy "];
    [self.dummyEntryUserId addObject:@"@timlovejoy "];
    [self.dummyEntryUserId addObject:@"@planetf1 "];
    [self.dummyEntryUserId addObject:@"@JakeHumphrey "];
    [self.dummyEntryUserId addObject:@"@MarussiaF1 "];
	
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_CoulthardF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_mBrundleF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_MarussiaF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_mBrundleF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_PlanetF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_TimLovejoy.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_CoulthardF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_jakeHumphrey.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_TimLovejoy.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_PlanetF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_TimLovejoy.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_TimLovejoy.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_PlanetF1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_jakeHumphrey.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"_MarussiaF1.png"]];
    
    [self.dummyEntryComment addObject:@"Here we go for the warm up lap - look out for Alonso off the line"];
    [self.dummyEntryComment addObject:@"Vettel will be hoping for a good clean start. Webber will be hoping he doesn't go backwards."];
    [self.dummyEntryComment addObject:@"Timo and Jerome are really fired up for this one! They both really like this track - the fastest of the season."];
    [self.dummyEntryComment addObject:@"The cars are lining up on the grid. I just love the atmosphere in Monza."];
    [self.dummyEntryComment addObject:@"They're off - three abreast!!"];
    [self.dummyEntryComment addObject:@"What was Luizzi doing? That was crazy."];
    [self.dummyEntryComment addObject:@"Unlucky for Nico!"];
    [self.dummyEntryComment addObject:@"Great start Alonso! Shame about the safety car."];
    [self.dummyEntryComment addObject:@"Vettel will get him after the safety car."];
    [self.dummyEntryComment addObject:@"Look at Michael. He's flying."];
    [self.dummyEntryComment addObject:@"Check out Hamilton's onboard on Midas..."];
    [self.dummyEntryComment addObject:@"He's hitting the lmiter halfway down the straight!"];
    [self.dummyEntryComment addObject:@"Oh no! There was no way Webber was going to get by there."];
    [self.dummyEntryComment addObject:@"Fantastic move by Vettel. He was on the grass at 200mph!"];
    [self.dummyEntryComment addObject:@"Bad luck for Jerome today."];
    
#ifdef USE_REAL_TWITTER
    if ([TWTweetComposeViewController canSendTweet]) 
    {
        [self loadTweets];
    }
    [NSTimer scheduledTimerWithTimeInterval:90 target:self selector:@selector(loadTweets) userInfo:nil repeats:YES];
#endif
    
    {        
#ifndef INTEGRATED_IN_MIDAS
        self.shad1.hidden = NO;
        self.shad2.hidden = NO;
        self.shad2_1.hidden = NO;
        self.shad3.hidden = NO;
        self.shad4.hidden = NO;
#endif
    }
}

/* Not sure why this was overridden - difference is just that scrollToEnd is immediate
- (void)__checkForNewMessages:(CGFloat)mTime {
    if (mTime >= 0.0 && self.replying == NO)
    {
        for (int i = 0; i < [self.entryTimings count]; i++)
        {
            CGFloat aFloat = [[self.entryTimings objectAtIndex:i] floatValue];
            if (mTime > aFloat - 0.1 && mTime < aFloat + 0.1)
            {
                [self insertDummyEntry:i];
                [self.socialTable reloadData];
                [self scrollToEnd];
            }
        }
    }
}
*/

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
