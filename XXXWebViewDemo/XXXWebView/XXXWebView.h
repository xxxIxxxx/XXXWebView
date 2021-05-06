//
//  XXXWebView.h
//  XXXWebView
//
//  Created by Z on 2019/5/5.
//  Copyright © 2019 losht. All rights reserved.
//

#import <UIKit/UIKit.h>
@import  WebKit;
NS_ASSUME_NONNULL_BEGIN

@interface XXXWebView : UIView

/// 自定义图片资源 scheme
#define XXXCustomImageScheme @"xxxixxxx"

/// html 标签
@property (nonatomic, copy) NSString *htmlString;

/// 是否使用SDWebImage异步加载图片资源 默认不使用，  不开启的情况下不会存在 高度刷新回调
@property (nonatomic, assign) BOOL isAsyncLoadImg;

/// 占位图，仅在 `isAsyncLoadImg` 开启情况下有用
@property (nonatomic, strong) UIImage *placeholderImage;

/// 高度刷新回调  会回调多次，仅在开启 `isAsyncLoadImg` 的情况下有回调
@property (nonatomic, copy) void(^loadOverHeight)(CGFloat height);

/// 第二次获取高度延迟时间 不建议太小 否则可能获取高度不对 默认 0.4 s
@property (nonatomic, assign) double delayTime;

/// WKWebView
@property (nonatomic, strong, readonly) WKWebView *webView;


/// 开始加载
- (void)startLoadHTMLString;

/// 获取内容高度
/// @param compledBlock 高度回调
- (void)getWebViewContentHeight:(void(^)(CGFloat height))compledBlock;

//MARK: 以下方法只能在 navigationDelegate 代理中使用
/*
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {}
 */

/// 是否是图片点击，被 a 标签包裹下 无法判断返回 NO
/// @param navigationAction navigationAction
- (BOOL)isCustomScheme:(WKNavigationAction *)navigationAction;


/// img 标签点击事件，被 a 标签包裹下 无法响应
/// @param navigationAction navigationAction
/// @param imgClickBlock imgClickBlock   imgUrl 图片链接 |  image 图片
- (void)customScheme:(WKNavigationAction *)navigationAction imgClick:(void(^)(NSString *imgUrl,  UIImage * _Nullable image))imgClickBlock;

@end








#pragma mark -
#pragma mark - Extension

@interface UIView (copy_YYAdd)

@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGSize  size;        ///< Shortcut for frame.size.

@end



@interface NSData (xxx)
- (NSString *)xxx_base64EncodedString;
@end


NS_ASSUME_NONNULL_END

