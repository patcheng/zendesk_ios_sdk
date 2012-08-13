Zendesk iOS development tools
-----------------------------

You can integrate this library to your application so that your app users can send support request directly from within the application.


Usage
-----

1. Add ZendeskDropboxLib folder and contents to your project.

2. Define a key 'ZDURL' in your application's plist with your Zendesk URL as value, e.g. mysite.zendesk.com.

3. (Optional) specify the tag for tickets (the default is dropbox) In Info.plist add the key "ZDTAG" and put a tag . E.g. "iphone"

4. Implement a ticket input form, the sample code uses a `UITableView` to implement a Mail-like interface for ticket input. 
Please refer to `ZendeskDropboxSampleViewController.m` for details.

5. instantiate the dropbox class:
   ``ZendeskDropbox *dropbox = [[ZendeskDropbox alloc] initWithDelegate:self];``
 
6. Submit the request:
   ``[dropbox submitWithEmail:@"Email..." subject:@"Subject" andDescription:@"Description..."];``

7. (Optional) Implement the delegate methods to handle the response. Please refer to ZendeskDropbox.h for details