[![Ubuntu](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/ubuntu.yml)
[![MacOS](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/macos.yml/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/macos.yml)
[![Windows](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/windows.yml/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/windows.yml)
![badge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/atroxaper/bbe5dc9c78db69d256b11c2ea562a42f/raw/racoco-ubuntu-coco.json)

# NAME

`App::RaCoCo` - Raku Code Coverage tool.

# SYNOPSIS

```bash
> racoco -l
[...]
All tests successful.
Files=16, Tests=114,  6 wallclock secs
Result: PASS
Coverage: 89.2%

> racoco --fail-level=95
[...]
Coverage: 89.2%
# exit code: 6

> racoco --html --silent
Visualisation: file://.racoco/report.html
Coverage: 89.2%
> browsername .racoco/report.html
```

# INSTALLATION

If you use zef, then `zef install App::RaCoCo`, or `pakku add App::RaCoCo` if you use Pakku.

# DESCRIPTION

`App::RaCoCo` provides the `racoco` application, which can be used to run tests and calculate code coverage.

You may specify the following options:
* **--lib** - path to directory with target source files (`'./lib'` by default);

* **--exec** - command, which needs to be executed to run tests. For example, you may pass `--exec='prove --exec raku'` to use Perl's `prove` util instead of default `prove6`. Use `--/exec` parameter to not run tests and use coverage data from the previous run;

* **-l** - short-cut for `--exec='prove6 -l t'`;

* **--raku-bin-dir** - path to directory with `raku` and `moar` binaries, which supposed to be used in the `--exec` (`$*EXECUTABLE.parent` by default);
minimum possible coverage percent for success exit (0 by default)

* **--fail-level** - integer number - if the coverage level will be less than it then `racoco` will exit with a non-zero exit code;

* **--silent** - hide test result output;

* **--append** - append the previous run result to the new one;

* **--html** - produce a simple HTML page to visualize results;

* **--color-blind** - use with --html option to make more readable colors than green/red pare;

* **--reporter** - name of a custom result reporter;

* **--properties** - pass custom properties here.

# NOTES

* RaCoCo application works only with MoarVM backended Raku compiler;
* It is common practice to not include `use lib 'lib'` line in test files. In a such case, we need to run tests with a command like `prove6 -Ilib`. RaCoCo has a special short-cun option `-l` for you, then you do not need to write `racoco --exec='prove6 -l'`;
* Unfortunately, the current Rakudo implementation may produce a little different coverage log from run to run. Probably, it is because of some runtime optimisations.

# CONFIGURATION FILE

# CUSTOM REPORTERS

# AUTHOR

Mikhail Khorkov <atroxaper@cpan.org>

Sources can be found at: [github](https://github.com/atroxaper/raku-RaCoCo). The new Issued and Pull Requests are welcome.

# COPYRIGHT AND LICENSE

Copyright 2021 Mikhail Khorkov

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.




