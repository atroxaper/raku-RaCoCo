unit module App::Racoco::RunProc;

class RunProc is export {
	method run(:%vars, |c --> Proc) {
		my $comand = self!tweak-command(c.list[0], :%vars);
		my $proc = shell($comand, |c.hash);
		if $proc.exitcode != 0 {
			$*ERR.say: "Fail execute: { $comand }";
		}
		$proc
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

our sub autorun(:$proc, :%vars, |c --> Block) is export {
	-> {
		my $p = $proc.run(:%vars, |c);
		LEAVE { $p.out.close if $p && $p.out }
		$p && $p.out
		?? $p.out.slurp
		!! Nil;
	}
}
