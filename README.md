# Rubygems historian

App to save a group of gem's download history.

Copy the config YAML file and edit it to select the gems you want to follow:

```bash
$ cp config.yml{.sample,}
```

There's a rake task to create the database:

```bash
$ rake setup
```

And a rake task to update the gem downloads in the database:

```bash
$ rake update_gems
```
Ideally you want to schedule this task to run once a day/week/month with cron or similar

## Deploying to Heroku

If you want to use Heroku and PostgreSQL, the app is going to get `ENV['DATABASE_URL']` automatically and connect to Postgres.

The way I'm deploying this app to Heroku is I have a `heroku` branch where I've committed `config.yml` and `Gemfile.lock`. Whenever I update `master`, I rebase that branch and push it to heroku. You can push the `heroku` branch to Heroku with:

```bash
$ git push -f heroku heroku:master
```

Once it's deployed, remember to run `heroku run rake setup`.

I am using [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler)) to run the data collection every night. Create a new job, choose your schedule and enter this as your Run Command:
```
$ rake update_gems
```
