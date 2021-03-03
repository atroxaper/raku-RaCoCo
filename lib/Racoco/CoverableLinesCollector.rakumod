unit module Racoco::CoverableLinesCollector;

use Racoco::Coverable::CoverableLinesSupplier;

class CoverableLinesCollector is export {
  has IO::Path $.lib;
  has CoverableLinesSupplier $.supplier;
  has Int $!lib-path-len;

  submethod TWEAK() {
    $!lib-path-len = $!lib.Str.chars + '/'.chars;
  }

  method collect(--> Associative) {
    self!iter-through($!lib, %{});
  }

  method !iter-through($dir, %collect) {
    for $dir.dir -> $file {
      if $file.d {
        self!iter-through($file, %collect);
      } elsif $file.extension eq any('rakumod', 'pm6') {
        my $file-name = $file.Str.substr($!lib-path-len);
        my $lines = $!supplier.supply(:$file-name);
        %collect{$file-name} = $lines.Set if $lines;
      }
    }
    %collect
  }
}