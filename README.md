# XXXWebView
异步加载 html 内 img 标签，给 img 标签添加点击事件

# 使用

pod 'XXXWebView'

```
XXXWebView *xWebView = XXXWebView.new;
[headerView addSubview:xWebView];
[xWebView mas_makeConstraints:^(MASConstraintMaker *make){
    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 10, 0));
}];

xWebView.oriImageUrl = @"https://wx2.sinaimg.cn/";
xWebView.oriImageScheme = @"https";
xWebView.placeholderImage = [UIImage imageNamed:@"abc"];


xWebView.webView.navigationDelegate = self;
xWebView.webView.scrollView.scrollEnabled = NO;
xWebView.htmlString = [self htmlString];
[xWebView addImgClickScript];
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
    
    /// 是否是点击图片
    BOOL isCustom = [XXXWebView isCustomScheme:navigationAction];
    if (isCustom) {
        
        //-----
        /// 图片是否被 a 标签包裹
        BOOL isA = [XXXWebView isA:navigationAction];
        if (isA) {
            // 是，不拦截
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }else{
            // 不是，拦截
            decisionHandler(WKNavigationActionPolicyCancel);
            
            [XXXWebView customScheme:navigationAction oriImageScheme:@"https" imgClick:^(BOOL isA, NSString * _Nonnull aUrl, NSString * _Nonnull imgUrl, UIImage * _Nonnull image) {
                
//                imgUrl 图片链接，image 图片 图片加载完成是 image 否则是 imgUrl）
                NSLog(@"\n ---- 点击图片 ---- \n 是否是 a 标签 = %@ \n a 标签链接 = %@ \n 图片链接 = %@ \n 图片 = %@",isA?@"是":@"否",aUrl,imgUrl,image);
            }];
        }
        //-----
        
        /*
         // 只要是 图片点击事件 都拦截
         decisionHandler(WKNavigationActionPolicyCancel);
         [XXXWebView customScheme:navigationAction oriImageScheme:@"https" imgClick:^(BOOL isA, NSString * _Nonnull aUrl, NSString * _Nonnull imgUrl, UIImage * _Nonnull image) {
         //imgUrl 图片链接，image 图片 图片加载完成是 image 否则是 imgUrl）
         NSLog(@"\n ---- 点击图片 ---- \n 是否是 a 标签 = %@ \n a 标签链接 = %@ \n 图片链接 = %@ \n 图片 = %@",isA?@"是":@"否",aUrl,imgUrl,image);
         */
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

```