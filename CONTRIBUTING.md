## 🛠️ Contributing to Blobstream Starknet 🛠️

<!-- markdownlint-disable MD051 -->
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-8-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
<!-- markdownlint-enable MD051 -->

Welcome, contributing to `blobstream_sn` is easy!

1. Submit or comment your intent on an issue
1. We will try to respond quickly
1. Fork this repo
1. Submit your PR against `main`
1. Address PR Review

### Issue

Project tracking is done via GitHub [issues](https://github.com/keep-starknet-strange/blobstream-starknet/issues).
First look at open issues to see if your request is already submitted.
If it is comment on the issue requesting assignment, if not open an issue.

We use 3 issue labels for development:

- `feat` -> suggest new feature
- `bug` -> create a reproducible bug report
- `dev` -> non-functional repository changes

These labels are used as prefixes as follows for `issue`, `branch name`, `pr title`:

- `[feat]` -> `feat/{issue #}-{issue name}` -> `feat:`
- `[bug]` -> `bug/{issue #}-{issue name}` -> `bug:`
- `[dev]` -> `dev/{issue #}-{issue name}` -> `dev:`

#### TODO

If your PR includes a `TODO` comment please open an issue and comment the relevant
code with `TODO(#ISSUE_NUM):`.

### Submit PR

Ensure your code is well formatted, well tested and well documented. A core contributor
will review your work. Address changes, ensure ci passes,
and voilà you're a `blobstream_sn` contributor.

Markdown [linter](https://github.com/markdownlint/markdownlint?tab=readme-ov-file#markdown-lint-tool):

```bash
mdl -s .github/linter/readme_style.rb README.md
```

Scarb linter:

```bash
scarb fmt
```

### Additional Resources

- [Cairo Book](https://book.cairo-lang.org/)
- [Starknet Book](https://book.starknet.io/)
- [Starknet Foundry Book](https://foundry-rs.github.io/starknet-foundry/)
- [Starknet By Example](https://starknet-by-example.voyager.online/)
- [Starkli Book](https://book.starkli.rs/)
- [blockstream-sn TG](https://t.me/+N7UqCg2hxA4wNTZh)
- [Syncing a Fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork)
- [Submitting data blobs to Celestia](https://docs.celestia.org/developers/submit-data)

##

Thank you for your contribution!
