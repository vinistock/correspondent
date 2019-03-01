[![Build Status](https://travis-ci.com/vinistock/correspondent.svg?branch=master)](https://travis-ci.com/vinistock/correspondent) [![Maintainability](https://api.codeclimate.com/v1/badges/07592c6d6b946a7b71fc/maintainability)](https://codeclimate.com/github/vinistock/correspondent/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/07592c6d6b946a7b71fc/test_coverage)](https://codeclimate.com/github/vinistock/correspondent/test_coverage) [![Gem Version](https://badge.fury.io/rb/correspondent.svg)](https://badge.fury.io/rb/correspondent) ![](http://ruby-gem-downloads-badge.herokuapp.com/correspondent?color=brightgreen&type=total)

# Correspondent

Dead simple configurable user notifications using the Correspondent engine!

Configure subscribers and publishers and let Correspondent deal with all notification work with very little overhead.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'correspondent'
```

And then execute:
```bash
$ bundle
```

Create the necessary migrations:

```bash
$ rails g correspondent:install
```

## Usage

### Model configuration

Notifications can easily be setup using Correspondent. The following example goes through the basic usage. There are only two steps for the basic configuration:

1. Invoke notifies and configure the subscriber (user in this case), the triggers (method purchase in this case) and desired options
2. Define the to_notification method to configure information that needs to be used to create notifications 

```ruby
# Example model using Correspondent
# app/models/purchase.rb 
class Purchase < ApplicationRecord
  belongs_to :user
  
  # Notifies configuration
  # First argument is the subscriber (the one that receives a notification). Can be an NxN association as well (e.g.: users) which will create a notification for each associated record.
  # Second argument are the triggers (the method inside that model that triggers notifications). Can be an array of symbols for multiple triggers for the same entity.
  # Third argument are generic options as a hash 
  notifies :user, :purchase, avoid_duplicates: true

  # `notifies` will hook into the desired triggers.
  # Every time this method is invoked by an instance of Purchase
  # a notification will be created in the database using the
  # `to_notification` method. The handling of notifications is
  # done asynchronously to cause as little overhead as possible.
  def purchase
    # some business logic
  end

  # The to_notification method returns the information to be
  # used for creating a notification. This will be invoked automatically
  # by the gem when a trigger occurs.
  # When calling this method, entity and trigger will be passed. Entity
  # is the subscriber (in this example, `user`). Trigger is the method
  # that triggered the notification. With this approach, the hash
  # built to pass information can vary based on different triggers.
  # If entity and trigger will not be used, this can simply be defined as
  #
  # def to_notification(*)
  #   # some hash
  # end 
  def to_notification(entity:, trigger:)
    {
      title: "Purchase ##{id} for #{entity} #{send(entity).name}",
      content: "Congratulations on your recent #{trigger} of #{name}",
      image_url: "",
      link_url: "/purchases/#{id}"
    }
  end
end
```

### Options

The available options, their default values and their explanations are listed below.

```ruby
# Avoid duplicates
# Prevents creating new notifications if a non dismissed notification for the same publisher and same subscriber already exists
notifies :some_resouce, :trigger, avoid_duplicates: false
```

### JSON API

Correspondent exposes a few APIs to be used for handling notification logic in the application.

```json
Parameters

:subscriber_type -> The subscriber resource name - not in plural (e.g.: user)
:subscriber_id   -> The id of the subscriber

Index

Retrieves all non dismissed notifications for a given subscriber.

Request
GET /correspondent/:subscriber_type/:subscriber_id/notifications

Response
[
    {
        "id":20,
        "title":"Purchase #1 for user user",
        "content":"Congratulations on your recent purchase of purchase",
        "image_url":"",
        "dismissed":false,
        "publisher_type":"Purchase",
        "publisher_id":1,
        "created_at":"2019-03-01T14:19:31.273Z",
        "link_url":"/purchases/1"
    }
]

Preview

Returns total number of non dismissed notifications and the newest notification.

Request
GET /correspondent/:subscriber_type/:subscriber_id/notifications/preview

Response
{
    "count": 3,
    "notification": {
        "id":20,
        "title":"Purchase #1 for user user",
        "content":"Congratulations on your recent purchase of purchase",
        "image_url":"",
        "dismissed":false,
        "publisher_type":"Purchase",
        "publisher_id":1,
        "created_at":"2019-03-01T14:22:31.649Z",
        "link_url":"/purchases/1"
    }
}


Dismiss

Dismisses a given notification.

Resquest
PUT /correspondent/:subscriber_type/:subscriber_id/notifications/:notification_id/dismiss

Response
STATUS no_content (204) 
```

## Contributing

Contributions are very welcome! Don't hesitate to ask if you wish to contribute, but don't yet know how. Please refer to this simple [guideline].

[guideline]: https://github.com/vinistock/correspondent/blob/master/CONTRIBUTING.md
