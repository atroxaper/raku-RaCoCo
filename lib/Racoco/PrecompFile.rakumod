unit module Racoco::PrecompFile;
use Racoco::X;
use Racoco::Sha;
use Racoco::UtilExtProc;
use Racoco::Paths;
use Racoco::Precomp::PrecompLookup;

sub get-our-precomp($lib) {
  $lib.parent.add(DOT-RACOCO).add(OUR-PRECOMP);
}

sub get-file-precomp(:$path is copy, :$sha) {
  my @parts;
  $path .= extension('');
  while $path ne '.' {
    @parts.push: $path.basename;
    $path .= parent;
  }
  my $module-name = @parts.reverse.join('::');
  my $sha-value = $sha.uc($module-name);
  my $two-letters = $sha-value.substr(0, 2);
  $two-letters.IO.add($sha-value)
}

class Maker is export {
  has RunProc $.proc;
  has IO::Path $.precomp-path;
  has Str $.raku;
  has Str $!lib-name;
  has $!sha;

  submethod BUILD(:$lib, :$!raku, :$!proc) {
    $!lib-name = $lib.basename;
    $!precomp-path = get-our-precomp($lib);
    $!precomp-path.mkdir;
    $!sha = Racoco::Sha::create()
  }

  method compile(IO() $path --> IO::Path) {
    my $output = $!precomp-path.add(get-file-precomp(:$path, :$!sha));
    $output.parent.mkdir;
    my $file = $!lib-name.IO.add($path);
    my $proc = $!proc.run(
      "$!raku -I$!lib-name --target=mbc --output=$output $file", :out(False)
    );
    $proc.exitcode == 0 ?? $output !! Nil;
  }
}

role Provider is export {
  method get($path) { ... }
}
class ProviderReal does Provider is export {
  has $!lookup;
  has $!maker;

  method BUILD(:$lib, :$raku, :$proc) {
    $!lookup = PrecompLookup.new(:$lib);
    $!maker = Maker.new(:$lib, :$raku, :$proc)
  }

  method get($path) {
    $!lookup.lookup(file-name => $path.Str) // $!maker.compile($path)
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