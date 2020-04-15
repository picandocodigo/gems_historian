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
