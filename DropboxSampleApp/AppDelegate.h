//
//  AppDelegate.h
//  DropboxSampleApp
//
//  Created by Graham Cruse on 10/08/2012.
//  Copyright (c) 2012 Zendesk All rights reserved.
//

#import <UIKit/UIKit.h>


@class FormViewController;


@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *nc;
    
}


@property (nonatomic, retain) IBOutlet UIWindow *window;


@end

