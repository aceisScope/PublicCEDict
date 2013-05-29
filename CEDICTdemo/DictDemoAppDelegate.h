//
//  DictDemoAppDelegate.h
//  CEDICTdemo
//
//  Created by B.H.Liu on 13-5-28.
//  Copyright (c) 2013年 Appublisher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDTrie.h"

@class DictDemoViewController;

@interface DictDemoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DictDemoViewController *viewController;

@property (strong, nonatomic) NDTrie *dictTrie;

@end
