//
//  ZendeskDropbox.m
//  ZendeskDropbox
//
//  Created by Graham Cruse on 10/08/2012.
//  Copyright (c) 2012 Zendesk All rights reserved.
//

#import "ZendeskDropbox.h"
#import "SBJson4.h"

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
        baseURL = [theDict valueForKey:@"ZDURL"];
        
        // check for base url
        if ( baseURL == nil || [baseURL isEqualToString:@""] ) {
            NSException* myException = [NSException
                                        exceptionWithName:ZendeskURLDoesNotExistException
                                        reason:@"ZDURL is not set in Info.plist file"
                                        userInfo:nil];
            @throw myException;
        }
        
        // check for tags
        tag = [theDict valueForKey:@"ZDTAG"];
        if ( tag == nil || [tag isEqualToString:@""] ) {
            tag = @"dropbox";
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
    
	// start the request
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
    theConnection = nil;
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
    receivedData = nil;
    theConnection = nil;
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    SBJson4ValueBlock valueBlock = ^(id v, BOOL *stop) {
        if ([v isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *) v;
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
            receivedData = nil;
            theConnection = nil;
            
        }
    };
    SBJson4ErrorBlock errorBlock = ^(NSError* err) {
    };
    
    id parser = [SBJson4Parser parserWithBlock:valueBlock
                                allowMultiRoot:YES
                               unwrapRootArray:YES
                                  errorHandler:errorBlock];
    
    NSData *jsonData = [NSData dataWithData:receivedData];
    [parser parse:jsonData];
}


#pragma mark misc


- (NSString*) encodeStringForPost:(NSString*)string
{
    if (string) {
        CFStringRef s = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]-",
                                                                kCFStringEncodingUTF8 );
        return (__bridge  NSString*)s;
    }
    return @"";
}

@end
