//
//  HHWebViewController.m
//  HHWebViewController
//
//  Created by Donald Angelillo on 2/3/14.
//  Copyright (c) 2014 Donald Angelillo. All rights reserved.
//

#import "HHWebViewController.h"

@interface HHWebViewController ()

@end

@implementation HHWebViewController

@synthesize url;
@synthesize webView;
@synthesize toolBar;
@synthesize shouldShowControls;
@synthesize shouldHideNavBarOnScroll;
@synthesize shouldHideStatusBarOnScroll;
@synthesize shouldHideToolBarOnScroll;
@synthesize showControlsInNavBarOniPad;

-(instancetype) initWithURL:(NSURL *)_url {
    self = [super initWithNibName: nil bundle: nil];
    
    if (self) {
        self.url = _url;
        self.showControlsInNavBarOniPad = YES;
        self.shouldShowControls = YES;
        self.shouldHideNavBarOnScroll = YES;
        self.shouldHideStatusBarOnScroll = YES;
        self.shouldHideToolBarOnScroll = YES;
        hadStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        isExitingScreen = NO;
    }
    
    return self;
}

#pragma mark -
#pragma mark View Lifecyle
-(void) loadView {
    self.view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = YES;
    
    self.webView = [[UIWebView alloc] initWithFrame: self.view.frame];
    self.webView.autoresizingMask = self.view.autoresizingMask;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview: self.webView];
    
    [self createOrUpdateControls];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self loadURL: self.url];
    
}

-(void) viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"HHWebViewController must be contained in a navigation controller.");
    [super viewWillAppear: animated];
    
    if (self.isMovingToParentViewController) {
        hadToolBarHidden = self.navigationController.toolbarHidden;
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    //force the status bar and nav toolbar back to their original states when this viewController is being popped off stack
    if (self.isMovingFromParentViewController) {
        isExitingScreen = YES;
        
        [[UIApplication sharedApplication] setStatusBarHidden: hadStatusBarHidden withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setToolbarHidden: hadToolBarHidden animated: animated];
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        } else {
            // iOS 6
            [[UIApplication sharedApplication] setStatusBarHidden: hadStatusBarHidden withAnimation:UIStatusBarAnimationFade];
        }
    }
    
    
    //if (!self.showControlsInNavBarOniPad) {
    //    [self.navigationController setToolbarHidden: YES animated: animated];
    //}
}

#pragma mark -
#pragma mark Rotation
-(BOOL) shouldAutorotate {
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


-(BOOL) prefersStatusBarHidden {
    if (isExitingScreen) {
        return hadStatusBarHidden;
    }
    
    if (scrollingDown) {
        return YES;
    }
    
    return NO;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}


#pragma mark -
#pragma mark UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)_webView {
    if (webViewLoadingItems == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    webViewLoadingItems++;
    [self createOrUpdateControls];
}


-(void)webViewDidFinishLoad:(UIWebView *)_webView {
    webViewLoadingItems--;
    
    if (webViewLoadingItems <= 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self createOrUpdateControls];
        
    }
    
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    webViewLoadingItems--;
    
    if (webViewLoadingItems <= 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self createOrUpdateControls];
    }
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    initialContentOffset = scrollView.contentOffset.y;
    previousContentDelta = 0.f;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat prevDelta = previousContentDelta;
    CGFloat delta = scrollView.contentOffset.y - initialContentOffset;
    
    if (delta > 0.f && prevDelta <= 0.f) {
        //down
        scrollingDown = YES;
        [self hideUI];
    } else if (delta < 0.f && prevDelta >= 0.f) {
        //up
        scrollingDown = NO;
        [self showUI];
    }
    previousContentDelta = delta;
}

#pragma mark -
#pragma mark Controls
-(void) createOrUpdateControls {
    if (self.shouldShowControls) {
        
        if (flexiblespace == nil) {
            flexiblespace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
        }
        
        if (backButton == nil) {
            backButton = [[UIBarButtonItem alloc] initWithCustomView: [HHDynamicBarButton backButtonViewWithTarget: self action: @selector(backButtonHit:)]];;
        }
        
        if (forwardButton == nil) {
            forwardButton = [[UIBarButtonItem alloc] initWithCustomView: [HHDynamicBarButton forwardButtonViewWithTarget: self action: @selector(forwardButtonHit:)]];
        }
        
        if (reloadButton == nil) {
            reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(reloadHit:)];
        }
        
        if (stopButton == nil) {
            stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop target: self action: @selector(stopHit:)];
        }
        
        if (readerButton == nil) {
            readerButton = [[UIBarButtonItem alloc] initWithCustomView: [HHDynamicBarButton readerButtonViewWithTarget: self action: @selector(readerButtonHit:)]];
        }
        
        if (actionButton == nil) {
            actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: self action: @selector(actionHit:)];
        }
        
        NSArray *items = nil;
        
        if (webViewLoadingItems > 0) {
            items = @[backButton, forwardButton, flexiblespace, stopButton, flexiblespace, readerButton, flexiblespace, actionButton];
        } else {
            items = @[backButton, forwardButton, flexiblespace, reloadButton, flexiblespace, readerButton, flexiblespace, actionButton];
        }
        
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
            if (self.showControlsInNavBarOniPad) {
                self.navigationItem.rightBarButtonItems = [[items reverseObjectEnumerator] allObjects];
            } else {
                self.toolbarItems = items;
            }
        } else {
            self.toolbarItems = items;
        }
        
        
        backButton.enabled = self.webView.canGoBack;
        forwardButton.enabled = self.webView.canGoForward;
    }
}

-(void) backButtonHit: (id) sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

-(void) forwardButtonHit: (id) sender {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

-(void) reloadHit: (id) sender {
    [self.webView reload];
}

-(void) stopHit: (id) sender {
    [self.webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void) actionHit: (id) sender {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.request.URL] applicationActivities: nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(void) readerButtonHit: (id) sender {
    [self loadURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://www.readability.com/m?url=%@", [[self.url
                                                                                                               absoluteString] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]]];
}


-(void) showUI {
    if (self.shouldHideNavBarOnScroll) {
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden: NO animated: YES];
        }
    }
    
    if (self.shouldHideStatusBarOnScroll) {
        [[UIApplication sharedApplication] setStatusBarHidden: NO withAnimation:UIStatusBarAnimationFade];
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        } else {
            // iOS 6
            [[UIApplication sharedApplication] setStatusBarHidden: NO withAnimation:UIStatusBarAnimationFade];
        }
        
    }
    
    if (self.shouldShowControls) {
        if (self.shouldHideToolBarOnScroll) {
            if (!self.showControlsInNavBarOniPad) {
                [self.navigationController setToolbarHidden: NO animated: YES];
            }
        }
    }
}

-(void) hideUI {
    if (self.shouldHideNavBarOnScroll) {
        if (!self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden: YES animated: YES];
        }
    }
    
    if (self.shouldHideStatusBarOnScroll) {
        [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation:UIStatusBarAnimationFade];
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        } else {
            // iOS 6
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
    }
    
    if (self.shouldShowControls) {
        if (self.shouldHideToolBarOnScroll) {
            if (!self.showControlsInNavBarOniPad) {
                [self.navigationController setToolbarHidden: YES animated: YES];  //
            }
        }
    }
}


#pragma mark -
#pragma mark Loading
-(void) loadURL:(NSURL *)_url {
    if (![_url isEqual: self.url]) {
        self.url = _url;
    }
    
    [self.webView loadRequest: [NSURLRequest requestWithURL: _url]];
}


-(void) setShouldShowControls:(BOOL)_shouldShowControls {
    shouldShowControls = _shouldShowControls;
    
    [self createOrUpdateControls];
}

-(void) setShowControlsInNavBarOniPad:(BOOL)_showControlsInNavBarOniPad {
    if (_showControlsInNavBarOniPad) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            showControlsInNavBarOniPad = _showControlsInNavBarOniPad;
        } else {
            showControlsInNavBarOniPad = NO;
        }
    } else {
        showControlsInNavBarOniPad = _showControlsInNavBarOniPad;
    }
}


-(void) dealloc {
    [self.webView stopLoading];
}

@end


#pragma mark -
#pragma mark Dynamic Button Drawing Class for Browser Chrome
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

