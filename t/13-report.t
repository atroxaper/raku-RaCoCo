use Test;
use lib 'lib';
use App::Racoco::Report::Report;

plan 9;

my $report = Report.new(
  fileReportData => (
    FileReportData.new(
      file-name => '1/3',
      green => (1,).Set,
      red => (3, 4, 5, 6, 7).Set,
      purple => (2,).Set
    ),
    FileReportData.new(
      file-name => '4/3',
      green => (1,).Set,
      red => (2, 3).Set,
      purple => (4, 5, 6).Set
    )
  )
);

is $report.percent, 66.6, 'report percent ok';

my $report1 = $report.data(:file-name<1/3>);
is $report1.percent, 33.3, '1/3 percent ok';
is $report1.color(:1line), GREEN, '1/3 get green ok';
is $report1.color(:2line), PURPLE, '1/3 purple ok';
is $report1.color(:5line), RED, '1/3 red ok';

my $report2 = $report.data(:file-name<4/3>);
is $report2.percent, 100, '4/3 percent ok';
is $report2.file-name, '4/3', '4/3 file ok';

nok $report.data(:file-name<not-exists>), 'not-exists ok';

is $report.all-data.elems, 2, 'all data elems ok';

done-testing