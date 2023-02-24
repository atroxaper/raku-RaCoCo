unit module App::Racoco::Coverable::Precomp::PrecompLookup;

use App::Racoco::ModuleNames;
use App::Racoco::Paths;
use App::Racoco::Sha;
use App::Racoco::X;

my role PrecompLocation {
	has $.paths is required;

	method lookup(Str $file-name --> IO::Path) {
		with self.precomp-location -> $path {
			my $found = $path
				.add(file-precomp-path(lib => $!paths.lib, path => $file-name.IO));
			return $found if $found.e
		}
		Nil
	}

	method precomp-location(--> IO::Path:D) { ... }
}

my class LibPrecompLocation does PrecompLocation {
	has Block $.compiler-id;
	has IO::Path $!compiler-precomp-path;

	method precomp-location(--> IO::Path:D) {
		self!lookup-compiler-precomp-path()
	}

	method !lookup-compiler-precomp-path(--> IO::Path) {
		return $_ with $!compiler-precomp-path;
		my $id = $!compiler-id();
		return Nil unless $id;
		my $result = $!paths.lib-precomp-path.add($id);
		return Nil unless $result.e;
		$!compiler-precomp-path = $result
	}
}

my class OurPrecompLocation does PrecompLocation {
	method precomp-location(--> IO::Path:D) {
		$!paths.our-precomp-path
	}
}

class PrecompLookup is export {
  has PrecompLocation @!find-locations;

  submethod BUILD(:$paths!, Block :$compiler-id!) {
    @!find-locations =
    	LibPrecompLocation.new(:$paths, :$compiler-id),
    	OurPrecompLocation.new(:$paths);
  }

  method lookup(Str :$file-name --> IO::Path) {
    for @!find-locations -> $location {
    	return $_ with $location.lookup($file-name)
    }
    return Nil
  }
}