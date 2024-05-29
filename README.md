# README

## About Babelfu

[Babelfu](https://babelfu.com) is a web service that manages translations for your projects.

As with many other services, the idea is to provide a user-friendly interface to manage translations
for non-technical people like translators, product managers, etc, without the need to touch code and
other extra (but not less important) features.

The critical difference of Babelfu is that it uses GitHub as the source of truth
for your translations. You can use the same git workflow transparently
because Babelfu changes will appear as a regular commit in your pull requests.

Babelfu fetch the translations from your repository and allows you to edit them;
the same UI detects changes between the HEAD and BASE branches of your pull requests and display
the differences accordingly.

Once you are happy with the changes, you can commit them to the pull request base branch.

To set up a project, you only need to install the Babelfu GitHub App in your repository and invite
the users you want to give access to the translations. They don't need a Github account because
the app will commit them on their behalf.

### Work in progress

This project is a work in progress, but you can already use it to manage translations like the Rails I18n,
it supports YAML and JSON formats.

A cloud version is available on [babelfu.com](https://babelfu.com), but you can host it yourself if you want.

At the moment, it only implements the key features that I think are important to validate the idea from
the point of view of a developer integrating its repository on Babelfu.

There are a lot of details and optimizations pending and many features to implement, but everything
will depend on the feedback and the interest of the community.

You can follow the progress [here](https://github.com/orgs/babelfu/projects/4/views/7).

### Feedback

You can provide feedback or ask any question by creating an issue or sending
an email to jose.galisteo.ruiz@gmail.com.

## Running the project

### Configuration

The project can be configured via built-in Rails credentials (bin/rails credentials:edit) or
environment variables. The `dot-env` gem loads the environment variables from the `.env` files.

The `Babel::Config` module handles the configuration.

#### Active Record Encryption

It is used to encrypt several fields in the database. You can generate them with `bin/rails db:encryption:init`.
Save them on the credentials file with `bin/rails credentials:edit` or in the environment variables.

### Github App

Babelfu uses a GitHub App to interact with the GitHub API. You need to create and configure a GitHub App properly.

Create a [new app]([https://github.com/settings/apps]) on GitHub and set the following configuration:

- Callback URL: http://localhost:3000/connections/github/callback
- Enable: Expire user authorization tokens
- Enable: Request user authorization (OAuth) during installation

On post-installation:

- Enable: Redirect on update

On permissions:

- Commit statuses - Read & write
- Contents - Read & write
- Metadata - Read-only
- Pull requests - Read & write

Once the GitHub App is created, you will need to expose on `Babel.config` the following data: `app_id`, `client_id`, `client_secret` and the `private_key`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Flatito project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ceritium/flatito/blob/master/CODE_OF_CONDUCT.md).
