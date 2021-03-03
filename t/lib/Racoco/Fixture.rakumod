unit module Fixture;

use Racoco::Precomp::PrecompSupplier;
use Racoco::Precomp::PrecompHashcodeReader;
use Racoco::UtilExtProc;
use Racoco::Coverable::Coverable;
use Racoco::Coverable::CoverableIndex;
use Racoco::Coverable::CoverableOutliner;
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

sub putToTestKeyValueStore($store, %values) {
  for %values.kv -> $key, $value {
    $store.add($key, $value);
  }
  $store
}

our sub testSupplier() {
	class Supplier does PrecompSupplier does TestKeyValueStore {
		method supply(Str :$file-name --> IO::Path) { self.get($file-name) }
	}.new
}

our sub testOutliner() {
	class Outliner does CoverableOutliner does TestKeyValueStore {
		method outline(IO::Path :$path --> Positional) { self.get($path) }
	}.new
}

our sub testIndex() {
  class Index does CoverableIndex does TestKeyValueStore {
		method put(Coverable :$coverable) {
			self.add($coverable.file-name, $coverable)
		}
		method retrieve(Str :$file-name --> Coverable) { self.get($file-name) // Nil }
	}.new
}

our sub testHashcodeReader() {
  class Reader does PrecompHashcodeReader does TestKeyValueStore {
		method read(IO() :$path --> Str) { self.get($path) }
	}.new
}

my class TestCalculator is Calculator does TestKeyValueStore {
  method calc-and-update-index($path) { self.get($path) }
}

our sub testCalculator(%files?) {
  putToTestKeyValueStore(TestCalculator.new, %files)
}




my $err;
our sub suppressErr() {
	$err = $*ERR;
	$*ERR = (class :: is IO::Handle {
    submethod TWEAK { self.encoding: 'utf8' }
    method WRITE(Blob:D \data) { True }
  }).new
}
our sub restoreErr() {
	$*ERR = $err if $err
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