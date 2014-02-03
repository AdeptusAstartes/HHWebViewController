//
//  ArrowView.m
//  HHWebViewController
//
//  Created by Donald Angelillo on 2/3/14.
//  Copyright (c) 2014 Donald Angelillo. All rights reserved.
//

#import "ArrowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ArrowView

@synthesize enabled;
@synthesize highlighted;

-(id)initWithFrame:(CGRect)frame andDirection: (int) _direction {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        isBackButton = _direction;
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor redColor].CGColor;
    }
    return self;
}

+(instancetype) backButtonView {
    return [[ArrowView alloc] initWithFrame: CGRectMake(0, 0, 30, 30) andDirection: 1];
}

+(instancetype) forwardButtonView {
    return [[ArrowView alloc] initWithFrame: CGRectMake(0, 0, 30, 30) andDirection: 0];
}

-(void) drawRect:(CGRect)rect {
    [super drawRect: rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineWidth(context, 2);
    
    if (self.enabled) {
        if (self.highlighted) {
            CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        } else {
            CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
        }
        CGContextSetAlpha(context, 1.0f);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetAlpha(context, 0.5f);
    }
    
    CGFloat x;
    CGFloat y;
    CGFloat radius;
    
    switch (isBackButton) {
        case 0:
            x = 21;
            y = CGRectGetMidY(self.bounds);
            radius = 9;
            CGContextMoveToPoint(context, x - radius, y - radius);
            CGContextAddLineToPoint(context, x, y);
            CGContextAddLineToPoint(context, x - radius, y + radius);
            CGContextStrokePath(context);
            break;
            
            
        case 1:
            x = 9;
            y = CGRectGetMidY(self.bounds);
            radius = 9;
            CGContextMoveToPoint(context, x + radius, y + radius);
            CGContextAddLineToPoint(context, x, y);
            CGContextAddLineToPoint(context, x + radius, y - radius);
            CGContextStrokePath(context);
            break;
            
        default:
            break;
    }
    
    
}

@end
