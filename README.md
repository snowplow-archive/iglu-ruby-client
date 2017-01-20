# Ruby client for Iglu

[![Build Status] [travis-image]] [travis] 
[![Release] [release-image]] [releases] 
[![License] [license-image]] [license] 
[![Coverage Status] [coverage-image]] [coverage]

A Ruby client and resolver for **[Iglu schema repositories] [iglu-wiki]** from the team at **[Snowplow Analytics] [snowplow-website]**.

Iglu Ruby Client is used to validate self-describing JSONs. For a presentation on how we came to build Iglu, see **[this blog post] [snowplow-schema-post]**.

![client-img] [client-img]

## Installation

The Ruby Iglu Client is published to [RubyGems] [rubygems], the Ruby community's gem hosting service. 
This makes it easy to either install the client locally, or to add it as a dependency into your own Ruby app.

To install the Iglu Ruby Client locally:

    $ gem install iglu-ruby-client

To add the Iglu Client as a dependency to your own Ruby gem, edit your gemfile and add:

```ruby
gem 'iglu-ruby-client'
```

## Usage

The primary entity for working with Iglu Ruby Client is `Iglu::Client`.
Resolver static method `parse` allows you to create Resolver instance from a **[resolver configuration] [resolver-config]**.
The second working method is `lookup_schema`, receiving Schema key as String or directly `com.snowplowanalytics.iglu.SchemaKey` object,
this method traverses all configured repositories trying to find Schema by its key.

```ruby
require 'json'
require 'iglu-client'

schema_key = Iglu::SchemaKey.parse_key("iglu:com.snowplowanalytics.snowplow/mobile_context/jsonschema/1-0-0")
resolver = Iglu::Resolver.parse(JSON.parse(resolver_config, {:symbolize_names => true}))
schema = resolver.lookup_schema(schema_key)
```

Above snippet returns a mobile context JSON Schema if you provide the correct `resolver_config`.

## Developer quickstart

Assuming git, **[Vagrant] [vagrant-install]** and **[VirtualBox] [virtualbox-install]** installed:

```bash
 host> git clone https://github.com/snowplow/iglu-ruby-client
 host> cd iglu-ruby-client
 host> vagrant up && vagrant ssh
guest> cd /vagrant
guest> rspec
```

## Find out more

| **[Technical Docs] [techdocs]**     | **[Setup Guide] [setup]**     | **[Roadmap] [roadmap]**           | **[Contributing] [contributing]**           |
|-------------------------------------|-------------------------------|-----------------------------------|---------------------------------------------|
| [![i1] [techdocs-image]] [techdocs] | [![i2] [setup-image]] [setup] | [![i3] [roadmap-image]] [roadmap] | [![i4] [contributing-image]] [contributing] |

## Copyright and license

Iglu Ruby Client is copyright 2017 Snowplow Analytics Ltd.

Licensed under the **[Apache License, Version 2.0] [license]** (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[client-img]: https://github.com/snowplow/iglu/wiki/technical-documentation/images/iglu-clients.png

[iglu-wiki]: https://github.com/snowplow/iglu/wiki
[snowplow-schema-post]: http://snowplowanalytics.com/blog/2014/06/06/making-snowplow-schemas-flexible-a-technical-approach/
[resolver-config]: https://github.com/snowplow/iglu/wiki/Iglu-client-configuration

[snowplow-repo]: https://github.com/snowplow/snowplow
[snowplow-website]: http://snowplowanalytics.com

[vagrant-install]: http://docs.vagrantup.com/v2/installation/index.html
[virtualbox-install]: https://www.virtualbox.org/wiki/Downloads

[techdocs-image]: https://d3i6fms1cm1j0i.cloudfront.net/github/images/techdocs.png
[setup-image]: https://d3i6fms1cm1j0i.cloudfront.net/github/images/setup.png
[roadmap-image]: https://d3i6fms1cm1j0i.cloudfront.net/github/images/roadmap.png
[contributing-image]: https://d3i6fms1cm1j0i.cloudfront.net/github/images/contributing.png

[techdocs]: https://github.com/snowplow/iglu/wiki/Ruby-client
[setup]: https://github.com/snowplow/iglu/wiki/Ruby-client-setup
[roadmap]: https://github.com/snowplow/iglu/wiki/Product-roadmap
[contributing]: https://github.com/snowplow/iglu/wiki/Contributing

[travis]: https://travis-ci.org/snowplow/iglu-ruby-client
[travis-image]: https://travis-ci.org/snowplow/iglu-ruby-client.png?branch=master

[releases]: https://github.com/snowplow/ruby-iglu-client/releases
[release-image]: http://img.shields.io/badge/release-0.1.0-blue.svg?style=flat

[license]: http://www.apache.org/licenses/LICENSE-2.0
[license-image]: http://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

[coveralls]: https://coveralls.io/r/snowplow/iglu-ruby-client
[coveralls-image]: https://coveralls.io/repos/snowplow/iglu-ruby-client/badge.png

