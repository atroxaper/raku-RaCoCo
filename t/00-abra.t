use Test;
use lib 't/lib';
use TestResources;

my $subtest;
sub setup($subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
}

$subtest = 'subsub';
subtest $subtest, {
	setup($subtest, :1plan);
}