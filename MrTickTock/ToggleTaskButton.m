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
#import "Constants.h"

@implementation ToggleTaskButton

- (void)setRunning:(BOOL)running
{
    _running = running;

    FTPDFAssetRenderer * renderer = [FTAssetRenderer rendererForPDFNamed:_running ? @"pause" : @"start"];
    renderer.targetSize = self.bounds.size;

    _color = _running ? [UIColor whiteColor] : [UIColor colorWithWhite:0.555 alpha:1.000];

    renderer.targetColor = _color;

    UIImage * normalImage = [renderer imageWithCacheIdentifier:[NSString stringWithFormat:@"%@-normal-button", _running ? @"running" : @"paused"]];

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


