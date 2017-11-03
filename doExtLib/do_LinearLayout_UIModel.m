//
//  do_LinearLayout_Model.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_LinearLayout_UIModel.h"
#import "doProperty.h"
#import "do_LinearLayout_UIView.h"

@implementation do_LinearLayout_UIModel

#pragma mark - 注册属性（--属性定义--）
/*
[self RegistProperty:[[doProperty alloc]init:@"属性名" :属性类型 :@"默认值" : BOOL:是否支持代码修改属性]];
 */
-(void)OnInit
{
    [super OnInit];    
    //属性声明
	[self RegistProperty:[[doProperty alloc]init:@"bgImage" :String :@"" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"bgImageFillType" :String :@"fillxy" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"direction" :String :@"vertical" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"enabled" :Bool :@"true" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"padding" :String :@"0,0,0,0" :YES]];

}
-(void) AddSubview:(doUIModule*) _model
{
    do_LinearLayout_UIView* _view = (do_LinearLayout_UIView*)self.CurrentUIModuleView;
    [_view AddSubview:_model];
}

- (void)eventOn:(NSString *)onEvent
{
    [((do_LinearLayout_UIView *)self.CurrentUIModuleView) eventName:onEvent :@"on"];
}

- (void)eventOff:(NSString *)offEvent
{
    [((do_LinearLayout_UIView *)self.CurrentUIModuleView) eventName:offEvent :@"off"];
}
@end