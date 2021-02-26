use Test;
use lib 'lib';
use Racoco::Report;

plan 8;

my $report = Report.new(
  files => (
    # covered = green + purple
    # possible = green + red
    ReportFile.new(
      file => '1/3',
      green => (1,),
      red => (3, 4, 5, 6, 7),
      purple => (2,)
    ),
    ReportFile.new(
      file => '4/3',
      green => (1,),
      red => (2, 3),
      purple => (4, 5, 6)
    )
  )
);

is $report.percent, 66.6, 'report percent ok';

my $report1 = $report.get('1/3');
is $report1.percent, 33.3, '1/3 percent ok';
is $report1.color(1), GREEN, '1/3 get green ok';
is $report1.color(2), PURPLE, '1/3 purple ok';
is $report1.color(5), RED, '1/3 red ok';

my $report2 = $report.get('4/3');
is $report2.percent, 100, '4/3 percent ok';
is $report2.file, '4/3', '4/3 file ok';

nok $report.get('not-exists'), 'not-exists ok';

done-testing