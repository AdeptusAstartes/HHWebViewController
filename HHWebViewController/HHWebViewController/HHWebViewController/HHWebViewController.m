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
@synthesize shouldHideNavBarOnScroll;
@synthesize shouldHideStatusBarOnScroll;
@synthesize shouldHideToolBarOnScroll;

-(instancetype) initWithURL:(NSURL *)_url {
    self = [super initWithNibName: nil bundle: nil];
    
    if (self) {
        self.url = _url;
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
    
    self.navigationController.toolbarHidden = NO;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadURL: self.url];

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
}


-(void)webViewDidFinishLoad:(UIWebView *)_webView {
    webViewLoadingItems--;
    
    if (webViewLoadingItems <= 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }
    
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];

}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    webViewLoadingItems--;
    
    if (webViewLoadingItems <= 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    
    if (self.shouldHideToolBarOnScroll) {
        [self.navigationController setToolbarHidden: NO animated: YES];
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
    
    if (self.shouldHideToolBarOnScroll) {
        [self.navigationController setToolbarHidden: YES animated: YES];
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


-(void) dealloc {
    [self.webView stopLoading];
}

@end
