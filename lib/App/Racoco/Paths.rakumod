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

	sub absolute(IO::Path $path --> IO::Path) {
		$path.is-absolute ?? $path !! $path.absolute.IO
	}

	method !calc-root-racoco(--> IO::Path:D) {
		$!root ~~ $!racoco.parent
			?? $!racoco
			!! $!racoco.add(self!root-hash-name)
	}

	method !root-hash-name(--> Str:D) {
		App::Racoco::Sha::create.uc($!root.Str)
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

	method meta6-path(--> IO::Path:D) {
  	$!root.add(META6)
	}

	method root-name(--> Str:D) {
		$!root.basename
	}

	method config-path-in(::?CLASS:U: IO() $path --> IO::Path:D) {
		$path.add(CONFIG-FILE)
	}
}
