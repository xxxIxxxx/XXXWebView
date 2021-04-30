# XXXWebView
异步加载 html 内 img 标签，给 img 标签添加点击事件

# 使用

pod 'XXXWebView'

```
XXXWebView *xWebView = XXXWebView.new;
self.xWebView = xWebView;
[headerView addSubview:xWebView];
[xWebView mas_makeConstraints:^(MASConstraintMaker *make){
    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 10, 0));
}];
xWebView.placeholderImage = [UIImage imageNamed:@"abc"];
xWebView.webView.navigationDelegate = self;
xWebView.webView.scrollView.scrollEnabled = NO;
xWebView.isAsyncLoadImg = YES;
xWebView.htmlString = [self htmlString];
[xWebView startLoadHTMLString];

__weak typeof(headerView) weakHeaderView = headerView;
__weak typeof(tabView) weakTabView = tabView;

xWebView.loadOverHeight = ^(CGFloat height) {
    weakHeaderView.height = height +10;
    weakTabView.tableHeaderView = weakHeaderView;
};

```
# 实现 webView.navigationDelegate 代理，拦截点击事件
```
//代理 xWebView.webView.navigationDelegate = self;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
  
    if ([self.xWebView isCustomScheme:navigationAction]) {
        [self.xWebView customScheme:navigationAction imgClick:^(NSString * _Nonnull imgUrl, UIImage * _Nullable image) {
          NSLog(@"\n-- 图片地址:%@\n--   图片:%@",imgUrl,image);
          
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
  
    decisionHandler(WKNavigationActionPolicyAllow);
  
}

```
