unit module Fixture;

use Racoco::UtilExtProc;
use Racoco::PrecompFile;

my class FakeProc does ExtProc {
  has $.c;
  method run(|c) {
    $!c = c;
    return class :: { method exitcode { 0 } }
  }
}

my class FailProc does ExtProc {
  method run(|c) {
    return class :: { method exitcode { 1 } }
  }
}

our sub fakeProc() { FakeProc.new }
our sub failProc() { FailProc.new }

my class FakeIOPath is IO::Path {
  has $.modified is built = now;
  method modified() {
    $!modified
  }
}

our sub fakePath(|c) { FakeIOPath.new(|c) }

my class TestPrecompFile is Provider {
  has %.mock;

  method add($key, $value) {
    %!mock{$key} = $value
  }

  method get($path --> IO::Path) {
    %!mock{$path}
  }
}

our sub testPrecompProvider(%files) {
  my $provider = TestPrecompFile.new;
  for %files.kv -> $name, $path {
    $provider.add($name, $path);
  }
  $provider
}