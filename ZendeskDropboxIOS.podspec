Pod::Spec.new do |spec|
	spec.name					= 'ZendeskDropboxIOS'
	spec.version 				= '1.0'
	spec.license				= 'Apache License, Version 2.0'
	spec.summary				= 'Zendesk iOS library'
	spec.homepage				= 'https://github.com/sergey-sportsetter/zendesk_ios_sdk'
	spec.social_media_url 		= 'https://twitter.com/Zendesk'
	spec.authors				= { 'Zendesk' => ' support@zendesk.com' }
	spec.source					= { :git => 'https://github.com/sergey-sportsetter/zendesk_ios_sdk.git', :tag => '1.0' }
	spec.requires_arc			= true

	spec.ios.deployment_target 	= '6.0'

	spec.public_header_files	= 'Dropbox/*.h'
	spec.source_files			= 'Dropbox/*'
	spec.dependency	'SBJson4', '~> 4.0.0'
end

