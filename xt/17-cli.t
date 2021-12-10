use Test;
use lib 'lib';
use lib 't/lib';
need App::Racoco::Cli;
use App::Racoco::Fixture;
use App::Racoco::Paths;
use App::Racoco::X;
use TestResources;
use TestHelper;

plan 11;

constant &APP_MAIN = &App::Racoco::Cli::MAIN;
my ($sources, $lib, $*subtest, $*plan);
sub setup($lib-name) {
	plan $*plan;
	TestResources::prepare($*subtest);
	$sources = TestResources::exam-directory;
	$lib = $sources.add($lib-name);
}

sub do-main(&bloc) {
  Fixture::silently({ indir($sources, &bloc) });
}

'01-lib-not-exists'.&test(:1plan, {
  setup('lib');
  do-main({
    throws-like { APP_MAIN(lib => 'not-exists') }, App::Racoco::X::WrongLibPath,
      'MAIN with wrong lib ok', message => /'not-exists'/;
  });
});

'02-wrong-raku-bin-dir'.&test(:2plan, {
  setup('lib');
  do-main({
  	throws-like { APP_MAIN(raku-bin-dir => 'not-exists') },
  		App::Racoco::X::WrongRakuBinDirPath,
    	'MAIN with wrong raku bin dir ok', message => /'not-exists'/;
  	throws-like { APP_MAIN(raku-bin-dir => 'lib') },
  		App::Racoco::X::WrongRakuBinDirPath,
    	'MAIN with empty raku bin dir ok', message => /'lib'/;
  });
});

'03-lib-with-no-precomp-lives-ok'.&test(:1plan, {
  setup('lib');
  do-main({
  	lives-ok { APP_MAIN(lib => 'no-precomp', :silent) }, 'lives with no precomp';
  });
});


'04-lib-with-no-precomp-lives-ok-with-fix-compunit'.&test(:1plan, {
  setup('lib');
  do-main({
  	lives-ok { APP_MAIN(lib => 'no-precomp', :fix-compunit, :silent) },
			'lives with no precomp fix-compunit';
  });
});

'05-simple-run'.&test(:1plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:silent);
  });
  is $captured.out.text.trim, 'Coverage: 75%', 'simple run ok';
});

'06-with-raku-bin-dir'.&test(:1plan, {
  setup('lib');
  my $captured = do-main({
		APP_MAIN(lib => 'lib', raku-bin-dir => $*EXECUTABLE.parent.Str, :silent);
  });
  is $captured.out.text.trim, 'Coverage: 75%', 'pass lib and raku-bin-dir';
});

'07-pass-exec'.&test(:1plan, {
  setup('lib');
  my $captured = do-main({
		APP_MAIN(exec => 'echo "foo"', :silent);
  });
  is $captured.out.text.trim, 'Coverage: 0%', 'pass exec';
});

'08-no-exec-and-no-report-fail'.&test(:1plan, {
  setup('lib');
  do-main({
		throws-like { APP_MAIN(:!exec) }, App::Racoco::X::CannotReadReport,
			'no report, exception', message => /'lib'/;
  });
});

'09-append'.&test(:1plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:silent);
  	APP_MAIN(:append, exec => 'echo "foo"', :silent);
  });
  is $captured.out.text.trim, "Coverage: 75%{$?NL}Coverage: 75%", 'pass append';
});

'10-pass-html'.&test(:2plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:html, :silent);
  });
  ok report-html-path(:$lib).e, 'ok html';
  ok $captured.out.text.contains(report-html-path(:$lib)), 'pass html';
});

'11-fix-compunit'.&test(:1plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:fix-compunit, :silent);
  });
  is $captured.out.text.trim, 'Coverage: 100%', 'two precomp with fix-compunit';
});

done-testing