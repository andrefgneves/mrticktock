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

@synthesize running = _running;


- (void)setRunning:(BOOL)running
{
    _running = running;

    FTPDFAssetRenderer * renderer = [FTAssetRenderer rendererForPDFNamed:_running ? @"pause" : @"start"];
    renderer.targetSize = self.bounds.size;

    renderer.targetColor = _running ? [UIColor whiteColor] : [UIColor colorWithRed:0.278 green:0.565 blue:0.702 alpha:1.000];
    UIImage * normalImage = [renderer imageWithCacheIdentifier:[NSString stringWithFormat:@"%@-normal", _running ? @"running" : @"paused"]];

    renderer.targetColor = [UIColor blackColor];
    UIImage * highlightedImage = [renderer imageWithCacheIdentifier:@"highlighted"];

    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.running = NO;
    }

    return self;
}

@end


