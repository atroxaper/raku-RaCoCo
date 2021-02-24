unit module Fixture;

use Racoco::UtilExtProc;
use Racoco::PrecompFile;

my class FakeProc is RunProc {
  has $.c;
  method run(|c) {
    $!c = c;
    return class :: { method exitcode { 0 } }
  }
}

my class FailProc is RunProc {
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

my role TestKeyValueStore {
  has %.mock;

  method add($key, $value) {
    %!mock{$key} = $value
  }

  method get($path --> IO::Path) {
    %!mock{$path}
  }
}

my class TestProvider is Provider does TestKeyValueStore {}

our sub testProvider(%files) {
  my $provider = TestProvider.new;
  for %files.kv -> $name, $path {
    $provider.add($name, $path);
  }
  $provider
}

my class TestHashcodeGetter is HashcodeGetter does TestKeyValueStore {}

our sub testHashcodeGetter(%files) {
  my $provider = TestHashcodeGetter.new;
  for %files.kv -> $name, $path {
    $provider.add($name, $path);
  }
  $provider
}

our sub devNullHandle() {
  (class :: is IO::Handle {
    submethod TWEAK { self.encoding: 'utf8' }
    method WRITE(Blob:D \data) { True }
  }).new
}