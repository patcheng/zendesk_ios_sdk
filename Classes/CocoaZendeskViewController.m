//
//  CocoaZendeskViewController.m
//  CocoaZendesk
//
//  Created by Bill So on 06/05/2009.
//  Copyright Zendesk Inc 2009. All rights reserved.
//

#import "CocoaZendeskViewController.h"
#import "ZendeskDropbox.h"

@implementation CocoaZendeskViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[descriptionView release];
	[emailView release];
	[subjectView release];
    [super dealloc];
}

- (IBAction)submitTicket {
	ZendeskDropbox *ticketSubmission = [[ZendeskDropbox alloc] init];
	ticketSubmission.delegate = self;
	sendButton.enabled = NO;
	[ticketSubmission sendTicket:[NSDictionary dictionaryWithObjectsAndKeys:descriptionView.text, ZendeskDropboxDescription, emailView.text, ZendeskDropboxEmail, subjectView.text, ZendeskDropboxSubject, nil]];
}

#pragma mark ticket submission delegate
- (void)submissionDidFinishLoading:(ZendeskDropbox *)connection {
	sendButton.enabled = YES;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Ticket sent to server successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[connection release];
}

- (void)submission:(ZendeskDropbox *)connection didFailWithError:(NSError *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[error userInfo] valueForKey:NSLocalizedDescriptionKey] message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	sendButton.enabled = YES;
	[connection release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell * cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
	
	switch (indexPath.row) {
		case 0:
		{
			cell.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
			cell.text = @"Email";
			cell.textColor = [UIColor darkGrayColor];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			if ( emailView == nil ) {
				emailView = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0, 30.0)];
				emailView.font = [UIFont systemFontOfSize:22.0];
				emailView.keyboardType = UIKeyboardTypeEmailAddress;
				emailView.autocorrectionType = UITextAutocorrectionTypeNo;
				emailView.borderStyle = UITextBorderStyleNone;
			}
			emailView.text = @"test@test.com";
			cell.accessoryView = emailView;
			break;
		}
		case 1:
		{
			cell.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
			cell.text = @"Subject";
			cell.textColor = [UIColor darkGrayColor];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			if ( subjectView == nil ) {
				subjectView = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0, 30.0)];
				subjectView.font = [UIFont systemFontOfSize:22.0];
				subjectView.borderStyle = UITextBorderStyleNone;
				
				NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
				[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
				[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
				
				NSDate *date = [NSDate date];
				subjectView.text = [dateFormatter stringFromDate:date];
			}
			cell.accessoryView = subjectView;
			break;
		}
		case 2:
		{
			if ( descriptionView == nil ) {
				descriptionView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 140.0)];
				descriptionView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
				descriptionView.scrollEnabled = NO;
			}
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell.contentView addSubview:descriptionView];
			break;
		}
		default:
			break;
	}
    
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ( indexPath.row > 1 ) return 140.0;
	return 44.0;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
// Navigation logic may go here. Create and push another view controller.
// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
// [self.navigationController pushViewController:anotherViewController];
// [anotherViewController release];
//}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


@end
