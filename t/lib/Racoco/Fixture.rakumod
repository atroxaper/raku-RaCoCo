unit module Fixture;

use Racoco::Precomp::PrecompSupplier;
use Racoco::Precomp::PrecompHashcodeReader;
use Racoco::RunProc;
use Racoco::Coverable::Coverable;
use Racoco::Coverable::CoverableIndex;
use Racoco::Coverable::CoverableOutliner;
use Racoco::Coverable::CoverableLinesSupplier;
use Racoco::TmpDir;

our sub instant($time) {
  Instant.from-posix($time.Str)
}

our sub fakeProc() {
  class FakeProc is RunProc {
    has $.c;
    method run(|c) {
      $!c = c;
      return class :: { method exitcode { 0 } }
    }
  }.new
}

our sub failProc() {
  class FailProc is RunProc {
    method run(|c) {
      return class :: { method exitcode { 1 } }
    }
  }.new
}

our sub fakePath($path, :$modified) {
  my $result = class FakeIOPath is IO::Path {
    has $.modified is rw;
    method Str() {
      self.path
    }
  }.new($path);
  $result.modified = instant($modified);
  $result
}

my role TestKeyValueStore {
  has %.mock;
  multi method add($key, $value) { %!mock{$key} = $value }
  method get($path) { %!mock{$path} }
}

our sub testPrecompSupplier() {
	class PreSupplier does PrecompSupplier does TestKeyValueStore {
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

our sub testLinesSupplier() {
  class LineSupplier is CoverableLinesSupplier does TestKeyValueStore {
		method supply(Str :$file-name) { self.get($file-name) }
	}.new
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

my $out;
my @out-collect = [];
our sub capture-out() {
  $out = $*OUT;
  $*OUT = (class :: is IO::Handle {
    submethod TWEAK { self.encoding: 'utf8' }
    method WRITE(Blob:D \data) { @out-collect.push(data.decode); True }
  }).new
}

our sub get-out() {
  my $result = @out-collect.join("\n").trim;
  @out-collect = [];
  $result
}

our sub restore-out() {
  $*OUT = $out if $out;
}

our sub root-folder() {
	't-resources'.IO.add('root-folder')
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

my $need-restore;
our sub need-restore-root-folder() {
  $need-restore = True;
}
our sub restore-root-folder() {
  my $to = 't-resources/root-folder'.IO;
  my $from = 't-resources/root-folder-backup'.IO;
  Racoco::TmpDir::rmdir($to);
  copy($from, $to);
}

END {
  restore-root-folder() if $need-restore;
}