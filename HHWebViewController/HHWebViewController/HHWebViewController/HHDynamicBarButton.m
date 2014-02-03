//
//  HHDynamicBarButton
//  HHWebViewController
//
//  Created by Donald Angelillo on 2/3/14.
//  Copyright (c) 2014 Donald Angelillo. All rights reserved.
//

#import "HHDynamicBarButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation HHDynamicBarButton

-(id)initWithFrame:(CGRect)frame direction: (HHWebViewButtonType) _buttonType target: (id) _target action: (SEL) _action {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        hhWebViewButtonType = _buttonType;
        
        [self addTarget: _target action: _action forControlEvents: UIControlEventTouchUpInside];
    }
    return self;
}

+(instancetype) backButtonViewWithTarget:(id)_target action:(SEL)_action {
    return [[HHDynamicBarButton alloc] initWithFrame: CGRectMake(0, 0, 30, 30) direction: kHHWebViewButtonTypeBackButton target:_target action: _action];
}

+(instancetype) forwardButtonViewWithTarget:(id)_target action:(SEL)_action {
    return [[HHDynamicBarButton alloc] initWithFrame: CGRectMake(0, 0, 30, 30) direction: kHHWebViewButtonTypeForwardButton target: _target action: _action];
}

+(instancetype) readerButtonViewWithTarget:(id)_target action:(SEL)_action {
    return [[HHDynamicBarButton alloc] initWithFrame: CGRectMake(0, 0, 30, 30) direction: kHHWebViewButtonTypeReaderButton target: _target action: _action];
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
    
    switch (hhWebViewButtonType) {
        case kHHWebViewButtonTypeBackButton:
            x = 9;
            y = CGRectGetMidY(self.bounds);
            radius = 9;
            CGContextMoveToPoint(context, x + radius, y + radius);
            CGContextAddLineToPoint(context, x, y);
            CGContextAddLineToPoint(context, x + radius, y - radius);
            CGContextStrokePath(context);
            break;
            
        case kHHWebViewButtonTypeForwardButton:
            x = 21;
            y = CGRectGetMidY(self.bounds);
            radius = 9;
            CGContextMoveToPoint(context, x - radius, y - radius);
            CGContextAddLineToPoint(context, x, y);
            CGContextAddLineToPoint(context, x - radius, y + radius);
            CGContextStrokePath(context);
            break;
            
        case kHHWebViewButtonTypeReaderButton:
            CGContextSetLineWidth(context, 1.5);
            
            CGContextMoveToPoint(context, 5, 5);
            CGContextAddLineToPoint(context, 25, 5);
            
            CGContextMoveToPoint(context, 5, 12);
            CGContextAddLineToPoint(context, 25, 12);
            
            CGContextMoveToPoint(context, 5, 19);
            CGContextAddLineToPoint(context, 25, 19);
            
            CGContextMoveToPoint(context, 5, 26);
            CGContextAddLineToPoint(context, 15, 26);
            
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
