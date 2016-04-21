/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ACEDrawingView.h"
#import "ACEDrawingTools.h"

#import "CacheDataInfo.h"

#import <QuartzCore/QuartzCore.h>

#define kDefaultLineColor       [UIColor blackColor]
#define kDefaultLineWidth       10.0f;
#define kDefaultLineAlpha       1.0f

#define afterTime 2

// experimental code
#define PARTIAL_REDRAW          0
#define IOS8_OR_ABOVE [[[UIDevice currentDevice] systemVersion] integerValue] >= 8.0

#define CHAT_BUTTON_SIZE 60
#define MOREVIEW_BUTTON_TAG 1000

@interface ACEDrawingView () {
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    
    UILabel *pointLabel;
    
    NSDate *endDate;
    
    BOOL isExecMethod;
    int count;
    
    NSTimer *timer;
    
    BOOL isHidden;
    
    BOOL isGetValue;
    NSMutableArray *valueArray; // 每隔50毫秒取的值
}

@property (nonatomic, strong) NSMutableArray *pathArray;
@property (nonatomic, strong) NSMutableArray *bufferArray;
@property (nonatomic, strong) id<ACEDrawingTool> currentTool;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) CGFloat originalFrameYPos;

// 缓存数据
@property (nonatomic, strong) UIButton *cacheDataButton;
// 请求联机
@property (nonatomic, strong) UIButton *requestOnlineButton;

@end

#pragma mark -

@implementation ACEDrawingView

- (id)initWithFrame:(CGRect)frame withisHiddenBtn:(BOOL)isHiddenBtn
{
    isHidden = isHiddenBtn;
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
        
        pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
        //label.font = [UIFont fontWithName:@"Arial" size:10.0f];
        pointLabel.tag = 99;
        pointLabel.textColor = [UIColor greenColor];
        [self addSubview:pointLabel];
        
        self.pointArray = self.lineArray = [NSMutableArray new];
        
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(pointLabel.frame) + 10, 0, 80, 30)];
        [switchBtn addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:switchBtn];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 setTitle:@"BC01" forState:UIControlStateNormal];
        [btn1 setFrame:CGRectMake(CGRectGetMaxX(pointLabel.frame) + 10, 40, 80, 30)];
        [self addSubview:btn1];
        
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn2 setTitle:@"BC02" forState:UIControlStateNormal];
        [btn2 setFrame:CGRectMake(CGRectGetMaxX(pointLabel.frame) + 10, 80, 80, 30)];
        [self addSubview:btn2];
        
        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn3 setTitle:@"BC03" forState:UIControlStateNormal];
        [btn3 setFrame:CGRectMake(CGRectGetMaxX(pointLabel.frame) + 10, 120, 80, 30)];
        [self addSubview:btn3];
        
        btn1.tag = 1;
        btn2.tag = 2;
        btn3.tag = 3;
        [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn3 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)switchValueChange:(UISwitch *)sender{
    NSString *value;
    if (sender.on) {
        value = @"BB01";
    }else{
        value = @"BB00";
    }
    if (_sendControlValue) {
        _sendControlValue(value);
    }
}

- (void)btnClick:(UIButton *)sender{
    NSString *value;
    switch (sender.tag) {
        case 1:
            value = @"BC01";
            break;
        case 2:
            value = @"BC02";
            break;
        case 3:
            value = @"BC03";
            break;
        default:
            break;
    }
    
    if (_sendControlValue) {
        _sendControlValue(value);
    }
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    // init the private arrays
    self.pathArray = [NSMutableArray array];
    self.bufferArray = [NSMutableArray array];
    valueArray = [NSMutableArray array];
    
    // set the default values for the public properties
    self.lineColor = kDefaultLineColor;
    self.lineWidth = kDefaultLineWidth;
    self.lineAlpha = kDefaultLineAlpha;

    self.drawMode = ACEDrawingModeOriginalSize;
    
    // set the transparent background
    self.backgroundColor = [UIColor clearColor];
    
    if (!isHidden) {
        _cacheDataButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_cacheDataButton setFrame:CGRectMake(ScreenSize.width - CHAT_BUTTON_SIZE * 2 - 40, 15, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
        [_cacheDataButton setImage:[UIImage imageNamed:@"open_cache_off"] forState:UIControlStateNormal];
        [_cacheDataButton setImage:[UIImage imageNamed:@"open_cache_on"] forState:UIControlStateHighlighted];
        [_cacheDataButton addTarget:self action:@selector(cacheDataAction) forControlEvents:UIControlEventTouchUpInside];
        _cacheDataButton.tag = MOREVIEW_BUTTON_TAG + 2;
        [self addSubview:_cacheDataButton];
        
        CGRect frame = self.frame;
        frame.size.height = 150;
        _requestOnlineButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_requestOnlineButton setFrame:CGRectMake(ScreenSize.width - CHAT_BUTTON_SIZE - 20, 15, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
        [_requestOnlineButton setImage:[UIImage imageNamed:@"online_request_off"] forState:UIControlStateNormal];
        [_requestOnlineButton setImage:[UIImage imageNamed:@"online_request_on"] forState:UIControlStateHighlighted];
        [_requestOnlineButton addTarget:self action:@selector(requestOnlineAction) forControlEvents:UIControlEventTouchUpInside];
        _requestOnlineButton.tag = MOREVIEW_BUTTON_TAG + 3;
        [self addSubview:_requestOnlineButton];
    }
     
    
    self.originalFrameYPos = self.frame.origin.y;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - action

- (void)cacheDataAction
{
    if(_theDelegate && [_delegate respondsToSelector:@selector(acedDrawingViewCacheDataAction:)]){
        [_theDelegate acedDrawingViewCacheDataAction:self];
    }
}

- (void)requestOnlineAction
{
    if (_theDelegate && [_delegate respondsToSelector:@selector(acedDrawingViewRequestOnlineAction:)]) {
        [_theDelegate acedDrawingViewRequestOnlineAction:self];
    }
}

- (UIImage *)prev_image {
    return self.backgroundImage;
}

- (void)setPrev_image:(UIImage *)prev_image {
    [self setBackgroundImage:prev_image];
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
#if PARTIAL_REDRAW
    // TODO: draw only the updated part of the image
    [self drawPath];
#else
    switch (self.drawMode) {
        case ACEDrawingModeOriginalSize:
            [self.image drawAtPoint:CGPointZero];
            break;
            
        case ACEDrawingModeScale:
            [self.image drawInRect:self.bounds];
            break;
    }
    [self.currentTool draw];
#endif
}

- (void)commitAndDiscardToolStack
{
    [self updateCacheImage:YES];
    self.backgroundImage = self.image;
    [self.pathArray removeAllObjects];
}

- (void)updateCacheImage:(BOOL)redraw
{
    // init a context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    if (redraw) {
        // erase the previous image
        self.image = nil;
        
        // load previous image (if returning to screen)
        
        switch (self.drawMode) {
            case ACEDrawingModeOriginalSize:
                [[self.backgroundImage copy] drawAtPoint:CGPointZero];
                break;
            case ACEDrawingModeScale:
                [[self.backgroundImage copy] drawInRect:self.bounds];
                break;
        }
        
        // I need to redraw all the lines
        for (id<ACEDrawingTool> tool in self.pathArray) {
            [tool draw];
        }
        
    } else {
        // set the draw point
        [self.image drawAtPoint:CGPointZero];
        [self.currentTool draw];
    }
    
    // store the image
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)finishDrawing
{
    // update the image
    [self updateCacheImage:NO];
    
    // clear the redo queue
    [self.bufferArray removeAllObjects];
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:didEndDrawUsingTool:)]) {
        [self.delegate drawingView:self didEndDrawUsingTool:self.currentTool];
    }
    
    // clear the current tool
    self.currentTool = nil;
}

- (void)setCustomDrawTool:(id<ACEDrawingTool>)customDrawTool
{
    _customDrawTool = customDrawTool;
    
    if (customDrawTool != nil) {
        self.drawTool = ACEDrawingToolTypeCustom;
    }
}

- (id<ACEDrawingTool>)toolWithCurrentSettings
{
    switch (self.drawTool) {
        case ACEDrawingToolTypePen:
        {
            return ACE_AUTORELEASE([ACEDrawingPenTool new]);
        }
            
        case ACEDrawingToolTypeLine:
        {
            return ACE_AUTORELEASE([ACEDrawingLineTool new]);
        }
            
        case ACEDrawingToolTypeText:
        {
            return ACE_AUTORELEASE([ACEDrawingTextTool new]);
        }

        case ACEDrawingToolTypeMultilineText:
        {
            return ACE_AUTORELEASE([ACEDrawingMultilineTextTool new]);
        }

        case ACEDrawingToolTypeRectagleStroke:
        {
            ACEDrawingRectangleTool *tool = ACE_AUTORELEASE([ACEDrawingRectangleTool new]);
            tool.fill = NO;
            return tool;
        }
            
        case ACEDrawingToolTypeRectagleFill:
        {
            ACEDrawingRectangleTool *tool = ACE_AUTORELEASE([ACEDrawingRectangleTool new]);
            tool.fill = YES;
            return tool;
        }
            
        case ACEDrawingToolTypeEllipseStroke:
        {
            ACEDrawingEllipseTool *tool = ACE_AUTORELEASE([ACEDrawingEllipseTool new]);
            tool.fill = NO;
            return tool;
        }
            
        case ACEDrawingToolTypeEllipseFill:
        {
            ACEDrawingEllipseTool *tool = ACE_AUTORELEASE([ACEDrawingEllipseTool new]);
            tool.fill = YES;
            return tool;
        }
            
        case ACEDrawingToolTypeEraser:
        {
            return ACE_AUTORELEASE([ACEDrawingEraserTool new]);
        }
            
        case ACEDrawingToolTypeCustom:
        {
            return self.customDrawTool;
        }
    }
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isGetValue = YES;
    
    [self getChangeValue];
    
    count = 0;
    if ([[NSDate date] timeIntervalSince1970] - [endDate timeIntervalSince1970] < afterTime) {
        isExecMethod = NO;
    }else{
        isExecMethod = YES;
    }
    
    if (self.textView && !self.textView.hidden) {
        [self commitAndHideTextEntry];
        return;
    }
    
    // add the first touch
    UITouch *touch = [touches anyObject];
    previousPoint1 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    // init the bezier path
    self.currentTool = [self toolWithCurrentSettings];
    self.currentTool.lineWidth = self.lineWidth;
    self.currentTool.lineColor = self.lineColor;
    self.currentTool.lineAlpha = self.lineAlpha;
    
    if ([self.currentTool class] == [ACEDrawingTextTool class]) {
        [self initializeTextBox:currentPoint WithMultiline:NO];
    } else if([self.currentTool class] == [ACEDrawingMultilineTextTool class]) {
        [self initializeTextBox:currentPoint WithMultiline:YES];
    } else {
        [self.pathArray addObject:self.currentTool];
        
        [self.currentTool setInitialPoint:currentPoint];
    }
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:willBeginDrawUsingTool:)]) {
        [self.delegate drawingView:self willBeginDrawUsingTool:self.currentTool];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *touchesArray = [event.allTouches allObjects];
    //获取当前触摸手指的坐标CGPoint
    CGPoint sPoint = [touchesArray.firstObject locationInView:self];
    sPoint.y = 190 - sPoint.y;
    //将CGpoint转换成NSString类
    //NSString *NSPoint  = NSStringFromCGPoint(sPoint);
    
    //取出self.pointArray里用于保存坐标的当前数组
    if (![self isValid:sPoint]) {
        return;
    }
    
    int y = sPoint.y;
    
    NSString *value = @"020000";
    if (y < 10) {
        value = [NSString stringWithFormat:@"02000%d",y];
    }else if(y < 100){
        value = [NSString stringWithFormat:@"0200%d",y];
    }else{
        value = [NSString stringWithFormat:@"020%d",y];
    }
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd hh:mm:ss.SSSZ";
    NSString *dateStr = [df stringFromDate:[NSDate date]];
    
    long oldTime = 0;
    if (self.pointArray != nil && self.pointArray.count > 0) {
        CacheDataInfo *info = self.pointArray.lastObject;
        NSDate *oldDate = [df dateFromString:info.date];
        
        NSDate *nowDate = [df dateFromString:dateStr];
        
        oldTime = [nowDate timeIntervalSince1970] * 1000 - [oldDate timeIntervalSince1970] * 1000;
        
    }
    
    CacheDataInfo *info = [[CacheDataInfo alloc] init];
    info.value = value;
    info.date = dateStr;
    info.timeInterval = [NSNumber numberWithLong:oldTime];
    
    //保存当前手指的坐标点
    [self.pointArray addObject:info];
    [self reportCurrentPointLocation];
    
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    
    previousPoint2 = previousPoint1;
    previousPoint1 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    if ([self.currentTool isKindOfClass:[ACEDrawingPenTool class]]) {
        CGRect bounds = [(ACEDrawingPenTool*)self.currentTool addPathPreviousPreviousPoint:previousPoint2 withPreviousPoint:previousPoint1 withCurrentPoint:currentPoint];
        
        CGRect drawBox = bounds;
        drawBox.origin.x -= self.lineWidth * 2.0;
        drawBox.origin.y -= self.lineWidth * 2.0;
        drawBox.size.width += self.lineWidth * 4.0;
        drawBox.size.height += self.lineWidth * 4.0;
        
        [self setNeedsDisplayInRect:drawBox];
    }
    else if ([self.currentTool isKindOfClass:[ACEDrawingTextTool class]]) {
        [self resizeTextViewFrame: currentPoint];
    }
    else {
        [self.currentTool moveFromPoint:previousPoint1 toPoint:currentPoint];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isGetValue = NO;
    // make sure a point is recorded
    [self touchesMoved:touches withEvent:event];
    
    if ([self.currentTool isKindOfClass:[ACEDrawingTextTool class]]) {
        [self startTextEntry];
    }
    else {
        [self finishDrawing];
    }
    
    //[self.pointArray addObjectsFromArray:self.pointArray];
    
    CacheDataInfo *info = [[CacheDataInfo alloc] init];
    info.value = @"020000";
    [self.pointArray addObject:info];
    
    self.lineArray = (NSMutableArray *)[self.lineArray arrayByAddingObjectsFromArray:self.pointArray];
    
    //重置用于保存坐标点的数组，再次画线时清空上次的轨迹线
    [self.pointArray removeAllObjects];
    
    //[self saveHistoryPoint];
    
    if (!isExecMethod) {
        if (timer != nil) {
            [timer invalidate];
        }
        timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    }
    
    endDate = [NSDate date];
    
    [self performSelector:@selector(execMethod) withObject:nil afterDelay:afterTime];
}


/**
 *  @brief 每隔50毫秒取一个值
 */
- (void)getChangeValue{
    
    if (isGetValue) {
        if (self.pointArray.lastObject != nil) {
            [valueArray addObject:self.pointArray.lastObject];
        }
        
        [self getDrawingValue];
    }
}

- (void)getDrawingValue{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            
            if (self.pointArray.lastObject != nil) {
                [valueArray addObject:self.pointArray.lastObject];
            }
            [self getDrawingValue];
            
        });
        
    });
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Text Entry

- (void)initializeTextBox:(CGPoint)startingPoint WithMultiline:(BOOL)multiline {
    if (!self.textView) {
        self.textView = [[UITextView alloc] init];
        self.textView.delegate = self;
        if(!multiline) {
            self.textView.returnKeyType = UIReturnKeyDone;
        }
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.layer.borderWidth = 1.0f;
        self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
        self.textView.layer.cornerRadius = 8;
        [self.textView setContentInset: UIEdgeInsetsZero];
        
        
        [self addSubview:self.textView];
    }
    
    int calculatedFontSize = self.lineWidth * 3; //3 is an approximate size factor
    
    [self.textView setFont:[UIFont systemFontOfSize:calculatedFontSize]];
    self.textView.textColor = self.lineColor;
    self.textView.alpha = self.lineAlpha;
    
    int defaultWidth = 200;
    int defaultHeight = calculatedFontSize * 2;
    int initialYPosition = startingPoint.y - (defaultHeight/2);
    
    CGRect frame = CGRectMake(startingPoint.x, initialYPosition, defaultWidth, defaultHeight);
    frame = [self adjustFrameToFitWithinDrawingBounds:frame];
    
    self.textView.frame = frame;
    self.textView.text = @"";
    self.textView.hidden = NO;
}

- (void) startTextEntry {
    if (!self.textView.hidden) {
        [self.textView becomeFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(([self.currentTool class] == [ACEDrawingTextTool  class]) && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    CGRect frame = self.textView.frame;
    if (self.textView.contentSize.height > frame.size.height) {
        frame.size.height = self.textView.contentSize.height;
    }
    
    self.textView.frame = frame;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self commitAndHideTextEntry];
}

-(void)resizeTextViewFrame: (CGPoint)adjustedSize {
    
    int minimumAllowedHeight = self.textView.font.pointSize * 2;
    int minimumAllowedWidth = self.textView.font.pointSize * 0.5;
    
    CGRect frame = self.textView.frame;
    
    //adjust height
    int adjustedHeight = adjustedSize.y - self.textView.frame.origin.y;
    if (adjustedHeight > minimumAllowedHeight) {
        frame.size.height = adjustedHeight;
    }
    
    //adjust width
    int adjustedWidth = adjustedSize.x - self.textView.frame.origin.x;
    if (adjustedWidth > minimumAllowedWidth) {
        frame.size.width = adjustedWidth;
    }
    frame = [self adjustFrameToFitWithinDrawingBounds:frame];
    
    self.textView.frame = frame;
}

- (CGRect)adjustFrameToFitWithinDrawingBounds: (CGRect)frame {
    
    //check that the frame does not go beyond bounds of parent view
    if ((frame.origin.x + frame.size.width) > self.frame.size.width) {
        frame.size.width = self.frame.size.width - frame.origin.x;
    }
    if ((frame.origin.y + frame.size.height) > self.frame.size.height) {
        frame.size.height = self.frame.size.height - frame.origin.y;
    }
    return frame;
}

- (void)commitAndHideTextEntry {
    [self.textView resignFirstResponder];
    
    if ([self.textView.text length]) {
        UIEdgeInsets textInset = self.textView.textContainerInset;
        CGFloat additionalXPadding = 5;
        CGPoint start = CGPointMake(self.textView.frame.origin.x + textInset.left + additionalXPadding, self.textView.frame.origin.y + textInset.top);
        CGPoint end = CGPointMake(self.textView.frame.origin.x + self.textView.frame.size.width - additionalXPadding, self.textView.frame.origin.y + self.textView.frame.size.height);
        
        ((ACEDrawingTextTool*)self.currentTool).attributedText = [self.textView.attributedText copy];
        
        [self.pathArray addObject:self.currentTool];
        
        [self.currentTool setInitialPoint:start]; //change this for precision accuracy of text location
        [self.currentTool moveFromPoint:start toPoint:end];
        [self setNeedsDisplay];
        
        [self finishDrawing];
        
    }
    
    self.currentTool = nil;
    self.textView.hidden = YES;
    self.textView = nil;
}

#pragma mark - Keyboard Events

- (void)keyboardDidShow:(NSNotification *)notification
{
    self.originalFrameYPos = self.frame.origin.y;

    if (IOS8_OR_ABOVE) {
        [self adjustFramePosition:notification];
    }
    else {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            [self landscapeChanges:notification];
        } else {
            [self adjustFramePosition:notification];
        }
    }
}

- (void)landscapeChanges:(NSNotification *)notification {
    CGPoint textViewBottomPoint = [self convertPoint:self.textView.frame.origin toView:self];
    CGFloat textViewOriginY = textViewBottomPoint.y;
    CGFloat textViewBottomY = textViewOriginY + self.textView.frame.size.height;

    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat offset = (self.frame.size.height - keyboardSize.width) - textViewBottomY;

    if (offset < 0) {
        CGFloat newYPos = self.frame.origin.y + offset;
        self.frame = CGRectMake(self.frame.origin.x,newYPos, self.frame.size.width, self.frame.size.height);

    }
}
- (void)adjustFramePosition:(NSNotification *)notification {
    CGPoint textViewBottomPoint = [self convertPoint:self.textView.frame.origin toView:nil];
    textViewBottomPoint.y += self.textView.frame.size.height;

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat offset = (screenRect.size.height - keyboardSize.height) - textViewBottomPoint.y;

    if (offset < 0) {
        CGFloat newYPos = self.frame.origin.y + offset;
        self.frame = CGRectMake(self.frame.origin.x,newYPos, self.frame.size.width, self.frame.size.height);

    }
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    self.frame = CGRectMake(self.frame.origin.x,self.originalFrameYPos,self.frame.size.width,self.frame.size.height);
}


#pragma mark - Load Image

- (void)loadImage:(UIImage *)image
{
    self.image = image;
    
    //save the loaded image to persist after an undo step
    self.backgroundImage = [image copy];
    
    // when loading an external image, I'm cleaning all the paths and the undo buffer
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    [self updateCacheImage:YES];
    [self setNeedsDisplay];
}

- (void)loadImageData:(NSData *)imageData
{
    CGFloat imageScale;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        imageScale = [[UIScreen mainScreen] scale];
        
    } else {
        imageScale = 1.0;
    }
    
    UIImage *image = [UIImage imageWithData:imageData scale:imageScale];
    [self loadImage:image];
}

- (void)resetTool
{
    if ([self.currentTool isKindOfClass:[ACEDrawingTextTool class]]) {
        self.textView.text = @"";
        [self commitAndHideTextEntry];
    }
    self.currentTool = nil;
}

#pragma mark - Actions

- (void)clear
{
    [self resetTool];
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    self.backgroundImage = nil;
    [self updateCacheImage:YES];
    [self setNeedsDisplay];
}


#pragma mark - Undo / Redo

- (NSUInteger)undoSteps
{
    return self.bufferArray.count;
}

- (BOOL)canUndo
{
    return self.pathArray.count > 0;
}

- (void)undoLatestStep
{
    if ([self canUndo]) {
        [self resetTool];
        id<ACEDrawingTool>tool = [self.pathArray lastObject];
        [self.bufferArray addObject:tool];
        [self.pathArray removeLastObject];
        [self updateCacheImage:YES];
        [self setNeedsDisplay];
    }
}

- (BOOL)canRedo
{
    return self.bufferArray.count > 0;
}

- (void)redoLatestStep
{
    if ([self canRedo]) {
        [self resetTool];
        id<ACEDrawingTool>tool = [self.bufferArray lastObject];
        [self.pathArray addObject:tool];
        [self.bufferArray removeLastObject];
        [self updateCacheImage:YES];
        [self setNeedsDisplay];
    }
}


- (void)dealloc
{
    self.pathArray = nil;
    self.bufferArray = nil;
    self.currentTool = nil;
    self.image = nil;
    self.backgroundImage = nil;
    self.customDrawTool = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
#if !ACE_HAS_ARC
    
    [super dealloc];
#endif
}

//上报坐标
- (void)reportCurrentPointLocation {
    
    NSMutableArray *sPointArray = self.pointArray;
    
    CacheDataInfo *info = [sPointArray objectAtIndex:(sPointArray.count - 1)];
    
    pointLabel.text = info.value;
}

- (BOOL)isValid:(CGPoint)currentPointLocation{
    
    if (currentPointLocation.y <= 0 || currentPointLocation.y >= 180) {
        return NO;
    }
    
    return YES;
}

-(void)startSendDrawData:(StartSendDrawData)startSendDrawData{
    _startSendDrawData = startSendDrawData;
}


- (void)execMethod{
    if (isExecMethod) {
        
        if (_startSendDrawData) {
            _startSendDrawData(self.lineArray);
        }
        //_startSendDrawData(valueArray);
        
        self.lineArray = [NSMutableArray new];
        valueArray = [NSMutableArray new];
    }
}

- (void)countMethod{
    count ++;
    
    if (count == afterTime) {
        [timer invalidate];
        isExecMethod = YES;
        [self execMethod];
    }
}

@end
