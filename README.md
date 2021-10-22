[![Ubuntu](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/ubuntu.yml)
[![MacOS](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/macos.yml/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/macos.yml)
[![Windows](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/windows.yml/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/windows.yml)
![badge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/atroxaper/bbe5dc9c78db69d256b11c2ea562a42f/raw/racoco-ubuntu-coco.json)

# NAME

`App::RaCoCo` - Raku Code Coverage tool.

# SYNOPSIS

```bash
> racoco
[...]
All tests successful.
Files=16, Tests=114,  6 wallclock secs
Result: PASS
Coverage: 89.2%

> racoco --html --silent
Visualisation: file://.racoco/report.html
Coverage: 89.2%
> browsername .racoco/report.html

> racoco --exec='prove6 -Ilib' --fail-level=95 --silent
Coverage: 89.2%
# exit code: 6

> racoco
[...]
===SORRY!===
Library path ｢lib/.precomp｣ has ambiguous .precomp directory with more than one
CompUnit Repository. Please, make sure you have only the one directory in
the <library>/.precomp path or use --fix-compunit flag for the next RaCoCo launch
to erase .precomp directory automatically.
> racoco --fix-compunit
[...]
Coverage: 89.2%
```

# INSTALLATION

If you use zef, then `zef install App::RaCoCo`, or `pakku add App::RaCoCo` if you use Pakku.

# DESCRIPTION

`App::RaCoCo` provides the `racoco` application, which can be used to run tests and calculate code coverage.

You may specify the following parameters:
* **--lib** - path to directory with target source files (`'./lib'` by default);
* **--raku-bin-dir** - path to directory with raku and moar binaries (`$*EXECUTABLE.parent` by default);
* **--exec** - command, which need to be executed to run tests. For example, you may pass `'prove --exec raku'` to the `exec` parameter to say `prove` to manage your tests, or use `--/exec` parameter to not run tests and use coverage data from the previous run (`prove6` by default);
* **--fail-level** - integer number - if coverage will be less than it then `racoco` will exit with non-zero exitcode;
* **--silent** - hide test result output;
* **--append** - do not clean coverage data before this `racoco` run and append its result to the previous one;
* **--html** - produce simple html page to visualize results;
* **--color-blind** - addition to `--html` parameter - use more readable colors than green/red pare;
* **--fix-compunit** - erase `<library>/.precomp` directory before run tests. See [details below](#common-difficult-cases).

# COMMON DIFFICULT CASES

* It is common practise to not include `use lib 'lib'` line in test files. In such case we need to run tests with command like `prove6 -Ilib`. As RaCoCo uses just `prove6` command by default, then we will need to run it like `racoco --exec='prove6 -Ilib'`.
* If `<library>/.precomp` directory has more than one directory with compiled sources, then RaCoCo cannot be sure which one need to be analysed. The situation arises, for example, after updating raku compiler. You need to clean `.precomp` directory or delete only the old directories inside. Alternatively, you can run RaCoCo with `--fix-compunit` flag ones to erase `.precomp` directory automatically.

# NOTE

RaCoCo application works only with MoarVM backended Raku compiler.

# AUTHOR

Mikhail Khorkov <atroxaper@cpan.org>

Source can be located at: [github](https://github.com/atroxaper/raku-RaCoCo). Comments and Pull Requests are welcome.

# COPYRIGHT AND LICENSE

Copyright 2021 Mikhail Khorkov

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.




