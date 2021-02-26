unit module Racoco::Report;
use Racoco::Constants;

enum COLOR is export <GREEN RED PURPLE>;

sub percent-round($n) {
  ($n * 10).Int / 10;
}

class ReportFile is export {
  has Str $.file;
  has Set $.green;
  has Set $.red;
  has Set $.purple;

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

  method files() {
    %!files.values.sort(*.file).List
  }
}

role Reporter {
  method from-data(:%possible-lines, :%covered-lines --> Reporter) { ... }
  method write(:$lib --> IO::Path) { ... }
}

class BaseReporter does Reporter is export {
  has Report $.report;

  method from-data(:%possible-lines, :%covered-lines --> Reporter) {
    my @files = %possible-lines.map(-> $p {
      my $covered = (%covered-lines{$p.key} // ()).Set;
      my $possible = $p.value.Set;
      my $green = $possible ∩ $covered;
      my $red = $possible ∖ $covered;
      my $purple = $covered ∖ $possible;
      ReportFile.new(:file($p.key), :$green, :$red, :$purple)
    }).List;

    self.bless(report => Report.new(:@files));
  }

  method write(:$lib --> IO::Path) {
    return Nil unless $lib.e;
    my $path = $lib.parent.add($DOT-RACOCO).add($REPORT-TXT);
    my $h = $path.open(:w);
    LEAVE { .close with $h }
    $h.say($!report.percent(), '%');
    $!report.files().map(-> $f {
      $h.say($f.file);
      $h.say($f.percent, '%');
      $h.say('green ', "{$f.green.keys.sort.List}") if $f.green;
      $h.say('red ', "{$f.red.keys.sort.List}") if $f.red;
      $h.say('purple ', "{$f.purple.keys.sort.List}") if $f.purple;
    });
    $path
  }

}