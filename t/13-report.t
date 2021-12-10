use Test;
use lib 'lib';
use App::Racoco::Report::Report;

plan 4;

sub setup(:$plan!) {
	plan $plan;
}

sub data-producer(:$file-name, :$green, :$red, :$purple) {
  FileReportData.new(
    file-name => $file-name // 'Standard.rakumod',
    green => $green // Set(1),
    red => $red // Set(3, 4, 5, 6, 7),
    purple => $purple // Set(2),
  )
}

subtest 'report interface', {
	setup(:4plan);
	my $data1 = data-producer(:file-name<Zorro.rakumod>);
  my $data2 = data-producer(
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

subtest 'eqv report', {
	setup(:3plan);
  my $expected = Report.new(fileReportData =>
    (data-producer(:file-name<first>), data-producer(:red(Set()))));
  my $same = Report.new(fileReportData =>
    (data-producer(:file-name<first>), data-producer(:red(Set()))));
  ok $same eqv $expected, 'same';

  my $diff-elems = Report.new(fileReportData =>
    (data-producer(:file-name<first>),));
  nok $diff-elems eqv $expected, 'diff elems';

  my $diff-elem = Report.new(fileReportData =>
    (data-producer(:file-name<first>), data-producer(:red(Set(3)))));
  nok $diff-elem eqv $expected, 'diff elem';
}

done-testing