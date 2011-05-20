//
//  CocoaZendeskViewController.h
//  CocoaZendesk
//
//  Created by Bill So on 06/05/2009.
//  Copyright Zendesk Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CocoaZendeskViewController : UIViewController {
	UITextField *emailView;
	UITextField *subjectView;
	UITextView *descriptionView;
	
	IBOutlet UIBarItem *sendButton;

	IBOutlet UITableView *tableView;
}

- (IBAction)submitTicket;

@end

