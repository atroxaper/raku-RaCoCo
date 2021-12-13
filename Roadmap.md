For v1.5.0


* Add `-l` option as shortcut for `--exec='prove6 -Ilib t'`;
* Improve `--fix-compunit(--fix)` to leave precomp for the current raku version
* Add `--clear-precomp` to do previous `--fix-compunit` behaviour
* Add possibility to write own reporter as a plugin.
* ~~Add line hit count into the report~~
* ~~Make tests (in `t` and `xt`) great again;~~

Backlog:
* Convert project from a tool to tool&library. Make it possible to calculate a coverage from the Raku code.
* Centrally check lib (and other paths) to be absolute.
* Add :create adverb to all Paths subs.
* Move Precomp package to Coverable.
