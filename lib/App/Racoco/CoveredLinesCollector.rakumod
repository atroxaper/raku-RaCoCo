unit module App::Racoco::CoveredLinesCollector;

use App::Racoco::RunProc;
use App::Racoco::Misc;
use App::Racoco::X;

class CoveredLinesCollector is export {
  has IO::Path $!lib;
  has RunProc $.proc;
  has $.exec;
  has Bool $.append = False;
  has Bool $.print-test-log = True;
  has IO::Path $!coverage-log-path;

  submethod TWEAK(:$paths) {
    $!lib = $paths.lib;
    $!coverage-log-path = $paths.coverage-log-path;
  }

  method !need-save-log() {
    $!append || !$!exec
  }

  method collect(--> Associative) {
    $!coverage-log-path.unlink unless self!need-save-log;
    self!run-tests();
    my $result = self!parse-log;
    $!coverage-log-path.unlink if $!coverage-log-path.e;
    $result;
  }

  method !run-tests() {
    return unless $!exec;
    my %vars = MVM_COVERAGE_LOG => $!coverage-log-path;
    my $proc = $!print-test-log
        ?? $!proc.run($!exec, :%vars, :out<->)
        !! $!proc.run($!exec, :%vars, :!out);
    if $proc.exitcode {
      App::Racoco::X::NonZeroExitCode.new(exitcode => $proc.exitcode).throw
    }
  }

  method !parse-log(--> Associative) {
    return %{} unless $!coverage-log-path.e;
    my $prefix = 'HIT  ' ~ $!lib ~ $*SPEC.dir-sep;
    my $prefix-len = $prefix.chars;
    my $real-module-names = collect-all-module-names-in(:$!lib).Set;
    $!coverage-log-path.lines
      .grep(*.starts-with($prefix))
      .map(*.substr($prefix-len))
      .map(-> $h { .[0] => .[2] with $h.words})
      .classify({ $_.key })
      .grep({ $real-module-names{$_.key} })
      .map({ $_.key => $_.value.map({ (($_.value // 0).Int // 0) }).grep(* > 0).Bag })
      .Hash
  }
}

