# CloudCheckr

This is the Ruby client for the CloudCheckr API.

## Installation

Add this line to your application's Gemfile:

    gem 'cloudcheckr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudcheckr

## Usage

The API client uses JSON by default. Here's how to instantiate an API client.

```ruby
# The only thing you need is an API key
client = CloudCheckr::API::Client.new(access_key: "146D0Y8R...W6U0463K")

# Another option is to set the API key globally
CloudCheckr::API.access_key("146D0Y8R...W6U0463K")
client = CloudCheckr::API::Client.new

# Alternatively, keep the API key in an environment variable
ENV['CLOUDCHECKR_ACCESS_KEY'] = "146D0Y8R...W6U0463K"
client = CloudCheckr::API::Client.new

# JSON responses automatically convert keys from camel case to snake case.
# You can disable key conversion globally
CloudCheckr::API.snake_case_json_keys(false)

# Use XML instead (not fully implemented)
client = CloudCheckr::API::Client.new(format: :xml)
```

Each endpoint (or "API call") is grouped into a "controller". The API client has a method representing each controller, and each controller has a method for each API call.

```ruby
client = CloudCheckr::API::Client.new

# The API client is pre-configured with a list of controllers, for which you can get a listing
# Call any of these as a method on the `client`
controller_names = client.controller_names
# => [:account, :alert, :best_practice, :billing, :change_monitoring, :cloudwatch, :cloudwatchevent, :help, :inventory, :security]

# Each controller is pre-configured with a list of API calls, for which you can also get a listing
# Call any of these as a method on a controller
api_calls = client.help.api_calls
# => [:get_all_api_endpoints]

# Let's get a list of all endpoints available to you based on your API access key
# NOTE: The API client is pre-configured with a cached list of endpoints 
#       and does not use the results of this call, specific to your API access key
# https://api.cloudcheckr.com/api/help.json/get_all_api_endpoints?access_key=[access_key]
endpoints = client.help.get_all_api_endpoints
# => [{"controller_name"=>"account", "api_calls"=>[{"method_name"=>"get_users"...

# As an example, we'll call the first endpoint listed in the above response
# https://api.cloudcheckr.com/api/account.json/get_users?access_key=[access_key]
users = client.account.get_users
# => {"users_and_accounts"=>[{"username"=>"user@example.com", "account_names"=>["Example"]}]}

# Pass parameters to an API call
client.account.remove_user(email: "user@example.com")

# Pass headers to an API call
client.account.remove_user({email: "user@example.com"}, {'Content-Type': 'application/json'})
```

_NOTE: The controllers and API calls are defined in [endpoints.yml](./lib/cloud_checkr/api/endpoints.yml) (which is a cached listing retrieved from [get_all_api_endpoints](http://support.cloudcheckr.com/cloudcheckr-api-userguide/cloudcheckr-api-reference-guide/#get_all_api_endpoints))._

Here's more information about the [API Reference](http://support.cloudcheckr.com/cloudcheckr-api-userguide/cloudcheckr-api-reference-guide/).

### Admin API

Some endpoints are admin-level and require an account name.

```ruby
access_key = "146D0Y8R...W6U0463K"
account    = "Account Name"

# Create an API client for with a default account specified
client = CloudCheckr::API::Client.new(access_key: access_key, use_account: account)

# Another option is to set the default account globally
CloudCheckr::API.use_account(account)
client = CloudCheckr::API::Client.new

# Alternatively, keep the API key in an environment variable
ENV['CLOUDCHECKR_USE_ACCOUNT'] = account
client = CloudCheckr::API::Client.new
```

Here's more information about the [Admin API](http://support.cloudcheckr.com/cloudcheckr-api-userguide/cloudcheckr-admin-api-reference-guide/).

Here's the [Admin API User Guide](http://support.cloudcheckr.com/cloudcheckr-api-userguide/).

### Faraday

The API client uses [Faraday](https://github.com/lostisland/faraday) under the hood. [Faraday Middleware](https://github.com/lostisland/faraday_middleware) is utilized to parse JSON and XML responses. JSON responses are wrapped in [Hashie::Mash](https://github.com/intridea/hashie) for easy access to data.

It's easy to customize Faraday to your liking.

```ruby
# Globally apply Faraday settings
CloudCheckr::API.connection_builder do |faraday|
  faraday.request :url_encoded

  faraday.response :xml,     content_type: /\bxml$/
  faraday.response :json,    content_type: /\bjson$/
  faraday.response :mashify, content_type: /\bjson$/
  faraday.response :logger, nil, bodies: true

  faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
end

# Alternatively, apply Faraday settings per client
client = CloudCheckr::API::Client.new do
  faraday.request :url_encoded

  faraday.response :xml,     content_type: /\bxml$/
  faraday.response :json,    content_type: /\bjson$/
  faraday.response :mashify, content_type: /\bjson$/
  faraday.response :logger, nil, bodies: true

  faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
end
```

You may also want to configure individual Faraday requests. This can be accomplished with any API call (see [Faraday examples](https://github.com/lostisland/faraday) for specifics).

```ruby
client = CloudCheckr::API::Client.new

# Let's get a list of all endpoints available to you based on your API access key
endpoints = client.help.get_all_api_endpoints do |request|
  req.url '/search', page: 2
  req.params['limit'] = 100
  req.headers['Content-Type'] = 'application/json'
  req.body = '{ "name": "value" }'
  req.options.timeout = 5      # open/read timeout in seconds
  req.options.open_timeout = 2 # connection open timeout in seconds
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cloudcheckr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### TODO

* Determine if there is a use case for XML format
* RSpec tests


