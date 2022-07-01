unit module App::Racoco::Coverable::Precomp::Precompiler;

use App::Racoco::ModuleNames;
use App::Racoco::RunProc;
use App::Racoco::Paths;

class Precompiler is export {
	has IO::Path $.lib;
	has RunProc $.proc;
	has Str $.raku;

	method compile(Str :$file-name --> IO::Path) {
		my $file-precomp-path = file-precomp-path(:$!lib, path => $file-name.IO);
		my $out-path = our-precomp-path(:$!lib).add($file-precomp-path);
		$out-path.parent.mkdir;
		my $source-file = $!lib.add($file-name);
		my $proc = $!proc.run(
			qq/$!raku -I$!lib --target=mbc --output=$out-path $source-file/, :!out,
			:err, error-handler => suppress-precompilation-impotence($file-name)
		);
		$proc.exitcode ?? Nil !! $out-path;
	}

	my sub suppress-precompilation-impotence($file-name) {
		-> $proc, $comand, &default-handler {
			my $error-msg = slurp($proc.err);
			if $error-msg ~~ /'This compilation unit cannot be pre-compiled'/ {
				$*OUT.say: "$file-name cannot be precompiled. Coverage results may be inaccurate.";
			} else {
				default-handler($proc, $comand);
			}
		}
	}
}