unit module Racoco::CoveredLinesCollector;

use Racoco::RunProc;
use Racoco::Paths;

class CoveredLinesCollector is export {
  has IO::Path $.lib;
  has RunProc $.proc;
  has Str $.exec;
  has Bool $.append = False;
  has Bool $.no-tests = False;
  has $!coverage-log-path;

  submethod TWEAK() {
    $!lib = $!lib.absolute.IO;
    $!coverage-log-path = coverage-log-path(:$!lib);
    $!coverage-log-path.unlink unless $!append;
  }

  method collect(--> Associative) {
    return %{} unless self!run-tests();
    self!parse-log;
  }

  method !run-tests(--> Bool) {
    return True if $!no-tests;
    my $proc = $!proc.run("MVM_COVERAGE_LOG=$!coverage-log-path $!exec", :!out);
    $proc.exitcode == 0;
  }

  method !parse-log(--> Associative) {
    return Nil unless $!coverage-log-path.e;
    my $prefix = 'HIT  ' ~ $!lib;
    my $prefix-len = $prefix.chars + '/'.chars;
    $!coverage-log-path.lines
      .grep(*.starts-with($prefix))
      .map(*.substr($prefix-len))
      .unique
      .map(-> $h { .[0] => .[2] with $h.words})
      .classify({ $_.key })
      .map({ $_.key => $_.value.map(*.value.Int).Set })
      .Hash
  }
}

