//
//  HHWebViewController.h
//  HHWebViewController
//
//  Created by Donald Angelillo on 2/3/14.
//  Copyright (c) 2014 Donald Angelillo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HHWebViewControllerShareCompletionBlock)(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError, NSURL *sharedURL);

@interface HHWebViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    NSURL *url;
    UIWebView *webView;
    UIToolbar *toolBar;
    BOOL shouldShowControls;
    BOOL shouldControlsImmediately;
    BOOL shouldHideNavBarOnScroll;
    BOOL shouldHideStatusBarOnScroll;
    BOOL shouldHideToolBarOnScroll;
    BOOL showControlsInNavBarOniPad;
    BOOL shouldPreventChromeHidingOnScrollOnInitialLoad;
    
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
    UIBarButtonItem *reloadButton;
    UIBarButtonItem *stopButton;
    UIBarButtonItem *actionButton;
    UIBarButtonItem *readerButton;
    UIBarButtonItem *flexiblespace;
    
    int webViewLoadingItems;
    
    float initialContentOffset;
    float previousContentDelta;
    BOOL scrollingDown;
    BOOL hadStatusBarHidden;
    BOOL hadToolBarHidden;
    BOOL isExitingScreen;
    
    HHWebViewControllerShareCompletionBlock shareCompletionBlock;
    NSString *customShareMessage;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, assign) BOOL shouldShowControls;
@property (nonatomic, assign) BOOL shouldControlsImmediately;
@property (nonatomic, assign) BOOL shouldHideNavBarOnScroll;
@property (nonatomic, assign) BOOL shouldHideStatusBarOnScroll;
@property (nonatomic, assign) BOOL shouldHideToolBarOnScroll;
@property (nonatomic, assign) BOOL showControlsInNavBarOniPad;
@property (nonatomic, assign) BOOL shouldPreventChromeHidingOnScrollOnInitialLoad;
@property (nonatomic, strong) NSString *customShareMessage;
@property (nonatomic, copy) HHWebViewControllerShareCompletionBlock shareCompletionBlock;

-(instancetype) initWithURL: (NSURL *) _url;
-(void) loadURL: (NSURL *) _url;

@end


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
