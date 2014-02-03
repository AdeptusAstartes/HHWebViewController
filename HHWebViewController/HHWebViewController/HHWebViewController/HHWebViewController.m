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

-(instancetype) initWithURL:(NSURL *)_url {
    self = [super initWithNibName: nil bundle: nil];
    
    if (self) {
        self.url = _url;
        self.shouldShowControls = YES;
        self.shouldHideNavBarOnScroll = YES;
        self.shouldHideStatusBarOnScroll = YES;
        self.shouldHideToolBarOnScroll = YES;
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
    [self.view addSubview: self.webView];
    
    //self.toolBar = self.navigationController.toolbar;
    
    [self createOrUpdateControls];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadURL: self.url];

}

-(void) viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"HHWebViewController must be contained in a navigation controller.");
    [super viewWillAppear: animated];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    [self.navigationController setToolbarHidden:YES animated: animated];
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
    if (scrollingDown) {
        return YES;
    }
    
    return NO;
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
        self.navigationController.toolbarHidden = NO;
        
        float spacerWidth = 10.0f;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            spacerWidth = 35.0f;
        }
        
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
        
        if (webViewLoadingItems > 0) {
            [self setToolbarItems: @[backButton, forwardButton, flexiblespace, stopButton, flexiblespace, readerButton, flexiblespace, actionButton]];
        } else {
            [self setToolbarItems: @[backButton, forwardButton, flexiblespace, reloadButton, flexiblespace, readerButton, flexiblespace, actionButton]];
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
            [self.navigationController setToolbarHidden: NO animated: YES];
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
            [self.navigationController setToolbarHidden: YES animated: YES];
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


-(void) dealloc {
    [self.webView stopLoading];
}

@end
