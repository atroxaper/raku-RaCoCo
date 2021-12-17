use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Fixture;
use App::Racoco::Paths;
use App::Racoco::Coverable::Precomp::PrecompHashcodeReader;
use TestResources;

plan 1;

my ($lib, $reader, $subtest);
sub setup($lib-name, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
	$reader = PrecompHashcodeReaderReal.new;
}

$subtest = '01-read-hash-code';
subtest $subtest, {
	setup('lib', :$subtest, :1plan);
	my $expected = '266B9F83542BC85F73639D2D300D0701AF14F9E5';
	my $path = $lib.parent.add('precompiled');
	is $reader.read(:$path), $expected, 'hashcode ok';
}

done-testing