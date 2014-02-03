//
//  ArrowView.h
//  HHWebViewController
//
//  Created by Donald Angelillo on 2/3/14.
//  Copyright (c) 2014 Donald Angelillo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArrowView : UIView {
    BOOL enabled;
    BOOL highlighted;
    BOOL isBackButton;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL highlighted;

+(instancetype) backButtonView;
+(instancetype) forwardButtonView;


@end
