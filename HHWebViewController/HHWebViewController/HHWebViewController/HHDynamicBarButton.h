//
//  HHDynamicBarButton
//  HHWebViewController
//
//  Created by Donald Angelillo on 2/3/14.
//  Copyright (c) 2014 Donald Angelillo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum HHWebViewButtonType {
    kHHWebViewButtonTypeBackButton,
    kHHWebViewButtonTypeForwardButton,
    kHHWebViewButtonTypeReaderButton
} HHWebViewButtonType;

@interface HHDynamicBarButton : UIButton {
    HHWebViewButtonType hhWebViewButtonType;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL highlighted;

+(instancetype) backButtonViewWithTarget: (id) _target action: (SEL) _action;
+(instancetype) forwardButtonViewWithTarget: (id) _target action: (SEL) _action;
+(instancetype) readerButtonViewWithTarget: (id) _target action: (SEL) _action;


@end
