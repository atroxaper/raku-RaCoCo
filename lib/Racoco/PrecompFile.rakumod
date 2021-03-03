unit module Racoco::PrecompFile;
use Racoco::X;
use Racoco::Sha;
use Racoco::UtilExtProc;
use Racoco::Paths;
use Racoco::Precomp::PrecompLookup;
use Racoco::Precomp::Precompiler;

role Provider is export {
  method get($path) { ... }
}

class ProviderReal does Provider is export {
  has PrecompLookup $!lookup;
  has Precompiler $!precompiler;

  method BUILD(:$lib, :$raku, :$proc) {
    $!lookup = PrecompLookup.new(:$lib);
    $!precompiler = Precompiler.new(:$lib, :$raku, :$proc)
  }

  method get($path) {
    $!lookup.lookup(file-name => $path.Str) // $!precompiler.compile(file-name => $path.Str)
  }
}

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