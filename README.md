# Memo-app

Memo-app is a simple memo application for FBC practices.

# Requirement

- erb_lint 0.5.0
- puma 6.3.1
- sinatra 3.1.0
- rubocop-fjord 0.3.0

# Installation

Add the following to your `Gemfile` and run `bundle install`.

```rb
gem 'erb_lint', require: false
gem 'puma'
gem 'sinatra'
gem 'sinatra-contrib'
group :development do
  gem 'rubocop-fjord', require: false
end

```

# Usage

Run the following command in your terminal.

```sh
bundle exec ruby memo_app.rb
```

Access the following url in your browser and use Memo-app.

```
http://127.0.0.1:4567/memo-top
```

Type `Ctrl＋C` in your terminal when you want to stop Memo-app.
