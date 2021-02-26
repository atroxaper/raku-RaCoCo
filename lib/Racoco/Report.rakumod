unit module Racoco::Report;

enum COLOR is export <GREEN RED PURPLE>;

sub percent-round($n) {
  ($n * 10).Int / 10;
}

class ReportFile is export {
  has Str $.file;
  has Set $!green;
  has Set $!red;
  has Set $!purple;

  method BUILD(:$!file, Set() :$!green, Set() :$!red, Set() :$!purple) {}

  method percent() {
    my $covered = $!green.elems + $!purple.elems;
    my $possible = $!green.elems + $!red.elems;
    return 100 if $possible == 0;
    min(100, percent-round(($covered / $possible) * 100));
  }

  method color(Int $n) {
    return GREEN if $!green{$n};
    return RED if $!red{$n};
    return PURPLE if $!purple{$n};
  }
}

class Report is export {
  has %!files;

  method new(:@files) {
    self.bless(files => @files.map({ .file => $_ }).Hash)
  }

  method BUILD(:%!files) { }

  method percent() {
    return 100 if %!files.elems == 0;
    percent-round(%!files.values.map(*.percent).sum / %!files.elems);
  }

  method get($file) {
    %!files{$file}
  }
}