For v1.5.0
* Make tests (in `t` and `xt`) great again;
* ~~Delete OurPrecompLocation related logic at all. It is wrong logic.~~
* Add `-l` option as shortcut for `--exec='prove6 -Ilib t'`;
* Improve `--fix-compunit(--fix)` to leave precomp for the current raku version
* Add `--clear-precomp` to do previous `--fix-compunit` behaviour
* Add line hit count into the report 
* Add possibility to write own reporter as a plugin.

For future:
* Convert project from a tool to tool&library. Make it possible to calculate a coverage from the Raku code.
