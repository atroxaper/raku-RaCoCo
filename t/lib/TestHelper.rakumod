use Test;

our $*plan is export;
our $*subtest is export;

sub test($name, \block, :$plan!) is export {
	$*subtest = $name;
	$*plan = $plan;
	subtest($*subtest, block);
}