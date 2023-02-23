unit module App::Racoco::Configuration;

use App::Racoco::ConfigFile;
use App::Racoco::Paths;

role Factory { ... }
class ConfigurationFactoryOr { ... }

role Key[::Type] {
	has Str $.name is required;
	method convert(Str $value --> Type) { ... }
	multi method of(Str() $name) { self.bless: :$name }
}

class BoolKey does Key[Bool] is export {
	method convert($value --> Bool) {
		return Nil without $value;
		if $value ~~ Str {
			if $value.lc eq 'false' || $value eq '0' || $value.chars == 0 {
				return False;
			}
		}
		return so $value;
	}
}

class IntKey does Key[Int] is export {
	method convert($value --> Int) {
		return Nil without $value;
		$value.Int
	}
}

role PathKey does Key[IO::Path] is export {
	method convert($value --> IO::Path) {
		return Nil without $value;
		given $value.IO {
			return $_.absolute.IO if self.is-my($_)
		}
		Nil
	}
	method is-my(IO $path) { True }
}

class FilePathKey does PathKey is export {
	method is-my(IO $path) { $path.f }
}

class DirPathKey does PathKey is export {
	method is-my(IO $path) { $path.d }
}

class ReporterClassesKey does Key[List] is export {
	method convert($value --> List) {
		return Nil without $value;
		return ('simple,' ~ $value)
			.split(',')
			.grep(*.chars)
			.map(*.split('-').map(*.tc).join)
			.map(-> $name { 'App::Racoco::Report::Reporter' ~ $name })
			.map(-> $compunit-name {
				try require ::($compunit-name);
				my $class = ::($compunit-name);
				if $class ~~ Failure {
					$class.so;
					note "Cannot use $compunit-name package as reporter.";
				}
				$class;
			})
			.grep(* !~~ Failure)
			.List;
	}
}

class ExecutableInDirKey does Key[Str] is export {
	has Str $.exec-name;
	multi method of(Str() $name) {
		die 'use .of with two params for ExecutableInDirKey';
	}
	multi method of(Str() $name, Str() $exec-name) {
		self.bless: :$name, :$exec-name
	}
	method convert($value --> Str) {
		return Nil without $value;
		my $app = $value.IO.add($!exec-name ~ ($*DISTRO.is-win ?? '.exe' !! ''));
		App::Racoco::X::WrongRakuBinDirPath.new(path => $value).throw unless $app.e;
		$app.Str
	}
}

role Configuration is export {
	method or(--> Factory) { ConfigurationFactoryOr.new(get => self) }
	multi method get(::?CLASS:D: Str() $key) { ... }
	multi method get(::?CLASS:D: Key $key) { $key.convert(self.get($key.name)) }
	multi method AT-KEY (::?CLASS:D: Str() $key) { self.get($key) }
	multi method AT-KEY (::?CLASS:D: Key $key) { self.get($key) }
	multi method EXISTS-KEY (::?CLASS:D: Str() $key) { self.get($key).defined }
	multi method EXISTS-KEY (::?CLASS:D: Key $key) { self.get($key).defined }
}

class Or does Configuration {
	has $!get is built is required;
	has $!or is built is required;
	multi method get(::?CLASS:D: Str() $key) { $!get.get($key) // $!or.get($key) }
	multi method get(::?CLASS:D: Key $key) {
		$key.convert($!get.get($key.name)) // $key.convert($!or.get($key.name))
	}
}

class Empty does Configuration {
	multi method get(::?CLASS:D: Str() $key) { Nil }
}

class Env does Configuration {
	multi method get(::?CLASS:D: Str() $key) { %*ENV{$key} // Nil }
}

class Args does Configuration {
	has %!values is built;
	multi method get(::?CLASS:D: Str() $key) { %!values{$key} // Nil }
}

role Factory {
	method empty(--> Configuration:D) { ... }
	method env(--> Configuration:D) { ... }
	method args(*%values --> Configuration:D) { ... }
	method property-line($line) { ... }
	method ini($content, :$section = '_') { ... }
	method defaults() { ... }
}

class ConfigurationFactory does Factory is export {
	method empty(--> Configuration:D) { Empty.new }
	method env(--> Configuration:D) { Env.new }
	method args(*%values) { Args.new(:%values) }
	method property-line($line) {
		my %values = ($line // '').split(';', :skip-empty)
				.map(*.split(':', :skip-empty)).flat
				.map(*.trim).map({ $^a => $^b }).Map;
		Args.new(:%values);
	}
	method ini($content, :$section = '_') {
		my %values = ConfigFile::parse(($content // '') ~ "\n"){$section} // %();
		Args.new(:%values)
	}
	method defaults() {
		my %values = %(
			append => False,
			cache-dir => App::Racoco::Paths::DOT-RACOCO,
			exec => 'prove6',
			fail-level => 0,
			lib => 'lib',
			raku-bin-dir => $*EXECUTABLE.parent.Str,
			silent => False,
			reporter => ''
		);
		Args.new(:%values)
	}
}

class ConfigurationFactoryOr does Factory {
	has $!get is built is required;
	method !make($or) {
		Or.new(:$!get, :$or);
	}
	method empty(--> Configuration:D) {
		self!make(ConfigurationFactory.empty)
	}
	method env(--> Configuration:D) {
		self!make(ConfigurationFactory.env)
	}
	method args(*%values --> Configuration:D) {
		self!make(ConfigurationFactory.args(|%values))
	}
	method property-line($line) {
		self!make(ConfigurationFactory.property-line($line))
	}
	method ini($content, :$section = '_') {
		self!make(ConfigurationFactory.ini($content, :$section))
	}
	method defaults() {
		self!make(ConfigurationFactory.defaults)
	}
}

our sub configuration-file-content(IO() :$root) is export {
	my $path = config-path(:$root);
	return $path.f ?? $path.slurp !! '';
}

our sub make-paths-from(Configuration :$config, IO() :$root) is export {
	Paths.new(
		root => $root,
		lib => $config<lib>,
		racoco => $config<cache-dir>,
	)
}