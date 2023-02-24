unit class App::RacocoTest is export;

submethod TWEAK(:$config, :$root) {
	$*config = $config;
	$*root = $root;
}

method calculate-coverage(::?CLASS:D: --> App::RacocoTest:D) {
	$*racoco-stages.push: 'calculate';
	self
}

method do-report(::?CLASS:D: --> App::RacocoTest:D) {
	$*racoco-stages.push: 'report';
	self
}

method how-below-fail-level(::?CLASS:D: --> Int:D) {
	$*racoco-stages.push: 'fail-level';
	0
}