use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Report::Report;
use App::Racoco::Report::ReporterBasic;
use App::Racoco::Paths;
use TestResources;

plan 4;

my ($lib, $subtest);
sub setup($lib-name, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
}

$subtest = '01-read-from-file';
subtest $subtest, {
	setup('lib', :$subtest, :1plan);
  my $reporter = ReporterBasic.read(:$lib);
	my $expect = Report.new(fileReportData => (
		FileReportData.new(:file-name<AllGreen>, green => (1, 3, 5), red => (), purple => ()),
		FileReportData.new(:file-name<AllRed>, green => (), red => (2, 4, 6), purple => ()),
		FileReportData.new(:file-name<GreenRed>, green => 7, red => 8, purple => ()),
		FileReportData.new(:file-name<WithPurple>, green => 1, red => (2, 4), purple => 3),
		FileReportData.new(:file-name<Empty>, green => (), red => (), purple => ()),
	));
  ok $reporter.report eqv $expect, 'read correct data';
}

$subtest = '02-make-from-data';
subtest $subtest, {
	setup('lib', :$subtest, :1plan);
	my $expected = ReporterBasic.read(:$lib).report;
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
	my $reporter = ReporterBasic.make-from-data(:%coverable-lines, :%covered-lines);
	ok $reporter.report eqv $expected, 'make correct data';
}

$subtest = '03-write-report';
subtest $subtest, {
	setup('lib', :$subtest, :3plan);
	my $reporter = ReporterBasic.read(:$lib);
	my $expected-path = report-basic-path(:$lib);
	my $expected = $expected-path.slurp;
	$expected-path.unlink;
	my $actual-path = $reporter.write(:$lib);
	ok $actual-path.e, 'report file exists';
	is $actual-path, $expected-path, 'report file path valid';
	is $actual-path.slurp, $expected, 'report file valid';
}

$subtest = '04-missing-report-file';
subtest $subtest, {
	setup('lib', :$subtest, :1plan);
	throws-like { ReporterBasic.read(:$lib) }, App::Racoco::X::CannotReadReport,
		'no report file, no reporter', message => / $lib /;
}

done-testing