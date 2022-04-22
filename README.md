# Set up Github Repository Secrets
Work in progress scripts for setting secrets for Github repositories and their environments

# How to Use it
Clone the repo

Copy `.env-example` to `.env`. Update `.env` with your Github PAT with repository access.

`docker-compose build`

For setting a repo secret edit `set_repo_secret.rb` and fill in the `my_*` variables at the top of the file. Then run:
```
docker-compose run --rm web ruby set_repo_secret.rb
```


For setting an environment secret edit `set_environment_secret.rb` and fill in the `my_*` variables at the top of the file. Then run:
```
docker-compose run --rm web ruby set_environment_secret.rb
```
