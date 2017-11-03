//
//  do_LinearLayout_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_LinearLayout_IView.h"
#import "do_LinearLayout_UIModel.h"
#import "doIUIModuleView.h"
#import "doIAutoLayout.h"

@interface do_LinearLayout_UIView : UIView<do_LinearLayout_IView, doIUIModuleView,doIAutoLayout>
//可根据具体实现替换UIView
{
	@private
		__weak do_LinearLayout_UIModel *model;
        BOOL isEnabled;
        NSString* target;
}
-(void) AddSubview:(doUIModule*) _model;

- (void)eventName:(NSString *)event :(NSString *)type;

@end
