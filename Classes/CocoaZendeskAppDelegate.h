//
//  CocoaZendeskAppDelegate.h
//  CocoaZendesk
//
//  Created by Bill So on 06/05/2009.
//  Copyright Zendesk Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CocoaZendeskViewController;

@interface CocoaZendeskAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CocoaZendeskViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CocoaZendeskViewController *viewController;
@end

