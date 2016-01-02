# Capistrano::GitBuild

A Capistrano 3.x deploy strategy.

The idea behind this strategy is to checkout the Git repository in a temporary directory first, on the local machine (the one which started the deploy task).

Hereafter, custom build tasks can be implemented on the checkout code (e.g. compile your static site with [Jekyll](http://jekyllrb.com/), compile [SASS](http://sass-lang.com/) or import some external modules using [Composer](https://getcomposer.org/) for your project or anything else).

Finally, the code will be archived in a tarball, uploaded to the servers and extracted in the release directory like normal.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-scm-gitbuild'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-scm-gitbuild

## Usage

Tell Capistrano to use the GitBuild deploy strategy like so:
```ruby
# Copy strategy
set :scm, :gitbuild
```

To deploy a subdirectory instead of the full root of the project, you can of course use `:repo_tree` which is supported by default in Capistrano.
```ruby
# Deploy subdirectory
set :repo_tree, 'project'
```

To implement your own build logic before the tarball is created and uploaded to the servers, you must implement the `gitbuild:build` task like so:
```ruby
namespace :gitbuild do
  task :build do
    run_locally do
      # Implement custom build logic.
    end
  end
end
```

When you deploy, the repository will be checked out first in a temporary directory (locally - on the machine which started the deploy task).
After that you have the ability to implement custom build tasks.
Finally, a tarball will be created, uploaded to all servers and extracted.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jover/capistrano-scm-gitbuild. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org/) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

