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
@synthesize shouldHideNavBarOnScroll;
@synthesize shouldHideStatusBarOnScroll;

-(instancetype) initWithURL:(NSURL *)_url {
    self = [super initWithNibName: nil bundle: nil];
    
    if (self) {
        self.url = _url;
        self.shouldHideNavBarOnScroll = YES;
        self.shouldHideStatusBarOnScroll = YES;
    }
    
    return self;
}

-(void) loadView {
    self.view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = YES;
    
    self.webView = [[UIWebView alloc] initWithFrame: self.view.frame];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    [self.view addSubview: self.webView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadURL: self.url];

}

-(BOOL) prefersStatusBarHidden {
    if (scrollingDown) {
        return YES;
    }
    
    return NO;
}

-(void) loadURL:(NSURL *)_url {
    if (![_url isEqual: self.url]) {
        self.url = _url;
    }
    
    [self.webView loadRequest: [NSURLRequest requestWithURL: _url]];
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
        [self hideNavBar];
    } else if (delta < 0.f && prevDelta >= 0.f) {
        //up
        scrollingDown = NO;
        [self showNavBar];
    }
    previousContentDelta = delta;
}

-(void) showNavBar {
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
}

-(void) hideNavBar {
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
}


-(void) dealloc {
    [self.webView stopLoading];
}

@end
