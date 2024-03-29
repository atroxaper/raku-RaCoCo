unit module App::Racoco::RunProc;

class RunProc is export {
	method run(:%vars, :&error-handler, |c --> Proc) {
		my $comand = self!tweak-command-placeholders(c.list[0]);
		$comand = self!tweak-command($comand, :%vars);
		my $proc = shell($comand, |c.hash);
		if $proc.exitcode != 0 {
			with &error-handler {
				error-handler($proc, $comand, &default-handler);
			} else {
				default-handler($proc, $comand);
			}
		}
		$proc
	}

	method !tweak-command-placeholders($command) {
		return $command.subst('$', '\$') unless $*DISTRO.is-win;
		return $command;
	}

	method !tweak-command($command, :%vars) {
		return $command unless %vars.elems;
		if $*DISTRO.is-win {
			my $vars-str = %vars.kv.map(-> $k, $v { "$k=$v&&" }).join(' set ');
			qq[cmd /S /C "set $vars-str $command"]
		} else {
			%vars.kv.map(-> $k, $v { "$k=$v" }).join(' ') ~ ' ' ~ $command
		}
	}
}

my sub default-handler($proc, $comand) {
	$*ERR.say: "Fail execute: { $comand }";
}

our sub autorun(:$proc, :%vars, |c --> Block) is export {
	-> {
		my $p = $proc.run(:%vars, |c);
		LEAVE { $p.out.close if $p && $p.out }
		$p && $p.out
		?? $p.out.slurp
		!! Nil;
	}
}
