unit module Fixture;

use App::Racoco::Configuration;
use App::Racoco::Coverable::Precomp::PrecompSupplier;
use App::Racoco::Coverable::Precomp::PrecompHashcodeReader;
use App::Racoco::RunProc;
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::Coverable::CoverableLinesSupplier;

our sub make-paths($root) {
	make-paths-from(config => ConfigurationFactory.defaults, :$root)
}

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

our sub realProc() {
	class RealProc is RunProc {
		has $.c;
		method run(|c) {
			$!c = c;
			RunProc.new.run(|c);
		}
	}.new
}

our sub mockProc(*%responces) {
	class :: is RunProc {
		has %.responces;
		method run($command, |c) {
			my $responce = %!responces.first({$command.contains: .key}).value // Nil;
			return class :: {
				method exitcode { 0 }
				method out {
					return class :: {
						method close {}
						method slurp { $responce }
					}.new
				}
			}.new
		}
	}.new(:%responces)
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
					self.get($path)<>
				}
			}.new;
	for @data -> $file-name, $lines { $outliner.add($file-name, $lines) }
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
		submethod TWEAK { self.encoding: 'utf8'}
		method WRITE(Blob:D \data) { @!out.push(data.decode); True }
		method text() { @!out.join() }
	}
	class Captured {
		has $.out;
		has $.err;
		method new(\out, \err) { self.bless.set(out, err) }
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