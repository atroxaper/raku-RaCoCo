use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Report::Report;
use Racoco::Report::ReporterBasic;
use Racoco::Paths;
use Racoco::TmpDir;

plan 2;

my ($sources, $lib) = create-tmp-lib('racoco-test');
my $racoco = racoco-path(:$lib);
my $report-path = report-basic-path(:$lib);

my %coverable-lines = %{
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

my $report-content = q:to/END/.trim;
  54.5%
  AllGreen
  100%
  green 1 3 5
  red
  purple
  AllRed
  0%
  green
  red 2 4 6
  purple
  Empty
  100%
  green
  red
  purple
  GreenRed
  50%
  green 7
  red 8
  purple
  WithPurple
  66.6%
  green 1
  red 2 4
  purple 3
  END

my $report = Report.new(files => (
  FileReportData.new(:file-name<AllGreen>, green => (1, 3, 5), red => (), purple => ()),
  FileReportData.new(:file-name<AllRed>, green => (), red => (2, 4, 6), purple => ()),
  FileReportData.new(:file-name<GreenRed>, green => 7, red => 8, purple => ()),
  FileReportData.new(:file-name<WithPurple>, green => 1, red => (2, 4), purple => 3),
  FileReportData.new(:file-name<Empty>, green => (), red => (), purple => ()),
));

{
  my $reporter = ReporterBasic.make-from-data(:%coverable-lines, :%covered-lines);
  my $path = $reporter.write(:$lib);
  is $path, $report-path, 'correct report path';
  is $report-path.slurp, $report-content, 'write base report ok';
}

done-testing