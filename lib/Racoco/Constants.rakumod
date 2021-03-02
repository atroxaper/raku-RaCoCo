unit module Racoco::Constants;

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

our sub dot-racoco(:$lib --> IO::Path:D) {
	mkdir absolute($lib).add(DOT-RACOCO);
}

our sub dot-precomp(:$lib --> IO::Path:D) {
	mkdir dot-racoco(:$lib).add(DOT-PRECOMP);
}

