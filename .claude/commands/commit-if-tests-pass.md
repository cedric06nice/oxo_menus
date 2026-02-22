Follow these steps:

- Run `dart format .`
- Reformat if necessary
- Run `flutter analyze --fatal-infos`
- Repair the errors if possible or stop if not
- Tests must have 75%+ coverage `flutter test --coverage`
- Make sure all the tests are passing and stop if not
- Stash and commit all the latest changes with a short and clear commit
- Include to the commit message the coverage percentage
- Never sign or mention claude in any commit message
