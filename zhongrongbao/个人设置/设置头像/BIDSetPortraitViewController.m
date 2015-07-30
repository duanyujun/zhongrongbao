//
//  BIDSetPortraitViewController.m
//  mashangban
//
//  Created by mal on 14-8-25.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDSetPortraitViewController.h"
#import "UIImage+BIDImageScale.h"

const int limitRatio = 3;
const CGFloat BOUNDCE_DURATION = 0.3f;

@interface BIDSetPortraitViewController ()
@property (assign, nonatomic) CGRect oldFrame;
@property (assign, nonatomic) CGRect latestFrame;
@property (assign, nonatomic) CGRect largeFrame;
@property (assign, nonatomic) CGRect cropFrame;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *confirmBtn;

@end

@implementation BIDSetPortraitViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImage:(UIImage*)originImg
{
    self = [super init];
    if(self)
    {
        _originImg = originImg;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CGSize cropSize = CGSizeMake(screenSize.width, screenSize.width);
    self.cropFrame = CGRectMake(0, (screenSize.height-cropSize.height)/2, cropSize.width, cropSize.height);
    
    //
    // scale to fit the screen
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = _originImg.size.height * (oriWidth / _originImg.size.width);
    CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    _imgView = [[UIImageView alloc] init];
    _imgView.frame = self.oldFrame;
    [_imgView setImage:_originImg];
    
    self.largeFrame = CGRectMake(0, 0, limitRatio * self.oldFrame.size.width, limitRatio * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:_imgView];
    //
    
    UIView *layerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [layerView setBackgroundColor:[UIColor blackColor]];
    layerView.layer.opacity = 0.5f;
    [self.view addSubview:layerView];
    
    UIView *cropView = [[UIView alloc] initWithFrame:self.cropFrame];
    cropView.layer.borderColor = [UIColor whiteColor].CGColor;
    cropView.layer.borderWidth = 1;
    [self.view addSubview:cropView];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake(0, 0, screenSize.width, CGRectGetMinY(self.cropFrame)));
    CGPathAddRect(path, nil, CGRectMake(0, CGRectGetMaxY(self.cropFrame), screenSize.width, screenSize.height-CGRectGetMaxY(self.cropFrame)));
    shapeLayer.path = path;
    layerView.layer.mask = shapeLayer;
    CGPathRelease(path);
    
    [self setBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

/**
 *设置取消和选取按钮
 */
- (void)setBtn
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize btnSize = CGSizeMake(60, 40);
    CGFloat posY = screenSize.height - 5 - btnSize.height;
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelBtn.frame = CGRectMake(0, posY, btnSize.width, btnSize.height);
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.confirmBtn.frame = CGRectMake(screenSize.width-btnSize.width, posY, btnSize.width, btnSize.height);
    [self.confirmBtn setTitle:@"选取" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.confirmBtn];
}

/**
 *取消按钮事件
 */
- (void)cancelBtnHandler
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

/**
 *选取按钮事件
 */
- (void)confirmBtnHandler
{
    UIImage *cropedImg = [self getSubImage];
    [delegate finishCropImage:cropedImg viewController:self];
}

// register all gestures
- (void) addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = _imgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = _imgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            _imgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = _imgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = _imgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = _imgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            _imgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (_imgView.frame.size.width > _imgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

-(UIImage *)getSubImage
{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / _originImg.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = _originImg.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = _originImg.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    UIImage *smallImage = [_originImg getSubImage:myImageRect];
    return smallImage;
}

@end
