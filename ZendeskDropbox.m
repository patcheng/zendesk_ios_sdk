//
//  CocoaZendesk.m
//  CocoaZendesk
//
//  Created by Bill So on 06/05/2009.
//  Copyright 2009 Zendesk Inc. All rights reserved.
//

#import "ZendeskDropbox.h"
#import "NSString+SBJSON.h"

NSString *const ZendeskDropboxDescription = @"description";
NSString *const ZendeskDropboxEmail = @"email";
NSString *const ZendeskDropboxSubject = @"subject";
NSString *const ZendeskURLDoesNotExistException = @"ZDURLDoesNotExist";

@implementation ZendeskDropbox

@synthesize delegate;

- (id)init {
	self = [super init];
	NSDictionary *theDict = [[NSBundle mainBundle] infoDictionary];
	baseURL = [[theDict valueForKey:@"ZDURL"] retain];
	if ( baseURL == nil || [baseURL isEqualToString:@""] ) {
		// raise exception
		NSException* myException = [NSException
									exceptionWithName:ZendeskURLDoesNotExistException
									reason:@"ZDURL is not set in Info.plist file"
									userInfo:nil];
		@throw myException;
	}
	tag = [[theDict valueForKey:@"ZDTAG"] retain];
	if ( tag == nil || [tag isEqualToString:@""] ) {
		tag = [NSString stringWithString:@"dropbox"];
	}

	return self;
}

- (void)dealloc {
	[baseURL release];
	if ( tag != nil ) [tag release];
	[super dealloc];
}

- (void)sendTicket:(NSDictionary *)ticketInfo {
	// create the request
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/requests/mobile_api/create", baseURL]]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:10.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"1.0" forHTTPHeaderField:@"X-Zendesk-Mobile-API"];
	NSMutableString * bodyStr = [[[NSMutableString alloc] init] autorelease];
	if ( tag != nil ) {
		[bodyStr appendFormat:@"set_tags=%@&", tag];
	}
	[bodyStr appendFormat:@"description=%@&email=%@&subject=%@&via_id=17&commit=", 
	 [[ticketInfo valueForKey:ZendeskDropboxDescription] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
	 [[ticketInfo valueForKey:ZendeskDropboxEmail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
	 [[ticketInfo valueForKey:ZendeskDropboxSubject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[theRequest setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData alloc] initWithLength:128];
	} else {
		// inform the user that the download could not be made
	}
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
	if ( [delegate respondsToSelector:@selector(submissionConnectedToServer:)] ) {
		[delegate submissionConnectedToServer:self];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
//    NSLog(@"Connection failed! Error - %@ %@",
//          [error localizedDescription],
//          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	if ( [delegate respondsToSelector:@selector(submission:didFailWithError:)] ) {
		[delegate submission:self didFailWithError:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	NSString *theStr = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
	JSONString *jstr = [[[JSONString alloc] initWithString:theStr] autorelease];
	NSDictionary *dict = [jstr JSONValue];
	
	NSString *msg = [dict valueForKey:@"error"];
	if ( msg ) {
		NSError *myerr;
		NSRange myrange;
		myrange = [msg rangeOfString:@"subject"];
		if ( myrange.location != NSNotFound ) {
			myerr = [NSError errorWithDomain:NSCocoaErrorDomain code:ZDErrorMissingSubject userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		myrange = [msg rangeOfString:@"description"];
		if ( myrange.location != NSNotFound ) {
			myerr = [NSError errorWithDomain:NSCocoaErrorDomain code:ZDErrorMissingDescription userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		myrange = [msg rangeOfString:@"email"];
		if ( myrange.location != NSNotFound ) {
			myerr = [NSError errorWithDomain:NSCocoaErrorDomain code:ZDErrorMissingEmail userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		if ( [delegate respondsToSelector:@selector(submission:didFailWithError:)] ) {
			[delegate submission:self didFailWithError:myerr];
		}
	} else {
		msg = [dict valueForKey:@"message"];
		//NSLog(@"message: %@", msg);
		if ( [delegate respondsToSelector:@selector(submissionDidFinishLoading:)] ) {
			[delegate submissionDidFinishLoading:self];
		}
	}
	
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

@end
