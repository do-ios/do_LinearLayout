//
//  do_LinearLayout_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_LinearLayout_UIView.h"

#import "doUIModuleHelper.h"
#import "doUIModule.h"
#import "do_LinearLayout_UIModel.h"
#import "doInvokeResult.h"
#import "doIPage.h"
#import "doIScriptEngine.h"
#import "doEventCenter.h"
#import "doServiceContainer.h"
#import "doIUIModuleFactory.h"
#import "doScriptEngineHelper.h"
#import "doISourceFS.h"
#import "doUIContainer.h"
#import "doTextHelper.h"
#import "doIOHelper.h"
#import "doJsonHelper.h"
#import "doIBorder.h"

@interface do_LinearLayout_UIView()<doIBorder>
@property (nonatomic, assign) BOOL isSingleTouch;
@property (nonatomic, assign) BOOL isLongTouch;
@end

@implementation do_LinearLayout_UIView
{
    NSString *_lastFill;
    BOOL _isTouchOn;
}
#pragma mark - init
- (id)init
{
    self = [super init];
    if (self) {
        isEnabled = YES;
        self.clipsToBounds = YES;
        _lastFill = @"defaultValue";
        _isTouchOn = YES;
    }
    return self;
}

#pragma mark -
#pragma mark - override

- (doUIModule *) GetModel
{
    return model;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    if (!_isTouchOn) {
//        [super touchesBegan:touches withEvent:event];
//    }
    _isSingleTouch = YES;
    if (event.allTouches.count>1) {
        _isSingleTouch = NO;
        return;
    }
    _isLongTouch = NO;
    [self doLinearLayoutView_fingerTouchDown];
    [self performSelector:@selector(doLinearLayoutView_fingerLongTouch) withObject:nil afterDelay:.5];
    if (!_isTouchOn) {
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (event.allTouches.count>1) {
//        return;
//    }
//    if (isEnabled) {
//        [self touchBg];
//    }
//    if (!_isTouchOn) {
//        [super touchesEnded:touches withEvent:event];
//    }
    if (!_isSingleTouch) {
        _isSingleTouch = YES;
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch  locationInView:self];
    BOOL isPointInsideView = [self pointInside:point withEvent:event];
    if(!_isLongTouch && isPointInsideView)
    {
        [self doLinearLayoutView_fingerTouch];
    }
    [self doLinearLayoutView_fingerTouchUp];
    if (!_isTouchOn) {
        [super touchesEnded:touches withEvent:event];
    }
    
}
- (void)doLinearLayoutView_fingerLongTouch
{
    _isLongTouch = YES;
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"longTouch" :_invokeResult];
}
- (void)doLinearLayoutView_fingerTouch
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touch" :_invokeResult];
}
- (void)doLinearLayoutView_fingerTouchUp
{
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touchUp" :_invokeResult];
}
- (void)doLinearLayoutView_fingerTouchDown
{
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touchDown" :_invokeResult];
}

- (void)LoadView:(doUIModule *)_doUIModule
{
    model = (do_LinearLayout_UIModel *)_doUIModule;
    for (int i = (int)model.ChildUIModules.count- 1; i >= 0; i--)
    {
        doUIModule* _childUI = model.ChildUIModules[i];
        UIView* _view = (UIView*)_childUI.CurrentUIModuleView;
        if (_view == nil) continue;
        [self addSubview:_view];
    }
}
- (void)OnDispose{
    model = nil;
}
-(void) OnRedraw
{
    for(int i = (int)model.ChildUIModules.count- 1; i >= 0; i--)
    {
        doUIModule* _childUI = model.ChildUIModules[i];
        id<doIUIModuleView> _view = _childUI.CurrentUIModuleView;
        if (_view == nil) continue;
        [_view OnRedraw];
    }
    [self OnResize];
    
    if (![[model GetPropertyValue:@"bgImage"] isEqualToString:@""]) {
        [self change_bgImageFillType:[model GetPropertyValue:@"bgImageFillType"]];
    }
    [doUIModuleHelper generateBorder:model :[model GetPropertyValue:@"border"]];
}
- (void) OnResize
{
    CGFloat _x = model.RealX;
    CGFloat _y = model.RealY;
    CGFloat _w = model.RealWidth;
    CGFloat _h = model.RealHeight;
    float _paddingT = 0;
    float _paddingR = 0;
    float _paddingB = 0;
    float _paddingL = 0;
    NSString * _padding = [model GetPropertyValue:@"padding"];
    NSArray* paddingArray = [_padding componentsSeparatedByString:@","];
    if(paddingArray.count>=4)
    {
        _paddingT = [[doTextHelper Instance] StrToFloat:paddingArray[0] :0];
        _paddingR = [[doTextHelper Instance] StrToFloat:paddingArray[1] :0];
        _paddingB = [[doTextHelper Instance] StrToFloat:paddingArray[2] :0];
        _paddingL = [[doTextHelper Instance] StrToFloat:paddingArray[3] :0];
    }
    
    BOOL isHorizontal  = [[model GetPropertyValue:@"direction"] isEqualToString:@"horizontal"];
    BOOL isAutoWidth = [[model GetPropertyValue:@"width"] isEqualToString:@"-1"];
    BOOL isAutoHeight = [[model GetPropertyValue:@"height"] isEqualToString:@"-1"];
    float top = _paddingT;
    float left = _paddingL;
    
    if(!isHorizontal)
    {
        for (int i = 0;i<(int)model.ChildUIModules.count; i++)
        {
            doUIModule* _childUI = model.ChildUIModules[i];
            NSString *value = [_childUI GetPropertyValue:@"visible"];
            BOOL isVisible ;
            if (!value || [value isEqualToString:@""]) {
                isVisible = YES;
            }else
                isVisible = [value boolValue];
            if (!isVisible) {
                continue;
            }
            UIView* _view = (UIView*)_childUI.CurrentUIModuleView;
            if (_view == nil) continue;
            [self bringSubviewToFront:_view];
            float _childX =_paddingL+_childUI.Margins.l;
            [_childUI SetPropertyValue:@"x" :[@(_childX) stringValue]];
            float _childY =top+_childUI.Margins.t;
            [_childUI SetPropertyValue:@"y" :[@(_childY) stringValue]];
            
            //真实frame
            [_view setFrame:CGRectMake(_childUI.RealX, _childUI.RealY,CGRectGetWidth(_view.frame),CGRectGetHeight(_view.frame))];
            
            //设计坐标
            top = _childY + (CGRectGetHeight(_view.frame)/_childUI.YZoom)+_childUI.Margins.b;
            
            CGFloat tmpleft = _childX + CGRectGetWidth(_view.frame)/_childUI.XZoom+_childUI.Margins.r;
            if (tmpleft>left) {
                left = tmpleft;
            }
        }
    }else{
        for (int i = 0;i<(int)model.ChildUIModules.count; i++)
        {
            doUIModule* _childUI = model.ChildUIModules[i];
            NSString *value = [_childUI GetPropertyValue:@"visible"];
            BOOL isVisible ;
            if (!value || [value isEqualToString:@""]) {
                isVisible = YES;
            }else
                isVisible = [value boolValue];
            if (!isVisible) {
                continue;
            }
            UIView* _view = (UIView*)_childUI.CurrentUIModuleView;
            if (_view == nil) continue;
            [self bringSubviewToFront:_view];
            float _childX =left+_childUI.Margins.l;
            [_childUI SetPropertyValue:@"x" :[@(_childX) stringValue]];
            float _childY =_paddingT+_childUI.Margins.t;
            [_childUI SetPropertyValue:@"y" :[@(_childY) stringValue]];
            [_view setFrame:CGRectMake(_childUI.RealX, _childUI.RealY,CGRectGetWidth(_view.frame),CGRectGetHeight(_view.frame))];
            
            left = _childX + (CGRectGetWidth(_view.frame)/_childUI.XZoom)+_childUI.Margins.r;
            
            CGFloat tmpTop = _childY + (CGRectGetHeight(_view.frame)/_childUI.YZoom)+_childUI.Margins.b;
            if (tmpTop>top) {
                top = tmpTop;
            }
        }
    }
    if(isAutoHeight)
        _h = (top+_paddingB)*model.YZoom;
    if(isAutoWidth)
        _w = (left+_paddingR)*model.XZoom;
    [self setFrame:CGRectMake(_x, _y, _w, _h)];
}
-(void) AddSubview:(doUIModule*) _insertViewModel
{
    UIView* _insertView = (UIView*) _insertViewModel.CurrentUIModuleView;
    NSMutableArray* _childUIModules = model.ChildUIModules;
    if (target != nil && ![target isEqualToString:@""]) {// 插入的jui加在该组件的下面
        NSString *target1 = [NSString stringWithFormat:@"%@.%@",model.CurrentUIContainer.RootView.UniqueKey,target];
        doUIModule* _targetUIModule = [doScriptEngineHelper ParseUIModule: model.CurrentPage.ScriptEngine :target1];
        if(_targetUIModule==nil)
            //            [NSException raise:@"doLinearLayoutView" format:@"没找到target对应的组件"];
        {
            [_childUIModules insertObject:_insertViewModel atIndex:0];
            [self addSubview:_insertView];
        }
        for (int i = 0; i < _childUIModules.count; i++) {
            NSString *_unique = ((doUIModule *)[_childUIModules objectAtIndex:i]).UniqueKey;
            if (_unique != nil && [_targetUIModule.UniqueKey isEqualToString:_unique]) {
                [_childUIModules insertObject:_insertViewModel atIndex:i+1];
                [self addSubview:_insertView];
                return;
            }
        }
        
    } else {// 为空时表示加在Linearlayout最上面
        [_childUIModules insertObject:_insertViewModel atIndex:0];
        [self addSubview:_insertView];
        
    }
}
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    [doUIModuleHelper HandleViewProperChanged: self :model : _changedValues ];
}

- (BOOL)InvokeSyncMethod:(NSString *)_methodName :(NSDictionary *)_dictParas :(id<doIScriptEngine>) _scriptEngine :(doInvokeResult *)_invokeResult
{
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dictParas :_scriptEngine :_invokeResult];
}

- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
#pragma mark - 重写该方法，动态选择事件的施行或无效
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    //这里的BOOL值，可以设置为int的标记。从model里获取。
    if([model.EventCenter GetEventCount:@"touch"] <= 0 || isEnabled == NO)
        if(view == self)
            view = nil;
    return view;
}
#pragma mark -
#pragma mark - private
- (void)change_enabled:(NSString *)newValue
{
    isEnabled = [[doTextHelper Instance] StrToBool:newValue :NO];
}

- (void) change_bgImage:(NSString*) newValue
{
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:model.CurrentPage.CurrentApp :newValue];
    UIImage * img = [UIImage imageWithContentsOfFile:imgPath];
    [self changeImage:img : [self getType]];
}

- (void) change_bgImageFillType:(NSString*) newValue
{
    if ([newValue isEqualToString:_lastFill] || ![self sizeValidate]){
        return;
    }
    _lastFill = newValue;
    NSString *imgPath = [model GetPropertyValue:@"bgImage"];
    if (imgPath.length>0) {
        imgPath = [doIOHelper GetLocalFileFullPath:model.CurrentPage.CurrentApp :imgPath];
    }
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    [self changeImage:img : newValue];
}

- (NSString *)getType
{
    NSString *type = [model GetPropertyValue:@"bgImageFillType"];
    if (!type || [type isEqualToString:@""]) {
        type = [model GetProperty:@"bgImageFillType"].DefaultValue;
    }
    return type;
}

- (BOOL)sizeValidate
{
    if (CGRectGetHeight(self.frame)<=0 || CGRectGetWidth(self.frame)<=0) {
        return NO;
    }
    return YES;
}

-(void)add:(NSArray *)parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    id<doIScriptEngine> _scriptEngine =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString* _viewid = [doJsonHelper GetOneText:_dictParas :@"id" :@""];
    NSString* _viewtemplate =[doJsonHelper GetOneText:_dictParas : @"path" : @""];
    target = [doJsonHelper GetOneText:_dictParas :@"target" : @""];
    NSString* _result = [model Add:_scriptEngine :_viewtemplate :nil :nil :_viewid];
    [self OnRedraw];
    [_invokeResult SetResultText:_result];
}
-(void) getChildren:(NSArray *)parms
{
    [model getChildren:parms];
}
#pragma mark -
#pragma mark - uiview

-(void) changeImage:(UIImage*) _img :(NSString*) _type
{
    if (![self sizeValidate]) {
        return;
    }
    if(_img==nil) return;
    if ([_type isEqualToString:@"repeatxy"]) {
        self.layer.contents = nil;
        self.backgroundColor = [UIColor colorWithPatternImage:_img];
    }else{
        CGColorSpaceModel colorModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.backgroundColor.CGColor));
        if (colorModel != kCGColorSpaceModelRGB) {
            self.backgroundColor = [doUIModuleHelper GetColorFromString:[model GetPropertyValue:@"bgColor"] : [UIColor clearColor]];
        }
        self.layer.contents = (id)_img.CGImage;
    }
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.backgroundColor.CGColor));
    CGColorSpaceModel newModle = CGColorSpaceGetModel(CGColorGetColorSpace(backgroundColor.CGColor));
    if (colorModel == kCGColorSpaceModelPattern && newModle == kCGColorSpaceModelRGB && [_lastFill isEqualToString:@"repeatxy"]) {
    }else
        [super setBackgroundColor:backgroundColor];
}
- (void)touchBg
{
    doInvokeResult * _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touch" :_invokeResult];
}

#pragma mark - border
- (int)isResetBorder
{
    int isReset = 0;
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.backgroundColor.CGColor));
    if (colorModel == kCGColorSpaceModelPattern || self.layer.contents) {
        isReset = 1;
    }else
        isReset = 2;
    return isReset;
}
- (BOOL)isSupportDiffBorder
{
    return YES;
}
- (void)eventName:(NSString *)event :(NSString *)type
{
    if ([event hasPrefix:@"touch"]) {
        if ([type isEqualToString:@"on"]) {
            _isTouchOn = YES;
        }else
            _isTouchOn = NO;
    }
}

@end
