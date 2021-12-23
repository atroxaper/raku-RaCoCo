# Content of the file was copied from Config::INI module
# ("Tadeusz “tadzik” Sośnierz", "Nobuo Danjou") on purpose.
# The idea was to depends on no modules at all.

unit module App::Racoco::ConfigFile is export;

grammar INI {
	token TOP {
		^
		<.eol>*
		<toplevel>?
		<sections>*
		<.eol>*
		$
	}
	token toplevel { <keyval>* }
	token sections { <header> <keyval>* }
	token header   { ^^ \h* '[' ~ ']' $<text>=<-[ \] \n ]>+ \h* <.eol>+ }
	token keyval   { ^^ \h* <key> \h* '=' \h* <value>? \h* <.eol>+ }
	regex key      { <![#\[]> <-[;=]>+ }
	regex value    { [ <![#;]> \N ]+ }
	token eol      { [ <[#;]> \N* ]? \n }
}

class INI::Actions {
	method TOP ($/) {
		my %hash = $<sections>».ast;
		%hash<_> = $<toplevel>.ast.hash if $<toplevel>.?ast;
		make %hash;
	}
	method toplevel($/) { make $<keyval>».ast.hash }
	method sections($/) { make $<header><text>.Str => $<keyval>».ast.hash }
	method keyval($/) { make $<key>.Str.trim => $<value>.defined ?? $<value>.ast !! '' }
	method value($/) {
		without $/ {
			make '';
			return;
		}
		with $/.Str.trim {
			make $_;
			make True if $_ ~~ any(<yes on true True 1>);
			make False if $_ ~~ any(<no off false False 0>);
		}
	}
}

our sub parse(Str $string) {
	INI.parse($string, :actions(INI::Actions.new)).ast;
}