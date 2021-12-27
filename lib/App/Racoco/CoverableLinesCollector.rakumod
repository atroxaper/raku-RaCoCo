unit module App::Racoco::CoverableLinesCollector;

use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::Misc;

class CoverableLinesCollector is export {
  has IO::Path $.lib;
  has CoverableLinesSupplier $.supplier;
  has Int $!lib-path-len;

  submethod TWEAK() {
    $!lib-path-len = $!lib.Str.chars + $*SPEC.dir-sep.chars;
  }

  method collect(--> Associative) {
    my %collect;
    collect-all-module-names-in(:$!lib)
      .map(-> $file-name {
        my $lines = $!supplier.supply(:$file-name);
        %collect{$file-name} = $lines.Set if $lines;
      });
    %collect
  }
}