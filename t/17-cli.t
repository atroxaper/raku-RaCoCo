use Test;
use lib 'lib';
use lib 't/lib';
need Racoco::Cli;
use Racoco::Fixture;
use Racoco::Paths;
use Racoco::X;

plan 13;

Fixture::capture-out;
END { Fixture::restore-out }


sub do-test(&code) {
  indir(Fixture::root-folder, &code);
  Fixture::restore-root-folder();
}

{
  throws-like { Racoco::Cli::MAIN(lib => 'not-exists') }, Racoco::X::WrongLibPath,
    'MAIN with wrong lib ok', message => /'not-exists'/;
}

{
  throws-like { Racoco::Cli::MAIN(raku-bin-dir => 'not-exists') }, Racoco::X::WrongRakuBinDirPath,
    'MAIN with wrong raku bin dir ok', message => /'not-exists'/;
  throws-like { Racoco::Cli::MAIN(raku-bin-dir => 'lib') }, Racoco::X::WrongRakuBinDirPath,
    'MAIN with empty raku bin dir ok', message => /'lib'/;
}

do-test {
  Racoco::Cli::MAIN();
  is Fixture::get-out, 'Coverage: 62.5%', 'simple run ok';
};

do-test {
  Racoco::Cli::MAIN(lib => 'lib', raku-bin-dir => $*EXECUTABLE.parent.Str);
  is Fixture::get-out, 'Coverage: 62.5%', 'pass lib and raku-bin-dir';
};

do-test {
  Racoco::Cli::MAIN(exec => 'echo "foo"');
  is Fixture::get-out, 'Coverage: 0%', 'pass exec';
};

do-test {
  Racoco::Cli::MAIN(exec => False);
  is Fixture::get-out, 'Coverage: 0%', 'pass not exec';
};

do-test {
  my $path = coverage-log-path(:lib<lib>);
  Racoco::Cli::MAIN();
  Racoco::Cli::MAIN(:!exec);
  ok $path.e, 'coverage log exist without exec';
  Fixture::get-out
};

do-test {
  Racoco::Cli::MAIN(silent => True);
  is Fixture::get-out, 'Coverage: 62.5%', 'pass silent';
};

do-test {
  Racoco::Cli::MAIN();
  Racoco::Cli::MAIN(:append, exec => 'echo "foo"');
  is Fixture::get-out, "Coverage: 62.5%\n\nCoverage: 62.5%", 'pass append';
};

do-test {
  my $path = report-html-path(:lib<lib>);
  Racoco::Cli::MAIN();
  nok $path.e, 'nok html';
  Racoco::Cli::MAIN(:html, :!exec, :append);
  ok $path.e, 'ok html';
  is Fixture::get-out, "Coverage: 62.5%\n\nCoverage: 62.5%", 'pass html';
};

done-testing