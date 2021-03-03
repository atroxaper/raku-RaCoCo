unit module Racoco::PrecompFile;
use Racoco::X;
use Racoco::Sha;
use Racoco::UtilExtProc;
use Racoco::Paths;
use Racoco::Precomp::PrecompLookup;
use Racoco::Precomp::Precompiler;

role HashcodeGetter is export {
  method get($path) { ... }
}

class HashcodeGetterReal does HashcodeGetter is export {
  method get(IO() $path --> Str) {
    my $h = $path.open :r;
    LEAVE { .close with $h }
    $h.get
  }
}