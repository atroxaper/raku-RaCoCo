use Test;
use lib 'lib';
use lib 't/lib';
need Racoco::Cli;
use Racoco::Fixture;
use Racoco::X;

plan 4;

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
  my $o = Fixture::get-out;
  is $o, 'Coverage: 62.5%', 'simple run ok';
};

done-testing