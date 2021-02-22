unit module Racoco::PrecompFileFind;
use Racoco::X;
use Racoco::Sha;
use Racoco::UtilExtProc;
use Racoco::Constants;

class Finder is export {
  has $!sha;
  has @!find-locations;

  method BUILD(:$lib is copy) {
    Racoco::X::WrongLibPath.new(:path($lib)).throw unless $lib.e;
    $lib = $lib.absolute.IO;
    @!find-locations.push: $_ with self!get-raku-location($lib);
    @!find-locations.push: $_ with self!get-our-location($lib);
    $!sha = Racoco::Sha::create()
  }

  method !get-raku-location($lib) {
    my $lib-precomp = $lib.add($DOT-PRECOMP);
    return self!add-compiler-id($lib-precomp) if $lib-precomp.e;
    Nil
  }

  method !get-our-location($lib) {
    my $our-precomp = $lib.parent.add($DOT-RACOCO).add($OUR-PRECOMP);
    return $our-precomp if $our-precomp.e;
    Nil
  }

  method !add-compiler-id($path) {
    my @compiler-ids := $path.dir().grep(*.d).eager.List;
    Racoco::X::AmbiguousPrecompContent.new(:$path).throw
        if @compiler-ids.elems > 1;
    @compiler-ids.elems == 1 ?? $path.add(@compiler-ids[0].basename) !! IO::Path
  }

  multi method find(Finder: IO() \path --> IO::Path) {
    my $path-wo-ext = path.extension('').Str;
    my $sha-value = $!sha.uc($path-wo-ext);
    my $two-letters = $sha-value.substr(0, 2);
    for @!find-locations -> $location {
      my $result = $location.add($two-letters).add($sha-value);
      return $result if $result.e;
    }
    return Nil
  }
}

class Maker is export {
  has ExtProc $.proc;
  has IO::Path $.precomp-path;
  has Str $.raku = 'raku';
  has $!sha;

  submethod TWEAK() {
    $!precomp-path //= '.racoco'.IO.add('.precomp');
    $!precomp-path.mkdir;
    $!sha = Racoco::Sha::create();
  }

  method compile($lib, $file --> IO::Path) {
    my $output = $!precomp-path.add($!sha.uc($file));
    my $proc = $!proc.run(
      $!raku,
      "-I$lib",
      '--target=mbc',
      "--output=$output",
      $file.Str
    );
    $proc.exitcode == 0 ?? $output !! Nil;
  }
}