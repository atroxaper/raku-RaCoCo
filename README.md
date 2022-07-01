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

* **--exec** - command, which needs to be executed to run tests. For example, you may pass `--exec='prove --exec raku'` to use Perl's `prove` util instead of default `prove6`. Use `--/exec` option to not run tests and use coverage data from the previous run;

* **-l** - short-cut for `--exec='prove6 -l'`;

* **-I** - short-cut for `--exec='prove6 -I.'`;

* **--lib** - path to directory with target source files (`'./lib'` by default);

* **--raku-bin-dir** - path to directory with `raku` and `moar` binaries, which supposed to be used in the `--exec` (`$*EXECUTABLE.parent` by default);

* **--fail-level** - integer number - if the coverage level will be less than it then `racoco` will exit with a non-zero exit code;

* **--silent** - hide test result output;

* **--append** - append the previous run result to the new one;

* **--html** - produce a simple HTML page to visualize results. It is short-cut for `--reporter=html`;

* **--color-blind** - use with `--html` option to make more readable colors than green/red pare. It is short-cut for `--reporter=html-color-blind`;

* **--reporter** - name of a custom result reporter;

* **--properties** - pass custom properties here;

* **configuration-name** - name of section with properties in `racoco.ini` to use in tests (see below [CONFIGURATION FILE](#configuration-file))


# NOTES

* RaCoCo application works only with MoarVM backended Raku compiler;
* It is common practice to not include `use lib 'lib'` line in test files. In a such case, we need to run tests with a command like `prove6 -l`. RaCoCo has a special short-cut option `-l` for you, then you do not need to write `racoco --exec='prove6 -l'`;
* Unfortunately, the current Rakudo implementation may produce a little different coverage log from run to run. Probably, it is because of some runtime optimisations.

# CONFIGURATION FILE

Tests are a thing that it is customary to run frequently. If you run tests with a command more complicated than just `rococo -l`, then you will like the fact that you can write all the configurations to a special `racoco.ini` file. For example, you regularly run `rococo -l` and `racoco -l --silent --html --fail-level=82` before commit. Then you can create a `rococo.ini` file in the root directory of your project with the following content:

```ini
exec = prove6 -l

[commit]
silent = true
reporter = html
fail-level = 82
```

After that just run `racoco` regularly and `racoco commit` before commit. As an alternative for configuration file you can use environment variables with appropriate names, or `--property=name:value;name:value` command-line option, or a combination of them. The priority is: command-line arguments > `--property` option > environment variables > `racoco.ini` file.

# CUSTOM REPORTERS

In addition to the output of results to the console, Rococo supports additional reporters with the `--reporter` option. Examples of such reporters are `html` or `html-color-blind` which build a simple HTML page with results. Please look for other reporters in the [Ecosystem](https://raku.land/?q=racoco).

## Information for Developers

A custom reporter must implement `App::Racoco::Report::Reporter` role, has full qualified name like `App::Racoco::Report::ReporterTheName` and live in `App::Racoco::Report::ReporterTheName` compilation unit (file). Then you can address to it through `--reporter=the-name`. For example, see `ReportHtmlColorBlind.rakumod`.

# AUTHOR

Mikhail Khorkov <atroxaper[at]cpan.org>

Sources can be found at: [github](https://github.com/atroxaper/raku-RaCoCo). The new Issues and Pull Requests are welcome.

# COPYRIGHT AND LICENSE

Copyright 2021 Mikhail Khorkov

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.




