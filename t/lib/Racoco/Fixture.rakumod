unit module Fixture;

use Racoco::UtilExtProc;
use Racoco::PrecompFile;
use Racoco::Annotation;

our sub instant($time) {
  Instant.from-posix($time.Str)
}

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
  has $.modified is rw;
  method Str() {
    self.path
  }
}

our sub fakePath($path, :$modified) {
  my $result = FakeIOPath.new($path);
  $result.modified = instant($modified);
  $result
}

my role TestKeyValueStore {
  has %.mock;

  method add($key, $value) {
    %!mock{$key} = $value
  }

  method get($path) {
    %!mock{$path}
  }
}

my class TestProvider does Provider does TestKeyValueStore {}
my class TestHashcodeGetter does HashcodeGetter does TestKeyValueStore {}
my class TestIndex does Index does TestKeyValueStore { method flush() {} }
my class TestDumper does Dumper does TestKeyValueStore { }

sub putToTestKeyValueStore($store, %values) {
  for %values.kv -> $key, $value {
    $store.add($key, $value);
  }
  $store
}

our sub testProvider(%files?) {
  putToTestKeyValueStore(TestProvider.new, %files)
}

our sub testHashcodeGetter(%files?) {
  putToTestKeyValueStore(TestHashcodeGetter.new, %files)
}

our sub testIndex(%files?) {
  putToTestKeyValueStore(TestIndex.new, %files)
}

our sub testDumper(%files?) {
  putToTestKeyValueStore(TestDumper.new, %files)
}

our sub devNullHandle() {
  (class :: is IO::Handle {
    submethod TWEAK { self.encoding: 'utf8' }
    method WRITE(Blob:D \data) { True }
  }).new
}

our sub anno(Str $file, Str() $time, Str $hash, *@lines) {
  Annotation.new(
    :$file, :timestamp(instant($time)), :hashcode($hash), lines => @lines
  )
}