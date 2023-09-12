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

Install PostgreSQL by referring to [the official website.](https://www.postgresql.jp/download)

Connect to PostgreSQL as a superuser or a user with permission in your terminal.
Enter the following command to create the database.

```sh
CREATE DATABASE memo_app_db;
```

Enter the following command to connect to `memo_app_db`.

```sh
\c memo_app_db
```

Enter the following command to create TABLE for memo_app.
If you want to save more letters, change the numbers of title and content.
But do not change the number in `memo_id CHAR(36)`.

```sh
CREATE TABLE memos
(memo_id  CHAR(36)  NOT NULL,
title  VARCHAR(100)  NOT NULL,
content  VARCHAR(500),
PRIMARY KEY (memo_id));
```

Database creation is now complete. Please log out from `memo_app_db`.

```sh
exit
```

# Usage

Run the following command in your terminal.

```sh
bundle exec ruby memo_app.rb
```

Access the following url in your browser and use Memo-app.

```
http://127.0.0.1:4567/memos
```

Type `Ctrl＋C` in your terminal when you want to stop Memo-app.
