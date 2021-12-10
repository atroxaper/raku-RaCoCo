unit module Fixture;

use App::Racoco::Precomp::PrecompSupplier;
use App::Racoco::Precomp::PrecompHashcodeReader;
use App::Racoco::RunProc;
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::TmpDir;

our sub instant($time) {
	Instant.from-posix($time.Str)
}

our sub fakeProc() {
	class FakeProc is RunProc {
		has $.c;
		method run(|c) {
			$!c = c;
			return class :: {
				method exitcode {
					0
				}
			}
		}
	}.new
}

our sub failProc() {
	class FailProc is RunProc {
		method run(|c) {
			return class :: {
				method exitcode {
					1
				}
			}
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

our sub compiler-id() {
	$*RAKU.compiler.id
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

our sub testPrecompSupplier(*@data) {
	my $supplier =
			class PreSupplier does PrecompSupplier does TestKeyValueStore {
				method supply(Str :$file-name --> IO::Path) {
					self.get($file-name)
				}
			}.new;
	for @data -> $file-name, $precomp { $supplier.add($file-name, $precomp) }
	return $supplier;
}

our sub testOutliner(**@data) {
	my $outliner =
			class Outliner does CoverableOutliner does TestKeyValueStore {
				method outline(IO::Path :$path --> Positional) {
					self.get($path)
				}
			}.new;
	for @data -> $file-name, @lines { $outliner.add($file-name, @lines) }
	return $outliner;
}

our sub testIndex(*@data) {
	my $index =
			class Index does CoverableIndex does TestKeyValueStore {
				method put(Coverable :$coverable) {
					self.add($coverable.file-name, $coverable)
				}
				method retrieve(Str :$file-name --> Coverable) {
					self.get($file-name) // Nil
				}
			}.new;
	for @data -> $coverable { $index.put(:$coverable) }
	return $index;
}

our sub testHashcodeReader(*@data) {
	my $reader =
			class Reader does PrecompHashcodeReader does TestKeyValueStore {
				method read(IO() :$path --> Str) {
					self.get($path)
				}
			}.new;
	for @data -> $file-name, $hashcode { $reader.add($file-name, $hashcode) }
	return $reader;
}

our sub testLinesSupplier(**@data) {
	my $supplier =
			class LineSupplier is CoverableLinesSupplier does TestKeyValueStore {
				method supply(Str :$file-name) {
					self.get($file-name)
				}
			}.new;
	for @data -> $file-name, @lines { $supplier.add($file-name, @lines) }
	return $supplier;
}

our sub silently(&block) {
	class Capturer is IO::Handle {
		has @!out;
		submethod TWEAK {
			self.encoding: 'utf8'
		}
		method WRITE(Blob:D \data) {
			@!out.push(data.decode);
			True
		}
		method text() {
			@!out.join()
		}
	}
	class Captured {
		has $.out;
		has $.err;
		method new(\out, \err) {
			self.bless.set(out, err)
		}
		method set(\out, \err) {
			out = $!out := Capturer.new;
			err = $!err := Capturer.new;
			self
		}
	}
	my $result = Captured.new(my $*OUT, my $*ERR);
	block();
	return $result;
}

my $out;
my @out-collect;
our sub capture-out() {
	$out = $*OUT;
	$*OUT = (class :: is IO::Handle {
		submethod TWEAK {
			self.encoding: 'utf8'
		}
		method WRITE(Blob:D \data) {
			@out-collect.push(data.decode);
			True
		}
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

sub make-dir($create is copy) {
	if ($create.basename eq 'current_compiler_id') {
		$create = $create.parent.add(compiler-id());
	}
	$create.mkdir;
	$create
}

sub copy($from, $to is copy) {
	$to = make-dir($to);
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
	TmpDir::rmdir($to);
	copy($from, $to);
}

END {
	restore-root-folder() if $need-restore;
}