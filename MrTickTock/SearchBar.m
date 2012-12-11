//
//  SearchBar.m
//  MrTickTock
//
//  Created by André Neves on 10/18/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "SearchBar.h"
#import "UIImage+Utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation SearchBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        // Remove the top 1px black border
        self.layer.masksToBounds = YES;

        // The UITextField doesn't fill the whole search bar, so we force the bar's background to white
        self.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] andSize:self.frame.size];
    }

    return self;
}

@end
