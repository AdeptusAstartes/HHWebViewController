//
//  ArrowView.m
//  HHWebViewController
//
//  Created by Donald Angelillo on 2/3/14.
//  Copyright (c) 2014 Donald Angelillo. All rights reserved.
//

#import "ArrowBarButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation ArrowBarButton

-(id)initWithFrame:(CGRect)frame direction: (int) _direction target: (id) _target action: (SEL) _action {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        isBackButton = _direction;
        
        [self addTarget: _target action: _action forControlEvents: UIControlEventTouchUpInside];
    }
    return self;
}

+(instancetype) backButtonViewWithTarget:(id)_target action:(SEL)_action {
    return [[ArrowBarButton alloc] initWithFrame: CGRectMake(0, 0, 30, 30) direction: 1 target:_target action: _action];
}

+(instancetype) forwardButtonViewWithTarget:(id)_target action:(SEL)_action {
    return [[ArrowBarButton alloc] initWithFrame: CGRectMake(0, 0, 30, 30) direction: 0 target: _target action: _action];
}

-(void) drawRect:(CGRect)rect {
    [super drawRect: rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineWidth(context, 2);
    
    if (self.isEnabled) {
        if (self.isHighlighted) {
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

-(void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted: highlighted];
    [self setNeedsDisplay];
    
}

-(void) setEnabled:(BOOL)enabled {
    [super setEnabled: enabled];
    [self setNeedsDisplay];
}

@end
