unit module App::Racoco::Paths;

use App::Racoco::Sha;
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
		.add(root-hash-name($lib.parent));
}

our sub meta6-path(IO() :$lib --> IO::Path:D) is export {
  absolute($lib).parent.add(META6)
}

our sub parent-name(IO() $path) is export {
  absolute($path).parent.basename
}

our sub root-hash-name(IO() $path --> Str) is export {
	App::Racoco::Sha::create.uc(absolute($path).Str)
}

our sub config-file(IO() :$lib) is export {
	absolute($lib).parent.add(CONFIG-FILE)
}

our sub config-path(IO() :$root) is export {
	$root.add(CONFIG-FILE)
}

class Paths is export {
	has IO::Path $.root;
	has IO::Path $.lib;
	has IO::Path $!racoco;
	has IO::Path $.root-racoco is built(False);

	multi method from(IO() :$lib! --> Paths:D) {
		self.bless(:root($lib.parent), :$lib, :racoco($lib.parent.add(DOT-RACOCO)))
	}

	submethod BUILD(IO() :$root!, IO() :$lib!, IO() :$racoco!) {
		$!root = check-dir-path($root, App::Racoco::X::WrongRootPath);
		$!lib = check-dir-path(concat($!root, $lib), App::Racoco::X::WrongLibPath);
		$!racoco = concat($!root, $racoco);
		mkdir $!racoco;
		$!racoco = check-dir-path($!racoco, App::Racoco::X::WrongRacocoPath);
		$!root-racoco = self!calc-root-racoco;
		mkdir $!root-racoco;
		mkdir self.our-precomp-path;
		mkdir self.report-html-data-path;
	}

	sub concat($root, $path) {
		$path.is-absolute ?? $path !! $root.add($path)
	}

	sub check-dir-path(IO $path, App::Racoco::X::WrongPath:U $err-class) {
		$err-class.new(:$path).throw unless $path ~~ :e & :d;
		absolute($path);
	}

	method !calc-root-racoco(--> IO::Path:D) {
		$!root ~~ $!racoco.parent
			?? $!racoco
			!! $!racoco.add(root-hash-name($!root))
	}

	method coverage-log-path(--> IO::Path:D) {
		$!root-racoco.add(COVERAGE-LOG)
	}

	method lib-precomp-path(--> IO::Path:D) {
		$!lib.add(DOT-PRECOMP)
	}

	method our-precomp-path(--> IO::Path:D) {
		$!root-racoco.add(DOT-PRECOMP)
	}

	method index-path(--> IO::Path:D) {
		$!root-racoco.add(INDEX)
	}

	method report-data-path(--> IO::Path:D) {
		$!root-racoco.add(REPORT-TXT)
	}

	method report-html-path(--> IO::Path:D) {
		$!root-racoco.add(REPORT-HTML)
	}

	method report-html-data-path(--> IO::Path:D) {
		$!root-racoco.add(REPORT-DATA)
	}
}
