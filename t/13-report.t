use Test;
use lib 'lib';
use App::Racoco::Report::Report;

plan 3;

sub setup(:$plan!) {
	plan $plan;
}

subtest 'report interface', {
	setup(:4plan);
	my $data1 = FileReportData.new(
    file-name => 'Zorro.rakumod',
    green => Set(1),
    red => Set(3, 4, 5, 6, 7),
    purple => Set(2),
  );
  my $data2 = FileReportData.new(
    file-name => 'Average.rakumod',
    green => Set(1),
    red => Set(2, 3),
    purple => Set(4, 5, 6)
  );
  my $report = Report.new(fileReportData => ($data1, $data2));
  is $report.percent, 66.6, 'percent';
  is $report.data(:file-name<Zorro.rakumod>), $data1, 'data';
  nok $report.data(:file-name<NotExists.rakumod>), 'not exist data';
  is $report.all-data, ($data2, $data1), 'all-data';
}

subtest 'file report data interface', {
	setup(:6plan);
	my $data = FileReportData.new(
    file-name => 'Data.rakumod',
    green => <1>>>.Int.Set,
    red => <3 4 5 6 7>>>.Int.Set,
    purple => <2>>>.Int.Set,
  );
  is $data.percent, 33.3, 'percent';
  is $data.color(:1line), GREEN, 'green';
  is $data.color(:2line), PURPLE, 'purple';
  is $data.color(:5line), RED, 'red';
  is $data.covered, 2, 'covered';
  is $data.coverable, 6, 'coverable';
}

subtest 'eqv file report data', {
	setup(:5plan);
	my &data-producer = -> :$file-name, :$green, :$red, :$purple {
    FileReportData.new(
      file-name => $file-name // 'Standard.rakumod',
      green => $green // <1>>>.Int.Set,
      red => $red // <3 4 5 6 7>>>.Int.Set,
      purple => $purple // <2>>>.Int.Set,
    )
  };
	my $expected = data-producer;
  my $same = data-producer;
  ok $same eqv $expected, 'same';
  my $diff-name = data-producer(:file-name<diff>);
  nok $diff-name eqv $expected, 'diff name';
  my $diff-green = data-producer(green => Set(9));
  nok $diff-green eqv $expected, 'diff green';
  my $diff-red = data-producer(red => Set(3));
  nok $diff-red eqv $expected, 'diff red';
  my $diff-purple = data-producer(purple => Set(9));
  nok $diff-purple eqv $expected, 'diff purple';
}

#my $report1 = $report.data(:file-name<1/3>);
#is $report1.percent, 33.3, '1/3 percent ok';
#is $report1.color(:1line), GREEN, '1/3 get green ok';
#is $report1.color(:2line), PURPLE, '1/3 purple ok';
#is $report1.color(:5line), RED, '1/3 red ok';
#
#my $report2 = $report.data(:file-name<4/3>);
#is $report2.percent, 100, '4/3 percent ok';
#is $report2.file-name, '4/3', '4/3 file ok';
#
#nok $report.data(:file-name<not-exists>), 'not-exists ok';
#
#is $report.all-data.elems, 2, 'all data elems ok';

#todo add test for eqv

done-testing