//
//  TXViewController.m
//  Texf
//
//  Created by Mike Rotondo on 9/18/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import "TXViewController.h"

@interface TXViewController () <UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate>

@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) NSMutableArray *dynamicViews;

@end

@implementation TXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    NSString *string = @"";
    for (int i = 0; i < 1000; i++)
    {
//        int wordLength = 4 + arc4random() % 7;
        int wordLength = 1;
        for (int i = 0; i < wordLength; i++)
        {
            char c = 'a' + arc4random() % 26;
            string = [string stringByAppendingFormat:@"%c", c];
            
        }
        string = [string stringByAppendingString:@" "];
    }
    UIFont *font = [UIFont systemFontOfSize:12];
    UIColor *textColor = [UIColor colorWithRed:255.0/255 green:251.0/255 blue:193.0/255 alpha:1];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:@{NSFontAttributeName: font,
                                                                                        NSForegroundColorAttributeName: textColor}];
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    self.textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
    
    [layoutManager addTextContainer:self.textContainer];
    UITextView* textView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:self.textContainer];
    textView.backgroundColor = [UIColor colorWithRed:114.0/255 green:182.0/255 blue:204.0/255 alpha:1];
//    textView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:textView];
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.dynamicAnimator.delegate = self;
    
    self.dynamicViews = [NSMutableArray array];
    for (int i = 0; i < 10; i++)
    {
        UIView *dynamicView = [[UIView alloc] initWithFrame:generateRectInBounds(self.view.bounds)];
//        dynamicView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:dynamicView];
        [self.dynamicViews addObject:dynamicView];
    }
    self.textContainer.exclusionPaths = generatePathsFromViews(self.dynamicViews);
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:self.dynamicViews];
    self.gravityBehavior.magnitude = 0.1;
    [self.dynamicAnimator addBehavior:self.gravityBehavior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:self.dynamicViews];
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [self.dynamicAnimator addBehavior:collisionBehavior];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

//static CGRect generateRectAboveBounds(CGRect bounds)
//{
//    CGSize size = generateSizeForBounds(bounds);
//    CGPoint center = CGPointMake(bounds.size.width * (arc4random() / (float)0x100000000), -size.height / 2);
//    return rectWithSizeAndCenter(size, center);
//}

static CGRect generateRectInBounds(CGRect bounds)
{
    CGSize size = generateSizeForBounds(bounds);
    CGPoint center = CGPointMake(bounds.size.width * (arc4random() / (float)0x100000000), bounds.size.height * (arc4random() / (float)0x100000000));
    return rectWithSizeAndCenter(size, center);
}

static CGSize generateSizeForBounds(CGRect bounds)
{
    CGSize size = CGSizeMake(30 + 80 * (arc4random() / (float)0x100000000), 30 + 80 * (arc4random() / (float)0x100000000));
    return size;
}

static CGRect rectWithSizeAndCenter(CGSize size, CGPoint center)
{
    CGRect rect = CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
    return rect;
}

static NSArray *generatePathsFromViews(NSArray *views)
{
    NSMutableArray *paths = [NSMutableArray array];
    for (UIView *view in views) {
        CGPoint p1, p2, p3, p4;
        rotateCGRect(view.bounds, view.transform, &p1, &p2, &p3, &p4);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(view.center.x + p1.x, view.center.y + p1.y)];
        [path addLineToPoint:CGPointMake(view.center.x + p2.x, view.center.y + p2.y)];
        [path addLineToPoint:CGPointMake(view.center.x + p3.x, view.center.y + p3.y)];
        [path addLineToPoint:CGPointMake(view.center.x + p4.x, view.center.y + p4.y)];
        [path addLineToPoint:CGPointMake(view.center.x + p1.x, view.center.y + p1.y)];
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.frame];
        [paths addObject:path];
    }
    return paths;
}

static void rotateCGRect(CGRect rect, CGAffineTransform rotation, CGPoint *p1, CGPoint *p2, CGPoint *p3, CGPoint *p4)
{
    CGSize size = rect.size;
    CGPoint originalP1 = CGPointMake(-size.width / 2, -size.height / 2);
    *p1 = CGPointApplyAffineTransform(originalP1, rotation);
    CGPoint originalP2 = CGPointMake(size.width / 2, -size.height / 2);
    *p2 = CGPointApplyAffineTransform(originalP2, rotation);
    CGPoint originalP3 = CGPointMake(size.width / 2, size.height / 2);
    *p3 = CGPointApplyAffineTransform(originalP3, rotation);
    CGPoint originalP4 = CGPointMake(-size.width / 2, size.height / 2);
    *p4 = CGPointApplyAffineTransform(originalP4, rotation);
}

- (void)update:(CADisplayLink *)sender
{
//    NSMutableArray *viewsToRemove = [NSMutableArray array];
//    NSMutableArray *viewsToAdd = [NSMutableArray array];
//    for (UIView *dynamicView in self.dynamicViews) {
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:dynamicView.frame];
//        self.textContainer.exclusionPaths = @[path];
//        if (dynamicView.center.y - dynamicView.bounds.size.height / 2 > self.view.bounds.size.height)
//        {
//            [viewsToRemove addObject:dynamicView];
//        }
//    }
//    for (UIView *offscreenDynamicView in viewsToRemove) {
//        [self.gravityBehavior removeItem:offscreenDynamicView];
//        [offscreenDynamicView removeFromSuperview];
//        [self.dynamicViews removeObject:offscreenDynamicView];
//    }
//    
//    BOOL addView = 0.2 > (arc4random() / (float)0x100000000);
//    if (addView)
//    {
//        UIView *newDynamicView = [[UIView alloc] initWithFrame:generateRectAboveBounds(self.view.bounds)];
//        [self.view addSubview:newDynamicView];
//        [self.gravityBehavior addItem:newDynamicView];
//        [viewsToAdd addObject:newDynamicView];
//        [self.dynamicViews addObject:newDynamicView];
//    }
    self.textContainer.exclusionPaths = generatePathsFromViews(self.dynamicViews);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
