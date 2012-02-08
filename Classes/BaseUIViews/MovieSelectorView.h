//
//  MovieSelectorView.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/22/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleListView.h"
#import "TableData.h"
#import "BasePadMedia.h"
#import "BasePadVideoSource.h"

@interface MovieSelectorView : SimpleListView
{
}

- (BasePadVideoSource *) GetMovieSourceAtCol:(int)col;

@end
