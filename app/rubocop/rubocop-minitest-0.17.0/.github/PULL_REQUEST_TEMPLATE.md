**Replace this text with a summary of the changes in your PR.
The more detailed you are, the better.**

-----------------

Before submitting the PR make sure the following are checked:

* [ ] Wrote [good commit messages][1].
* [ ] Commit message starts with `[Fix #issue-number]` (if the related issue exists).
* [ ] Feature branch is up-to-date with `master` (if not - rebase it).
* [ ] Squashed related commits together.
* [ ] Added tests.
* [ ] Added an entry (file) to the [changelog folder](https://github.com/rubocop/rubocop-minitest/blob/master/changelog/) named `{change_type}_{change_description}.md` if the new code introduces user-observable changes. See [changelog entry format](https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format) for details.
* [ ] The PR relates to *only* one subject with a clear title
  and description in grammatically correct, complete sentences.
* [ ] Run `bundle exec rake default`. It executes all tests and RuboCop for itself, and generates the documentation.

[1]: https://chris.beams.io/posts/git-commit/
