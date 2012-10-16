//
//  ToggleTaskButton.m
//  MrTickTock
//
//  Created by André Neves on 10/13/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "ToggleTaskButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Pdf.h"
#import "FTPDFAssetRenderer.h"

@implementation ToggleTaskButton

- (void)setup
{
    FTPDFAssetRenderer * renderer = [FTAssetRenderer rendererForPDFNamed:@"start"];
    renderer.targetSize = self.bounds.size;

    renderer.targetColor = [UIColor blueColor];
    UIImage * normalImage = [renderer imageWithCacheIdentifier:@"start-normal"];

    renderer.targetColor = [UIColor redColor];
    UIImage * highlightedImage = [renderer imageWithCacheIdentifier:@"start-highlighted"];

    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self setup];
    }

    return self;
}

@end


