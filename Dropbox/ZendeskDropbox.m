//
//  ZendeskDropbox.m
//  ZendeskDropbox
//
//  Created by Graham Cruse on 10/08/2012.
//  Copyright (c) 2012 Zendesk All rights reserved.
//

#import "ZendeskDropbox.h"
#import "NSString+SBJSON.h"


NSString *const ZendeskDropboxDescription = @"description";
NSString *const ZendeskDropboxEmail = @"email";
NSString *const ZendeskDropboxSubject = @"subject";
NSString *const ZendeskURLDoesNotExistException = @"ZDURLDoesNotExist";


@implementation ZendeskDropbox


@synthesize delegate;


- (id) init
{
	self = [super init];
    if (self) {
        NSDictionary *theDict = [[NSBundle mainBundle] infoDictionary];
        baseURL = [[theDict valueForKey:@"ZDURL"] retain];
        
        // check for base url
        if ( baseURL == nil || [baseURL isEqualToString:@""] ) {
            NSException* myException = [NSException
                                        exceptionWithName:ZendeskURLDoesNotExistException
                                        reason:@"ZDURL is not set in Info.plist file"
                                        userInfo:nil];
            @throw myException;
        }
        
        // check for tags
        tag = [[theDict valueForKey:@"ZDTAG"] retain];
        if ( tag == nil || [tag isEqualToString:@""] ) {
            tag = [NSString stringWithString:@"dropbox"];
        }
    }
	return self;
}


- (id) initWithDelegate:(id<ZendeskDropboxDelegate>)theDelegate
{
	self = [self init];
    if (self) {
        delegate = theDelegate;
    }
	return self;
}


#pragma mark request control


- (void) submitWithEmail:(NSString*)email subject:(NSString*)subject andDescription:(NSString*)description 
{
	// create the request
    NSString *urlString = [NSString stringWithFormat:@"https://%@/requests/mobile_api/create", baseURL];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // configure request
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"1.0" forHTTPHeaderField:@"X-Zendesk-Mobile-API"];
    
    // add form body
	NSMutableString * bodyStr = [[NSMutableString alloc] init];
	if ( tag != nil ) {
		[bodyStr appendFormat:@"set_tags=%@&", tag];
	}
	[bodyStr appendFormat:@"description=%@&email=%@&subject=%@&via_id=17&commit=", 
        [self encodeStringForPost:description],
        [self encodeStringForPost:email], 
        [self encodeStringForPost:subject]];
	
	[theRequest setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyStr release];
    
	// start the request
    [theConnection release];
    theConnection = nil;
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
	if (theConnection) {
		// Create the NSMutableData that will hold the received data
		receivedData=[[NSMutableData alloc] initWithLength:128];
	} else {
		// inform the user that the download could not be made
	}
}


- (void) cancelRequest
{
    [theConnection cancel];
    [theConnection release];
    theConnection = nil;
    [receivedData release];
    receivedData = nil;
}


#pragma mark connection callbacks


- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0]; // prepare for data
	if ( [delegate respondsToSelector:@selector(submissionConnectedToServer:)] ) {
		[delegate submissionConnectedToServer:self];
	}
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ( [delegate respondsToSelector:@selector(submission:didFailWithError:)] ) {
		[delegate submission:self didFailWithError:error];
	}
    [receivedData release];
    receivedData = nil;
    [theConnection release];
    theConnection = nil;
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *theStr = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
	JSONString *jstr = [[[JSONString alloc] initWithString:theStr] autorelease];
	NSDictionary *dict = [jstr JSONValue];
	
	NSString *msg = [dict valueForKey:@"error"];
	if ( msg ) {
		NSError *myerr = nil;
		NSRange myrange;
		myrange = [msg rangeOfString:@"subject"];
		if ( myrange.location != NSNotFound ) {
			myerr = [NSError errorWithDomain:NSCocoaErrorDomain 
                                        code:ZDErrorMissingSubject 
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		myrange = [msg rangeOfString:@"description"];
		if ( myrange.location != NSNotFound ) {
			myerr = [NSError errorWithDomain:NSCocoaErrorDomain 
                                        code:ZDErrorMissingDescription 
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		myrange = [msg rangeOfString:@"email"];
		if ( myrange.location != NSNotFound ) {
			myerr = [NSError errorWithDomain:NSCocoaErrorDomain 
                                        code:ZDErrorMissingEmail 
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		if ( [delegate respondsToSelector:@selector(submission:didFailWithError:)] ) {
			[delegate submission:self didFailWithError:myerr];
		}
	} else {
		if ( [delegate respondsToSelector:@selector(submissionDidFinishLoading:)] ) {
			[delegate submissionDidFinishLoading:self];
		}
	}
    [receivedData release];
    receivedData = nil;
    [theConnection release];
    theConnection = nil;
}


#pragma mark misc


- (NSString*) encodeStringForPost:(NSString*)string
{
    if (string) {
        CFStringRef s = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]-",
                                                                kCFStringEncodingUTF8 );
        return [(NSString*)s autorelease];
    }
    return @"";
}


- (void) dealloc
{
	[receivedData release];
	[baseURL release];
	[tag release];
    [theConnection release];
	[super dealloc];
}

@end
