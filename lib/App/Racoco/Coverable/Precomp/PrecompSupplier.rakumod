unit module App::Racoco::Coverable::Precomp::PrecompSupplier;

use App::Racoco::Coverable::Precomp::PrecompLookup;
use App::Racoco::Coverable::Precomp::Precompiler;
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