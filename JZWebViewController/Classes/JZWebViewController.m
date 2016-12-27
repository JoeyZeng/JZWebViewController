//
//  JZWebViewController.m
//  Pods
//
//  Created by 曾昭英 on 2016/12/26.
//
//

#import "JZWebViewController.h"



@interface JZWebViewController ()

//设置加载进度条
@property (nonatomic,strong) UIProgressView *progressView;
//返回按钮
@property (nonatomic)UIBarButtonItem* customBackBarItem;
//关闭按钮
@property (nonatomic)UIBarButtonItem* closeButtonItem;

@end

@implementation JZWebViewController

#pragma mark - Getter and setter

static void *JZProgressKeyPathContext = &JZProgressKeyPathContext;

- (WKWebView *)webView{
    if (!_webView) {

        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.opaque = NO;
        // 设置代理
        _webView.navigationDelegate = self;
//        _webView.UIDelegate = self;
        //kvo 添加进度监控
        [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:JZProgressKeyPathContext];
        //开启手势触摸
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
//        UIImage* backItemImage = [[UIImage imageNamed:@"jz_icon_arrowback"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        UIImage* backItemHlImage = [[UIImage imageNamed:@"jz_icon_arrowback_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
                UIImage* backItemImage = [UIImage imageNamed:@"jz_icon_arrowback"];
                UIImage* backItemHlImage = [UIImage imageNamed:@"jz_icon_arrowback_hl"];

        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(backItemAction) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 2);
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor clearColor]];
        _progressView.progressTintColor = self.progressTintColor;
    }
    return _progressView;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemAction)];
    }
    return _closeButtonItem;
}

- (UIColor *)progressTintColor
{
    if (!_progressTintColor) {
        _progressTintColor = [UIColor greenColor];
    }
    return _progressTintColor;
}

#pragma mark - Button Action

-(void)updateNavigationItems{
    
    if (self.webView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem,self.closeButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem]];
    }
}

- (void)refreshAction
{
    [self.webView reload];
}

- (void)backItemAction
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View

-(void)dealloc{
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateNavigationItems];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //加载网页
    [self.webView loadRequest:request];
    
    //添加到主控制器上
    [self.view addSubview:self.webView];
    
    //添加进度条
    [self.view addSubview:self.progressView];
    
    if (self.showNavRefresh) {
        //添加右边刷新按钮
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _webView.frame = self.view.bounds;
    _progressView.frame = CGRectMake(0, _webView.scrollView.contentInset.top, self.view.bounds.size.width, 2);
}

#pragma mark - <WKNavigationDelegate>

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    // 获取加载网页的标题
    self.title = self.webView.title;
    [self updateNavigationItems];
}

@end
