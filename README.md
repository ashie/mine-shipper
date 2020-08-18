# mine-shipper

A command to duplicate comments on a GitHub issue to an associated Redmine issue.

## Prepare on Redmine

1. Create API access key of your Redmine account
  * My account -> API access key
2. Create a custom field with the following properties (Administration -> Custom fields)
  * Format: `Link`
  * Name: `GitHub`
  * Regular expression: `\A([\w-]+)/([\w-]+)#(\d+)\z`
  * Used as a filter: checked
3. Enable the custom field at your Redmine project
4. Create an issue on the project
  * Fill "GitHub" custom fileld to associate a GitHub issue to the Redmine issue.
    e.g.) groonga/groonga#1062

## Installation

```
$ bundle install
$ cp sample.env .env
```

Then edit .env to adopt to your environment.
`GITHUB_ACCESS_TOKEN` is optional but recommended to set to exceed [API rate limit](https://developer.github.com/v3/rate_limit/).
See https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token to know how to get it.

## Usage

Run ./bin/mine-shipper command with `--github-issue` option to specify the issue.

e.g.)

```
$ bundle exec ./bin/mine-shipper --github-issue groonga/groonga#1062
```

The comments on the GitHub issue will be copied to the associated Redmine issue.
If no associated issue on Redmine is found or the comments are already copied, it does nothing.

## Plans

* Create a new issue when no associated issue is found
* Close a Redmine issue automatically if an associated GitHub issue is closed
* Synchronize updated comments ([need to add new API to Redmine](https://www.redmine.org/issues/10171))
* Work as Webhook
* ...
