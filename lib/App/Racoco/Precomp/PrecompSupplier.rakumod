unit module App::Racoco::Precomp::PrecompSupplier;

use App::Racoco::Precomp::PrecompLookup;
use App::Racoco::Precomp::Precompiler;
use App::Racoco::Misc;

role PrecompSupplier is export {
	method supply(Str :$file-name --> IO::Path) { ... }
}

class PrecompSupplierReal does PrecompSupplier is export {
	has PrecompLookup $.lookup is required;
	has Precompiler $.precompiler is required;

	method supply(Str :$file-name --> IO::Path) {
		$!lookup.lookup(:$file-name) // $!precompiler.compile(:$file-name)
	}
}