unit module App::Racoco::Misc;

use App::Racoco::RunProc;

our sub percent(Int $numerator, Int $denominator --> Rat) is export {
	return 100.Rat if $denominator == 0;
	min 100.Rat, (($numerator / $denominator) * 100 * 10).Int / 10;
}

our sub collect-all-module-names-in(:$lib, :$collect is raw = [], :prefix($prefix-len)) is export {
	my $prefix = $prefix-len // $lib.Str.chars + $*SPEC.dir-sep.chars;
	for $lib.dir -> $file {
		if $file.d {
			collect-all-module-names-in(lib => $file, :$collect, :$prefix);
		} elsif $file.extension eq any('rakumod', 'pm6') {
			$collect.push: $file.Str.substr($prefix);
		}
	}
	$collect
}

our sub compiler-id(:$raku!, :$proc! --> Block) is export {
	autorun($raku ~ ' -e "print \$*RAKU.compiler.id"', :$proc, :out);
}