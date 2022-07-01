use Test;

our $*plan is export;
our $*subtest is export;
our $*wo-resources is export;

sub test($name, \block, :$plan!, :$wo-resources = False) is export {
	$*subtest = $name;
	$*plan = $plan;
	$*wo-resources = $wo-resources;
	subtest($*subtest, block);
}