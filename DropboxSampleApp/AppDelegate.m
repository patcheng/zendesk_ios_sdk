//
//  AppDelegate.m
//  DropboxSampleApp
//
//  Created by Graham Cruse on 10/08/2012.
//  Copyright (c) 2012 Zendesk All rights reserved.
//

#import "AppDelegate.h"
#import "FormViewController.h"


@implementation AppDelegate


@synthesize window;


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    FormViewController *viewController = [[[FormViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    nc = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window addSubview:nc.view];
    
    [self.window makeKeyAndVisible];
    return YES;
}


void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}


- (void) dealloc
{
    [window release];
    [nc release];
    [super dealloc];
}


@end
