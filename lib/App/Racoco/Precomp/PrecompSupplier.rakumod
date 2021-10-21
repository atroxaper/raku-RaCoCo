unit module App::Racoco::Precomp::PrecompSupplier;

use App::Racoco::Precomp::PrecompLookup;
use App::Racoco::Precomp::Precompiler;

role PrecompSupplier is export {
	method supply(Str :$file-name --> IO::Path) { ... }
}

class PrecompSupplierReal does PrecompSupplier is export {
	has PrecompLookup $!lookup;
	has Precompiler $!precompiler;

	submethod BUILD(:$lib, :$raku, :$proc) {
    $!lookup = PrecompLookup.new(:$lib);
    $!precompiler = Precompiler.new(:$lib, :$raku, :$proc)
  }

	method supply(Str :$file-name --> IO::Path) {
		$!lookup.lookup(:$file-name) // $!precompiler.compile(:$file-name)
	}
}