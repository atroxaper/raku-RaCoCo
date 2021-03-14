[![Build Status](https://github.com/atroxaper/raku-RaCoCo/workflows/Ubuntu/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/ubuntu.yml)
[![Build Status](https://github.com/atroxaper/raku-RaCoCo/workflows/Windows/badge.svg)](https://github.com/atroxaper/raku-RaCoCo/actions/workflows/windows.yml)
# NAME

`App::RaCoCo` - Raku Code Coverage tool and library.

# SYNOPSIS

```bash
> racoco
[...]
All tests successful.
Files=16, Tests=114,  6 wallclock secs
Result: PASS
Coverage: 89.2%

> racoco --html --silent
Coverage: 89.2%
> browsername .racoco/report.html
```

# DESCRIPTION

`App::RaCoCo` provides the `racoco` application, which can be used to run tests and calculate code coverage.

You may specify the following parameters:
* **--lib** - path to directory with coverable source files (`'./lib'` by default);
* **--raku-bin-dir** - path to directory with raku and moar binaries (`$*EXECUTABLE.parent` by default);
* **--exec** - command, which need to be executed to run tests. For example, you may pass `'prove --exec raku'` to the `exec` parameter to say `prove` to manage your tests, or use `--/exec` parameter to not run tests and use coverage data from the previous run (`prove6` by default);
* **--fail-level** - integer number - if coverage will be less than it then `racoco` will exit with non-zero exitcode;
* **--silent** - hide test result output;
* **--append** - do not clean coverage data before this `racoco` run and append its result to the previous one;
* **--html** - produce simple html page to visualize results;
* **--color-blind** - addition to `--html` parameter - use more readable colors than green/red pare. 

# NOTE

RaCoCo application works only with MoarVM backended Raku compiler.

# AUTHOR

Mikhail Khorkov <atroxaper@cpan.org>

Source can be located at: [github](https://github.com/atroxaper/raku-RaCoCo). Comments and Pull Requests are welcome.

# COPYRIGHT AND LICENSE

Copyright 2021 Mikhail Khorkov

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
