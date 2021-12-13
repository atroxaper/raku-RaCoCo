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
	has IO::Path $!compiler-precomp-path;

	method lookup(Str $file-name --> IO::Path) {
		with self!lookup-compiler-precomp-path() -> $path {
			my $found = $path.add(file-precomp-path(path => $file-name.IO));
			return $found if $found.e
		}
		Nil
	}

	method !lookup-compiler-precomp-path(--> IO::Path) {
		return $_ with $!compiler-precomp-path;
		my $lib-precomp = lib-precomp-path(:$!lib);
		return Nil unless $lib-precomp.e;
		$!compiler-precomp-path = self!add-compiler-hashcode($lib-precomp);
		$!compiler-precomp-path
	}

	method !add-compiler-hashcode(IO::Path $lib-precomp-path --> IO::Path) {
		my $compiler-hashcode = self!lookup-compiler-hashcode($lib-precomp-path);
		with $compiler-hashcode {
			return $lib-precomp-path.add($_)
		}
		Nil
	}

	method !lookup-compiler-hashcode(IO::Path $lib-precomp-path --> Str) {
		my @compiler-ids = $lib-precomp-path.dir().grep(*.d);
    self!check-compiler-amount(@compiler-ids, $lib-precomp-path);
    @compiler-ids.elems == 1 ?? @compiler-ids[0].basename !! Nil
	}

	method !check-compiler-amount(@compiler-ids, $path) {
		if @compiler-ids.elems > 1 {
			App::Racoco::X::AmbiguousPrecompContent.new(:$path).throw
		}
	}
}

my class OurPrecompLocation does PrecompLocation {
	has $.lib;

	method lookup(Str $file-name --> IO::Path) {
		with our-precomp-path(:$!lib) -> $path {
			my $found = $path.add(file-precomp-path(path => $file-name.IO));
			return $found if $found.e
		}
		Nil
	}
}

class PrecompLookup is export {
  has PrecompLocation @!find-locations;

  submethod BUILD(IO() :$lib) {
    @!find-locations =
    	LibPrecompLocation.new(:$lib),
    	OurPrecompLocation.new(:$lib);
  }

  method lookup(Str :$file-name --> IO::Path) {
    for @!find-locations -> $location {
    	return $_ with $location.lookup($file-name)
    }
    return Nil
  }
}