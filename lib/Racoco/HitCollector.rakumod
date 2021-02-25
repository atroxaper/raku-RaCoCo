unit module Racoco::HitCollector;
use Racoco::UtilExtProc;
use Racoco::Constants;

class HitCollector is export {
  has $!path;
  has $!lib;
  has RunProc $.proc;
  has Str $.exec;
  has Bool $.append = False;
  has Bool $.no-tests = False;

  submethod TWEAK(:$lib) {
    $!lib = $lib.absolute.IO;
    $!path = $lib.parent.add($DOT-RACOCO).add($COVERAGE-LOG);
  }

  method get() {
    $!path.unlink unless $!append;
    return Nil unless self!run-tests();
    self!parse-log;
  }

  method !run-tests() {
    return True if $!no-tests;
    my $proc = $!proc.run("MVM_COVERAGE_LOG=$!path $!exec", :out(False));
    $proc.exitcode == 0 ?? True !! False;
  }

  method !parse-log() {
    return Nil unless $!path.e;
    my $prefix = 'HIT  ' ~ $!lib;
    my $prefix-len = $prefix.chars + '/'.chars;
    $!path.lines
      .grep(*.starts-with($prefix))
      .map(*.substr($prefix-len))
      .unique
      .map(-> $h { .[0] => .[2] with $h.words})
      .classify({ $_.key })
      .map({ $_.key => $_.value.map(*.value.Int).sort.List })
      .eager
      .Hash
  }
}

