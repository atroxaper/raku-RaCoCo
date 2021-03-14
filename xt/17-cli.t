use Test;
use lib 'lib';
use lib 't/lib';
need App::Racoco::Cli;
use App::Racoco::Fixture;
use App::Racoco::Paths;
use App::Racoco::X;

plan 13;

Fixture::capture-out;
END { Fixture::restore-out }


sub do-test(&code) {
  indir(Fixture::root-folder, &code);
  Fixture::restore-root-folder();
  Fixture::get-out
}

{
  throws-like { App::Racoco::Cli::MAIN(lib => 'not-exists') }, App::Racoco::X::WrongLibPath,
    'MAIN with wrong lib ok', message => /'not-exists'/;
}

{
  throws-like { App::Racoco::Cli::MAIN(raku-bin-dir => 'not-exists') }, App::Racoco::X::WrongRakuBinDirPath,
    'MAIN with wrong raku bin dir ok', message => /'not-exists'/;
  throws-like { App::Racoco::Cli::MAIN(raku-bin-dir => 'lib') }, App::Racoco::X::WrongRakuBinDirPath,
    'MAIN with empty raku bin dir ok', message => /'lib'/;
}

do-test {
  App::Racoco::Cli::MAIN();
  is Fixture::get-out, 'Coverage: 62.5%', 'simple run ok';
};

do-test {
  App::Racoco::Cli::MAIN(lib => 'lib', raku-bin-dir => $*EXECUTABLE.parent.Str);
  is Fixture::get-out, 'Coverage: 62.5%', 'pass lib and raku-bin-dir';
};

do-test {
  App::Racoco::Cli::MAIN(exec => 'echo "foo"');
  is Fixture::get-out, 'Coverage: 0%', 'pass exec';
};

do-test {
  throws-like { App::Racoco::Cli::MAIN(exec => False) }, App::Racoco::X::CannotReadReport,
    'no report, exception', message => /'lib'/;
};

do-test {
  my $path = coverage-log-path(:lib<lib>);
  App::Racoco::Cli::MAIN();
  App::Racoco::Cli::MAIN(:!exec);
  ok $path.e, 'coverage log exist without exec';
};

do-test {
  App::Racoco::Cli::MAIN(silent => True);
  is Fixture::get-out, 'Coverage: 62.5%', 'pass silent';
};

do-test {
  App::Racoco::Cli::MAIN();
  App::Racoco::Cli::MAIN(:append, exec => 'echo "foo"');
  is Fixture::get-out, "Coverage: 62.5%\n\nCoverage: 62.5%", 'pass append';
};

do-test {
  my $path = report-html-path(:lib<lib>);
  App::Racoco::Cli::MAIN();
  nok $path.e, 'nok html';
  App::Racoco::Cli::MAIN(:html, :!exec, :append);
  ok $path.e, 'ok html';
  ok Fixture::get-out.contains(report-html-path(:lib<lib>)), 'pass html';
};

done-testing