# Set up Github Repository Secrets
Script for getting Kuberentes Secrets into Github Secrets.

## Dependencies
* `ruby` 
* `bundler`
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [tanka](https://tanka.dev/install)
* Kubernetes configuration written in `jsonnet` for application with `tanka`
* Authorization to read your given kubernetes namespace with `kubectl`

## Usage
Clone the repo

Copy `.env-example` to `.env`. 

Update `.env` with your Github PAT with repository access. You need this to add/update Github secrets.

Install the gems into `vendor/bundle`
```
`bundle install` 
```

Run the the script
```
./set-k8s-secrets.sh /path/to/tanka/environment organization/repository [github_environment]
```
If the `github_environment` isn't given, it will set **repository** secrets rather than **environment** secrets. 

If you need to set multiple sets of **repository** secrets, edit this script to change the name of the secrets it creates.

## Notes
Docker / docker-compose isn't used because of needing to use `kubectl` and `tk` which would be overly complicated to get working with Docker.

## Future Enhancements
Right now the script depends on `tanka`. It would be good to have a `kubectl` only option.
