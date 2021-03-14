unit module Racoco::CoveredLinesCollector;

use Racoco::RunProc;
use Racoco::Paths;
use Racoco::X;

class CoveredLinesCollector is export {
  has IO::Path $.lib;
  has RunProc $.proc;
  has $.exec;
  has Bool $.append = False;
  has Bool $.print-test-log = True;
  has $!coverage-log-path;

  submethod TWEAK() {
    $!lib = $!lib.absolute.IO;
    $!coverage-log-path = coverage-log-path(:$!lib);
    $!coverage-log-path.unlink unless self!need-save-log;
  }

  method !need-save-log() {
    $!append || !$!exec
  }

  method collect(--> Associative) {
    self!run-tests();
    self!parse-log;
  }

  method !run-tests() {
    return True unless $!exec;
    my $arg = "MVM_COVERAGE_LOG=$!coverage-log-path $!exec";
    my $proc = $!print-test-log ?? $!proc.run($arg) !! $!proc.run($arg, :!out);
    if $proc.exitcode {
      Racoco::X::NonZeroExitCode.new(exitcode => $proc.exitcode).throw
    }
  }

  method !parse-log(--> Associative) {
    return %{} unless $!coverage-log-path.e;
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

