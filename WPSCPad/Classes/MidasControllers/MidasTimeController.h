//
//  MidasTimeController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 9/17/12.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "BasePadTimeController.h"
#import "MovieView.h"

@interface MidasTimeController : BasePadTimeController <MovieViewDelegate>
{
    
}

+(MidasTimeController *)Instance;

@end
