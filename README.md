![Great Horned Owl](http://upload.wikimedia.org/wikipedia/commons/thumb/9/98/GreatHornedOwl-Wiki.jpg/640px-GreatHornedOwl-Wiki.jpg)

# AWS Owl

AWS Owl watches your accounts, saving their state to a git repository and
emailing you with any changes.

## AWS API

AWS Owl uses the official aws-sdk gem
<https://github.com/amazonwebservices/aws-sdk-for-ruby>. This is pretty sweet
for older features where the object models have been fully built out in ruby.
For newer features, you have to use the AWS::EC2::Client class to issue raw API
requests.

### dependencies

- `aptitude install libxml2-dev libxslt1-dev` (needed for nokogiri)

- `gem install aws-sdk` (will pull in uuidtools, multi_xml, httparty, nokogiri, json)
