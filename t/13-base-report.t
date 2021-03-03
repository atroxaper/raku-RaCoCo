use Test;
use lib 'lib';
use Racoco::Report;
use Racoco::Paths;
use lib 't/lib';
use Racoco::TmpDir;

plan 3;

my ($sources, $lib) = create-tmp-lib('racoco-test');
my $racoco = racoco-path(:$lib);
my $report-path = report-txt-path(:$lib);

my %possible-lines = %{
  'AllGreen' => (1, 3, 5).Set,
  'AllRed' => (2, 4, 6).Set,
  'GreenRed' => (7, 8),
  'WithPurple' => (1, 2, 4).Set,
  'Empty' => ().Set
}

my %covered-lines = %{
  'AllGreen' => (1, 3, 5).Set,
  'GreenRed' => (7),
  'WithPurple' => (1, 3).Set,
}

my $report-content = q:to/END/;
  63.3%
  AllGreen
  100%
  green 1 3 5
  AllRed
  0%
  red 2 4 6
  Empty
  100%
  GreenRed
  50%
  green 7
  red 8
  WithPurple
  66.6%
  green 1
  red 2 4
  purple 3
  END

my $report = Report.new(files => (
  ReportFile.new(:file<AllGreen>, green => (1, 3, 5), red => (), purple => ()),
  ReportFile.new(:file<AllRed>, green => (), red => (2, 4, 6), purple => ()),
  ReportFile.new(:file<GreenRed>, green => 7, red => 8, purple => ()),
  ReportFile.new(:file<WithPurple>, green => 1, red => (2, 4), purple => 3),
  ReportFile.new(:file<Empty>, green => (), red => (), purple => ()),
));


{
  my $reporter = BaseReporter.from-data(:%possible-lines, :%covered-lines);
  $lib.rmdir;
  my $path = $reporter.write(:$lib);
  nok $path, 'lib not exists';
  $lib.mkdir;
}

{
  my $reporter = BaseReporter.from-data(:%possible-lines, :%covered-lines);
  my $path = $reporter.write(:$lib);
  is $path, $report-path, 'correct report path';
  is $report-path.slurp, $report-content, 'write base report ok';
}

done-testing