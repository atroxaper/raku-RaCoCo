unit module App::Racoco::Configuration;

use App::Racoco::ConfigFile;
use App::Racoco::Paths;

role Factory { ... }
class ConfigurationFactoryOr { ... }

role Key[::Type] {
	has Str $.name is required;
	method convert(Str $value --> Type) { ... }
	method of(Str() $name) { self.bless: :$name }
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

role Configuration is export {
	multi method get(Str() $key) { ... }
	multi method get(Key $key) { $key.convert(self.get($key.name)) }
	method or(--> Factory) { ConfigurationFactoryOr.new(get => self) }
}

multi sub postcircumfix:<{ }>(Configuration $config, Str() $key) is export {
	$config.get($key)
}

multi sub postcircumfix:<{ }>(Configuration $config, Key $key) is export {
	$config.get($key)
}

class Or does Configuration {
	has $!get is built is required;
	has $!or is built is required;
	multi method get(Str() $key) { $!get.get($key) // $!or.get($key) }
	multi method get(Key $key) {
		$key.convert($!get.get($key.name)) // $key.convert($!or.get($key.name))
	}
}

class Empty does Configuration {
	multi method get(Str() $key) { Nil }
}

class Env does Configuration {
	multi method get(Str() $key) { %*ENV{$key} // Nil }
}

class Args does Configuration {
	has %!values is built;
	multi method get(Str() $key) { %!values{$key} // Nil }
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
			root => $*CWD,
			silent => False,
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

our sub configuration-file-content() is export {
	my $path =
		config-path(root => ConfigurationFactory.defaults{DirPathKey.of: 'root'});
	return $path.f ?? $path.slurp !! '';
}

our sub make-paths-from(Configuration $config) is export {
	Paths.new(
		root => $config{DirPathKey.of: 'root'},
		lib => $config{DirPathKey.of: 'lib'},
		racoco => $config<cache-dir>,
	)
}