unit module Fixture;

use Racoco::Precomp::PrecompSupplier;
use Racoco::UtilExtProc;
use Racoco::PrecompFile;
use Racoco::Annotation;
use Racoco::TmpDir;

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

  multi method add($key, $value) {
    %!mock{$key} = $value
  }

  method get($path) {
    %!mock{$path}
  }
}

my class TestHashcodeGetter does HashcodeGetter does TestKeyValueStore {}
my class TestIndex does Index does TestKeyValueStore {
  multi method add($annotation) { self.add($annotation.file, $annotation) }
  method flush() {}
}
my class TestCalculator is Calculator does TestKeyValueStore {
  method calc-and-update-index($path) { self.get($path) }
}
my class TestDumper does Dumper does TestKeyValueStore { }

sub putToTestKeyValueStore($store, %values) {
  for %values.kv -> $key, $value {
    $store.add($key, $value);
  }
  $store
}

our sub testSupplier(%files?) {
	return class Supplier does PrecompSupplier does TestKeyValueStore {
		method supply(Str :$file-name --> IO::Path) { self.get($file-name) }
	}.new
}

our sub testHashcodeGetter(%files?) {
  putToTestKeyValueStore(TestHashcodeGetter.new, %files)
}

our sub testIndex(%files?) {
  putToTestKeyValueStore(TestIndex.new, %files)
}

our sub testCalculator(%files?) {
  putToTestKeyValueStore(TestCalculator.new, %files)
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

sub cp($from, $to) {
  $from.copy($to);
}

sub create($create) {
  $create.mkdir;
}

sub copy($from, $to) {
  create($to);
  for $from.dir() -> $ls-from {
    my $ls-to = $to.add($ls-from.basename);
    if $ls-from.d {
      copy($ls-from, $ls-to);
    } else {
      cp($ls-from, $ls-to);
    }
  }
}

our sub root-folder() {
	't-resources'.IO.add('root-folder')
}

my $original-dir;
our sub change-current-dir-to-root-folder() {
	$original-dir = '.'.IO.absolute.IO;
	&*chdir(root-folder());
}

our sub restore-root-folder() {
  my $to = 't-resources/root-folder'.IO;
  my $from = 't-resources/root-folder-backup'.IO;
  Racoco::TmpDir::rmdir($to);
  copy($from, $to);
}

END {
	if $original-dir {
  	&*chdir($original-dir);
  	restore-root-folder;
  }
}