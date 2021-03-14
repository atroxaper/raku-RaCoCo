use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Report::Report;
use App::Racoco::Report::ReporterHtml;
use App::Racoco::ModuleNames;
use App::Racoco::Paths;
use App::Racoco::TmpDir;
use App::Racoco::Fixture;

plan 42;

my $lib = Fixture::root-folder.add('lib-for-report');
my $mod = 'RootModule.rakumod';
my $mod1 = 'RootModule'.IO.add('SubModule1.rakumod').Str;
my $mod2 = 'RootModule'.IO.add('SubModule2.rakumod').Str;

my %coverable-lines = %{
  $mod => (1, 2, 3, 4).Set,
  $mod1 => (1, 2, 3, 4).Set,
  $mod2 => (1, 2).Set,
}

my %covered-lines = %{
  $mod => (1, 2, 3, 4).Set,
  $mod1 => (1, 2).Set,
  $mod2 => (3, 4).Set,
}

my $report-expect = Report.new(fileReportData => (
  FileReportData.new(:file-name($mod), green => (1, 2, 3, 4), red => (), purple => ()),
  FileReportData.new(:file-name($mod1), green => (1, 2), red => (3, 4), purple => ()),
  FileReportData.new(:file-name($mod2), green => (), red => (1, 2), purple => (3, 4)),
));

sub check-page($file-name, $page-name) {
  my $data = $report-expect.data(:$file-name);
  my $page = (report-html-data-path(:$lib).add($page-name) ~ '.html').IO;
  ok $page.e, $page-name ~ ' exists';
  my $content = $page.slurp;
  for 1..4 -> $line {
    my $color = ($data.color(:$line).key // 'no').lc;
    ok $content ~~ /"<span class=\"coverage-$color\">line$line\</span>"/,
       "$page-name line$line ok";
  }

  nok $content ~~ /'%%'/, $page-name ~ ' has no placeholders';
}

sub check-main-page($content, $file-name, $page-name) {
  my $data = $report-expect.data(:$file-name);
  my $module-name = module-name(path => $file-name);
  my $link = $page-name ~ '.html';
  my $line = $content.lines.grep(* ~~ /$module-name/).first;
  ok $line, 'line with ' ~ $module-name ~ ' exists';
  ok $line ~~ /{$data.percent}/, $module-name ~ ' percent ok';
  ok $line ~~ /{$data.coverable}/, $module-name ~ ' coverable ok';
  ok $line ~~ /{$data.covered}/, $module-name ~ ' covered ok';
  ok $line ~~ /"href=\"./report-data/$link\""/, $module-name ~ ' link ok';
}

Fixture::need-restore-root-folder();
sub do-test(&code) {
  indir(Fixture::root-folder, &code)
}

do-test {
  my $reporter = ReporterHtml.make-from-data(:%coverable-lines, :%covered-lines);
  ok $reporter.report eqv $report-expect, 'make correct data';
  $reporter.write(:$lib);
  ok report-basic-path(:$lib).e, 'basic report exists';
  my $read-reporter = ReporterHtml.read(:$lib);
  ok $read-reporter.report eqv $report-expect, 'read correct data';
  App::Racoco::TmpDir::rmdir(report-html-data-path(:$lib));
};

do-test {
  my $reporter = ReporterHtml.make-from-data(:%coverable-lines, :%covered-lines);
  my $wrote-page = $reporter.write(:$lib);

  is report-html-data-path(:$lib).dir.elems, 3, 'data dir with pages';
  check-page($mod, 'RootModule');
  check-page($mod1, 'RootModule-SubModule1');
  check-page($mod2, 'RootModule-SubModule2');
  my $with-esc = report-html-data-path(:$lib).add('RootModule.html').slurp;
  ok $with-esc ~~ /'&quot;&amp;&lt;&gt;'/, 'escape ok';

  ok report-html-path(:$lib).e, 'html report exists';
  is $wrote-page, report-html-path(:$lib), 'html report path ok';
  my $main-content = $wrote-page.slurp;

  check-main-page($main-content, $mod, 'RootModule');
  check-main-page($main-content, $mod1, 'RootModule-SubModule1');
  check-main-page($main-content, $mod2, 'RootModule-SubModule2');
  nok $main-content ~~ /'%%'/, 'main page has no placeholders';
};

do-test {
  my ($, $lib) = create-tmp-lib('racoco-test-not-exists-report');
  throws-like { ReporterHtml.read(:$lib) }, App::Racoco::X::CannotReadReport,
    'no report, exception', message => /'lib'/;
};

done-testing
