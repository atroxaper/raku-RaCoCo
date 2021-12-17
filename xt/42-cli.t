use Test;
use lib 'lib';
use lib 't/lib';
need App::Racoco::Cli;
use App::Racoco::Fixture;
use App::Racoco::Paths;
use App::Racoco::X;
use TestResources;
use TestHelper;

plan 14;

constant &APP_MAIN = &App::Racoco::Cli::MAIN;
my ($sources, $lib);
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

'04-simple-run'.&test(:2plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:silent);
  });
  is $captured.out.text.trim, 'Coverage: 75%', 'simple run ok';
  nok coverage-log-path(:$lib).e, 'coverage.log deleted';
});

'05-with-raku-bin-dir'.&test(:1plan, {
  setup('lib');
  my $captured = do-main({
		APP_MAIN(lib => 'lib', raku-bin-dir => $*EXECUTABLE.parent.Str, :silent);
  });
  is $captured.out.text.trim, 'Coverage: 75%', 'pass lib and raku-bin-dir';
});

'06-pass-exec'.&test(:1plan, {
  setup('lib');
  my $captured = do-main({
		APP_MAIN(exec => 'echo "foo"', :silent);
  });
  is $captured.out.text.trim, 'Coverage: 0%', 'pass exec';
});

'07-no-exec-and-no-report-fail'.&test(:1plan, {
  setup('lib');
  do-main({
		throws-like { APP_MAIN(:!exec) }, App::Racoco::X::CannotReadReport,
			'no report, exception', message => /'lib'/;
  });
});

'08-append'.&test(:2plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:silent);
  	APP_MAIN(:append, exec => 'prove6 xt', :silent);
  });
  is $captured.out.text.lines.join, "Coverage: 25%Coverage: 75%", 'pass append';
  nok coverage-log-path(:$lib).e, 'coverage.log deleted';
});

'09-two-precomp-fail'.&test(:1plan, {
  setup('lib');
  do-main({ lives-ok { APP_MAIN(:silent) }, 'works with two precomp' });
});

'10-custom-reporter'.&test(:1plan, {
	setup('lib');
	my $captured = do-main({ APP_MAIN(:silent, reporter => 'custom-one') });
	is $captured.out.text.trim.lines.join('|'), 'Coverage: 75%|CustomOne: 75%',
		'custom-one reporter';
});

'11-two-custom-reporters'.&test(:1plan, {
	setup('lib');
	my $captured = do-main({ APP_MAIN(:silent, reporter => 'custom-one,two') });
	is $captured.out.text.trim.lines.join('|'), 'Coverage: 75%|CustomOne: 75%|Done',
		'two custom reporters';
});

'12-not-exists-reporter'.&test(:2plan, {
	setup('lib');
	my $captured = do-main({ APP_MAIN(:silent, reporter => 'not-exists,two') });
	is $captured.err.text.trim, 'Cannot use App::Racoco::Report::ReporterNotExists package as reporter.',
		'second reporter works';
	is $captured.out.text.trim.lines.join('|'), 'Coverage: 75%|Done',
		'not-exist-reporter';
});

'13-pass-html'.&test(:3plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:reporter<html>, :silent);
  });
  ok report-html-path(:$lib).e, 'ok html';
  ok $captured.out.text.contains(report-html-path(:$lib)), 'pass html';
  ok report-html-data-path(:$lib).dir()[0].slurp ~~ /'color-blind'/, 'no color-blind';
});

'14-pass-html-color-blind'.&test(:3plan, {
  setup('lib');
  my $captured = do-main({
  	APP_MAIN(:reporter<html-color-blind>, :silent);
  });
  ok report-html-path(:$lib).e, 'ok html';
	ok $captured.out.text.contains(report-html-path(:$lib)), 'pass html';
	nok report-html-data-path(:$lib).dir()[0].slurp ~~ /'color-blind'/, 'color-blind';
});

done-testing