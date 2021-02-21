unit module Racoco::PrecompFileFind;
use Racoco::X;
use Racoco::Sha;

class Finder is export {
  has $.lib;
  has $!sha;

  method new(IO() :$lib is copy) {
    Racoco::X::WrongLibPath.new(:path($lib)).throw unless $lib.e;
    $lib = $lib.add('.precomp');
    return Finder unless $lib.e;

    $lib = $lib.add(self!compiler-id($lib));
    self.bless(:$lib);
  }

  submethod TWEAK() {
    $!sha = Racoco::Sha::create();
  }

  method !compiler-id($lib) {
    my @compiler-ids := $lib.dir().grep(*.d).eager.List;
    Racoco::X::AmbiguousPrecompContent.new(:path($lib)).throw
        if @compiler-ids.elems > 1;
    @compiler-ids[0].basename
  }

  multi method find(Finder:D: IO() \path --> IO::Path) {
    my $path-wo-ext = path.extension('').Str;
    my $sha-value = $!sha.uc($path-wo-ext);
    my $result = $!lib.add($sha-value.substr(0, 2)).add($sha-value).absolute.IO;
    return $result.e ?? $result !! Nil
  }

  multi method find(Finder:U: IO() \path --> Nil) {
    Nil
  }
}