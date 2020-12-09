//
//  ViewController.m
//  XXXWebView
//
//  Created by Z on 2020/11/22.
//

#import "ViewController.h"
#import "XXXWebView.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>

@interface ViewController ()<WKNavigationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    
    UIButton *pbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:pbtn];
    [pbtn setTitle:@"push" forState:UIControlStateNormal];
    pbtn.backgroundColor = UIColor.brownColor;
    [pbtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [pbtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_equalTo(0);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(self.view.width/2.0);
    }];
    [pbtn addTarget:self action:@selector(pbtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *cpbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cpbtn];
    [cpbtn setTitle:@"清除缓存并push" forState:UIControlStateNormal];
    cpbtn.backgroundColor = UIColor.redColor;
    [cpbtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [cpbtn addTarget:self action:@selector(cpbtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [cpbtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.mas_equalTo(0);
        make.top.equalTo(pbtn);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(self.view.width/2.0);
    }];
    
    
    UITableView *tabView = UITableView.new;
    [self.view addSubview:tabView];
    [tabView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.mas_equalTo(0);
        make.top.equalTo(pbtn.mas_bottom);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    UIView *footerView = [UIView new];
    footerView.backgroundColor = UIColor.blueColor;
    footerView.frame = CGRectMake(0, 0, self.view.width, 10);
    tabView.tableFooterView = footerView;
    
    
    UIView *headerView = [UIView new];
    tabView.tableHeaderView = headerView;
    headerView.backgroundColor = UIColor.orangeColor;
    headerView.frame = CGRectMake(0, 0, self.view.width, 100);
    
    
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
    
}




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


- (void)cpbtnClick{
    
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [self.navigationController pushViewController:ViewController.new animated:YES];
}


- (void)pbtnClick{
    [self.navigationController pushViewController:ViewController.new animated:YES];
}









- (NSString *)htmlString {
    
//    <a href=\"https://www.baidu.com\">\
//      <img src=\"https://wx2.sinaimg.cn/large/006CHHsBly1gkxrs7785ej31402eoe84.jpg\" />\
//    </a>\
    
    return @"<div>\
    一、《望天门山》 作者：唐代李白 1、原文 天门中断楚江开，碧水东流至此回。两岸青山相对出，孤帆一bai片日边来。 2、译文\
天门山从中间断裂是楚江把它冲开，碧水向东浩然奔流到这里折回。\
    两岸高耸的青山隔着长江相峙而立，江面上一叶孤舟像从日边驶来。\
    <img src=\"https://wx2.sinaimg.cn/large/006CHHsBly1gkxrs7785ej31402eoe84.jpg\"/>\
    二、《望庐山瀑布》 作者：唐代李白 1、原文 日照香炉生紫烟，遥看瀑布挂前川。\
    飞流直下三千尺，疑是银河落九天。 2、译文\
    太阳照耀香炉峰生出袅袅紫烟，远远望去瀑布像长河悬挂山前。\
    仿佛三千尺水流飞奔直冲而下，莫非是银河从九天垂落山崖间。\
    <img src=\"https://wx2.sinaimg.cn/large/006CHHsBly1gkxrsav966j31402eoe84.jpg\"/>\
    三、《早发白帝城》 作者：唐代李白 1、原文 朝辞白帝彩云间，千里江陵一日还。\
    两岸猿声啼不住，轻舟已过万重山。 2、译文\
    清晨告别白云之间的白帝城，千里外的江陵一日就能到达。\
    江两岸的猿在不停地啼叫着，轻快的小舟已驶过万重青山。\
    <img src=\"https://wx2.sinaimg.cn/large/ad6a65e1ly1gkwtpyun7uj22us253kjo.jpg\"/>\
    四、《黄鹤楼送孟浩然之广陵》 作者：唐代李白 1、原文\
    故人西辞黄鹤楼，烟花三月下扬州。 孤帆远影碧空尽，唯见长江天际流。 2、译文\
    旧友告别了黄鹤楼向东而去，在烟花如织的三月漂向扬州。\
    帆影渐消失于水天相连之处，只见滚滚长江水在天边奔流。\
<img src=\"https://wx2.sinaimg.cn/large/ad6a65e1ly1gkwtq0j0c5j22us253npg.jpg\"/>\
    五、《赠孟浩然》 作者：唐代李白 1、原文 吾爱孟夫子，风流天下闻。\
    红颜弃轩冕，白首卧松云。 醉月频中圣，迷花不事君。 高山安可仰，徒此揖清芬。\
    2、译文 我非常敬重孟先生的庄重潇洒，他为人高尚风流倜傥闻名天下。\
    少年时鄙视功名不爱官冕车马，高龄白首又归隐山林摒弃尘杂。\
    明月夜常常饮酒醉得非凡高雅，他不事君王迷恋花草胸怀豁达。\
    高山似的品格怎么能仰望着他？只在此揖敬他芬芳的道德光华！\
    <img src=\"https://wx2.sinaimg.cn/large/006CHHsBly1gkxrs94aokj31402eob2b.jpg\"/>\
    六、《静夜思》 作者：唐代李白 1、原文 床前明月光，疑是地上霜。\
    举头望明月，低头思故乡。 2、译文\
    明亮的月光洒在窗户纸上，好像地上泛起了一层霜。我禁不住抬起头来，看那天窗外空中的一轮明月，不由得低头沉思，想起远方的家乡。\
  </div>";
    
}

- (void)dealloc
{
    NSLog(@"--- dealloc ---");
}

@end



