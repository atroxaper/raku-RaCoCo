unit module App::Racoco::Precomp::PrecompLookup;

use App::Racoco::ModuleNames;
use App::Racoco::Paths;
use App::Racoco::Sha;
use App::Racoco::X;

my role PrecompLocation {
	method lookup(Str $file-name --> IO::Path) { ... }
}

my class LibPrecompLocation does PrecompLocation {
	has IO::Path $.lib;
	has Str $.compiler-id;
	has IO::Path $!compiler-precomp-path;

	method lookup(Str $file-name --> IO::Path) {
		with self!lookup-compiler-precomp-path() -> $path {
			my $found = $path.add(file-precomp-path(:$!lib, path => $file-name.IO));
			return $found if $found.e
		}
		Nil
	}

	method !lookup-compiler-precomp-path(--> IO::Path) {
		return $_ with $!compiler-precomp-path;
		return Nil unless $!compiler-id;
		my $result = lib-precomp-path(:$!lib).add($!compiler-id);
		return Nil unless $result.e;
		$!compiler-precomp-path = $result
	}
}

my class OurPrecompLocation does PrecompLocation {
	has $.lib;

	method lookup(Str $file-name --> IO::Path) {
		with our-precomp-path(:$!lib) -> $path {
			my $found = $path.add(file-precomp-path(:$!lib, path => $file-name.IO));
			return $found if $found.e
		}
		Nil
	}
}

class PrecompLookup is export {
  has PrecompLocation @!find-locations;

  submethod BUILD(IO() :$lib!, Str :$compiler-id!) {
    @!find-locations =
    	LibPrecompLocation.new(:$lib, :$compiler-id),
    	OurPrecompLocation.new(:$lib);
  }

  method lookup(Str :$file-name --> IO::Path) {
    for @!find-locations -> $location {
    	return $_ with $location.lookup($file-name)
    }
    return Nil
  }
}