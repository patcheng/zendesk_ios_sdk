Zendesk iOS development tools
-----------------------------

You can integrate this library to your application so that your app users can send support request directly from within the application.


Compatibility
-----

By request there are now 2 versions of the lib, one with JSON lib files included, and one without to avoid conflicts with versions of the JSON framework already present in projects.

Use ZendeskDropboxNoJsonLib if you are providing your own version of the JSON framework.

Usage
-----

1. Add ZendeskDropboxLib folder and contents to your project.

2. Define a key 'ZDURL' in your application's plist with your Zendesk URL as value, e.g. mysite.zendesk.com.

3. (Optional) specify the tag for tickets (the default is dropbox) In Info.plist add the key "ZDTAG" and put a tag . E.g. "iphone"

4. Implement a ticket input form, the sample code uses a `UITableView` to implement a Mail-like interface for ticket input. 
Please refer to `FormViewController.m` for details.

5. instantiate the dropbox class:
   ``ZendeskDropbox *dropbox = [[ZendeskDropbox alloc] initWithDelegate:self];``
 
6. Submit the request:
   ``[dropbox submitWithEmail:@"Email..." subject:@"Subject" andDescription:@"Description..."];``

7. (Optional) Implement the delegate methods to handle the response. Please refer to ZendeskDropbox.h for details


Rebuilding the lib
----------------

1. Switch all schemes to release target

2. Build the target 'ZendeskiPhoneSimulator' against an iPhone simulator

3. Build the target 'ZendeskiPhone' against an IOS Device (does not have to be connected)

4. Build the target 'libZendeskDropbox' against an IOS Device (does not have to be connected)

5. The combined lib can then be found in the relevant build directory, in Xcode 4.3.2 this can be found at: 
   ``/Users/{user}/Developer/Xcode/DerivedData/ZendeskDropboxIOS-{...}/Build/Products/libZendeskDropbox/libZendeskDropbox.a``


## Copyright and license

Copyright 2013 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
