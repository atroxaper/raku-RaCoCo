unit module Racoco::Paths;

constant \DOT-RACOCO  is export = '.racoco';
constant \DOT-PRECOMP is export = '.precomp';
constant \OUR-PRECOMP is export = '.precomp';

constant \INDEX is export = 'index';
constant \COVERAGE-LOG is export = 'coverage.log';

constant \REPORT-TXT is export = 'report.txt';
constant \REPORT-MODULES is export = 'report-modules';
constant \REPORT-HTML is export = 'report.html';

sub absolute($path) {
	$path.is-absolute ?? $path !! $path.absolute.IO
}

our sub racoco-path(:$lib --> IO::Path:D) is export {
	mkdir absolute($lib).parent.add(DOT-RACOCO)
}

our sub our-precomp-path(:$lib --> IO::Path:D) is export {
	mkdir racoco-path(:$lib).add(DOT-PRECOMP)
}

our sub lib-precomp-path(:$lib --> IO::Path:D) is export {
	absolute($lib).add(DOT-PRECOMP)
}

our sub index-path(:$lib) is export {
	racoco-path(:$lib).add(INDEX)
}

our sub coverage-log-path(:$lib) is export {
	racoco-path(:$lib).add(COVERAGE-LOG)
}

our sub report-txt-path(:$lib) is export {
	racoco-path(:$lib).add(REPORT-TXT)
}

