//
//  ViewController.m
//  testDemo
//
//  Created by 董志盟 on 17/10/16.
//  Copyright © 2017年 DZM. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"



@interface ViewController ()<UIScrollViewDelegate>

{
    int counts;
    AFHTTPSessionManager *manager;
    NSArray *imageArrs;
}

@property (weak, nonatomic)UIScrollView *scrollView;

@property (weak, nonatomic)UIPageControl *pageView;

@property (strong, nonatomic)NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/javascript", nil];
    
    manager.requestSerializer.timeoutInterval = 30;
    
    NSString *url = @"http://192.168.0.130/app.mmhzyf.com/index.php/Info/banner";
    
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = (NSDictionary *)responseObject;
        [self imageName:dic];
        NSLog(@"%@",dic);
        
        
        [self prepareScollView];
        [self preparePageView];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }
     
     ];
    
}

- (void)imageName:(NSDictionary *)dic
{
    NSArray *arr = [dic valueForKey:@"data"];
    counts = [arr count];
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [arr count]; i++)
    {
        NSString *url = @"http://192.168.0.130/app.mmhzyf.com/Public/Uploads";
        NSString *name = [[arr objectAtIndex:i] valueForKey:@"pic"];
        NSString *imageName = [NSString stringWithFormat:@"%@/%@",url,name];
        [imageArr addObject:imageName];
    }
    NSLog(@"%@",imageArr);
    imageArrs = imageArr;
}

- (void)prepareScollView {
    CGFloat scrollW = [UIScreen mainScreen].bounds.size.width;
    CGFloat scrollH = 200;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollW, scrollH)];
    scrollView.delegate = self;
    
    for (int i = 0; i < counts; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
//        NSString *name = [NSString stringWithFormat:@"img_%02d",i + 1];
//        imageView.image = [UIImage imageNamed:name];
        [imageView sd_setImageWithURL:[imageArrs objectAtIndex:i]];
        CGFloat imageX = scrollW * (i + 1);
        imageView.frame = CGRectMake(imageX, 0, scrollW, scrollH);
        [scrollView addSubview:imageView];
    }
    
    UIImageView *firstImage = [[UIImageView alloc] init];
//    firstImage.image = [UIImage imageNamed:@"img_05"];
    [firstImage sd_setImageWithURL:[imageArrs lastObject]];
    firstImage.frame = CGRectMake(0, 0, scrollW, scrollH);
    [scrollView addSubview:firstImage];
    scrollView.contentOffset = CGPointMake(scrollW, 0);
    
    UIImageView *lastImage = [[UIImageView alloc] init];
//    lastImage.image = [UIImage imageNamed:@"img_01"];
    [lastImage sd_setImageWithURL:[imageArrs firstObject]];
    lastImage.frame = CGRectMake((counts + 1) * scrollW, 0, scrollW, scrollH);
    [scrollView addSubview:lastImage];
    scrollView.contentSize = CGSizeMake((counts + 2) * scrollW, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    [self addTimer];
    
}

-(void)preparePageView {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat pageW = 100;
    UIPageControl *pageView = [[UIPageControl alloc] initWithFrame:CGRectMake((width - pageW) * 0.5, 190, pageW, 4)];
    pageView.numberOfPages = counts;
    pageView.currentPageIndicatorTintColor = [UIColor redColor];
    pageView.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageView.currentPage = 0;
    [self.view addSubview:pageView];
    self.pageView = pageView;
}

- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)nextImage {
    CGFloat width = self.scrollView.frame.size.width;
    NSInteger index = self.pageView.currentPage;
    if (index == counts + 1) {
        index = 0;
    } else {
        index++;
    }
    [self.scrollView setContentOffset:CGPointMake((index + 1) * width, 0)animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat width = self.scrollView.frame.size.width;
    int index = (self.scrollView.contentOffset.x + width * 0.5) / width;
    if (index == counts + 2) {
        index = 1;
    } else if(index == 0) {
        index = counts;
    }
    self.pageView.currentPage = index - 1;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat width = self.scrollView.frame.size.width;
    int index = (self.scrollView.contentOffset.x + width * 0.5) / width;
    if (index == counts + 1) {
        [self.scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
    } else if (index == 0) {
        [self.scrollView setContentOffset:CGPointMake(counts * width, 0) animated:NO];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];



}


@end
