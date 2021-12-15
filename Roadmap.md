For v1.5.0


* Add `-l` option as shortcut for `--exec='prove6 -Ilib t'`;
* Remove `--fix-compunit` behaviour.
* Do --append through report.txt instead of coverage.log
* Do not store our precomp information in the index
* ~~Fix sha calculation~~
* ~~Add possibility to write own reporter as a plugin.~~
* ~~Add line hit count into the report~~
* ~~Make tests (in `t` and `xt`) great again;~~

Backlog:
* Convert project from a tool to tool&library. Make it possible to calculate a coverage from the Raku code.
* Centrally check lib (and other paths) to be absolute.
* Add :create adverb to all Paths subs.
* Move Precomp package to Coverable.
