use Test;

sub test($name, \block, :$plan!) is export {
	$*subtest = $name;
	$*plan = $plan;
	subtest($*subtest, block);
}