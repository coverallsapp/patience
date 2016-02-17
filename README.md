# patience
Use this when the database is down.

## Redis data structures
### "#{service}:#{repo_user}:#{repo_name}:info"

Hash containing

* `public` string of 't' or 'f'
* `badge_token` string
* `default_branch` string

### "#{service}:#{repo_user}:#{repo_name}:coverage"

Hash with the keys being the branch names, and the values being the coverage number as a whole number (stored as a string).
