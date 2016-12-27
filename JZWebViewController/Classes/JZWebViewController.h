//
//  JZWebViewController.h
//  Pods
//
//  Created by 曾昭英 on 2016/12/26.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface JZWebViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy, readonly) NSString *url;

@property (nonatomic) BOOL showNavRefresh;  //at right nav bar item
@property (nonatomic, strong) UIColor *progressTintColor;   // default is [UIColor greenColor]

- (instancetype)initWithUrl:(NSString *)url;

@end
