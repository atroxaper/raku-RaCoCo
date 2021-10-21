unit module App::Racoco::Precomp::Precompiler;

use App::Racoco::ModuleNames;
use App::Racoco::RunProc;
use App::Racoco::Paths;

class Precompiler is export {
	has IO::Path $.lib;
	has RunProc $.proc;
	has Str $.raku;

	method compile(Str :$file-name --> IO::Path) {
		my $file-precomp-path = file-precomp-path(path => $file-name.IO);
		my $out-path = our-precomp-path(:$!lib).add($file-precomp-path);
		$out-path.parent.mkdir;
		my $source-file = $!lib.add($file-name);
		my $proc = $!proc.run(
			qq/$!raku -I$!lib --target=mbc --output=$out-path $source-file/, :!out
		);
		$proc.exitcode ?? Nil !! $out-path;
	}
}