unit module App::Racoco::Paths;

use App::Racoco::X;

constant \DOT-RACOCO = '.racoco';
constant \DOT-PRECOMP = '.precomp';
constant \OUR-PRECOMP = '.precomp';

constant \INDEX = 'index';
constant \COVERAGE-LOG = 'coverage.log';

constant \REPORT-TXT = 'report.txt';
constant \REPORT-DATA = 'report-data';
constant \REPORT-HTML = 'report.html';

constant \META6 = 'META6.json';
constant \CONFIG-FILE = 'racoco.ini';

sub absolute(IO::Path $path --> IO::Path) {
	$path.is-absolute ?? $path !! $path.absolute.IO
}

our sub racoco-path(IO() :$lib --> IO::Path:D) is export {
	mkdir absolute($lib).parent.add(DOT-RACOCO)
}

our sub our-precomp-path(IO() :$lib --> IO::Path:D) is export {
	mkdir racoco-path(:$lib).add(DOT-PRECOMP)
}

our sub lib-precomp-path(IO() :$lib --> IO::Path:D) is export {
	absolute($lib).add(DOT-PRECOMP)
}

our sub index-path(IO() :$lib --> IO::Path:D) is export {
	racoco-path(:$lib).add(INDEX)
}

our sub coverage-log-path(IO() :$lib --> IO::Path:D) is export {
	racoco-path(:$lib).add(COVERAGE-LOG)
}

our sub report-data-path(IO() :$lib --> IO::Path:D) is export {
	racoco-path(:$lib).add(REPORT-TXT)
}

our sub report-html-data-path(IO() :$lib --> IO::Path:D) is export {
	mkdir racoco-path(:$lib).add(REPORT-DATA)
}

our sub report-html-path(IO() :$lib --> IO::Path:D) is export {
	racoco-path(:$lib).add(REPORT-HTML)
}

our sub meta6-path(IO() :$lib --> IO::Path:D) is export {
  absolute($lib).parent.add(META6)
}

our sub parent-name(IO() $path) is export {
  absolute($path).parent.basename
}

our sub config-file(IO() :$lib) is export {
	absolute($lib).parent.add(CONFIG-FILE)
}

class Paths is export {
	has IO::Path $.root;
	has IO::Path $.lib;
	has IO::Path $.racoco;

	submethod BUILD(IO() :$root, IO() :$lib, IO() :$racoco) {
		$!root = absolute($root);
		App::Racoco::X::WrongRootPath.new(:path($root)).throw unless $!root.e;
		$!lib = absolute($lib);
		App::Racoco::X::WrongLibPath.new(:path($lib)).throw unless $!lib.e;
		$!racoco = absolute($racoco);
		mkdir $!racoco;
	}

	multi method from(IO() :$lib --> Paths:D) {
		self.bless(:root($lib.parent), :$lib, :racoco($lib.parent.add(DOT-RACOCO)))
	}
}
