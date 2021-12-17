use Test;
use lib 'lib';
use App::Racoco::Cli;
use lib 't/lib';

plan 18;

my @*RESULT;
my &*ARGS-TO-CAPTURE = sub (&, @args) { @*RESULT := @args }

sub test(@args, @expected, :$desc) {
	try ARGS-TO-CAPTURE(-> {}, @args);
	is-deeply @*RESULT.sort, @expected.sort, $desc;
}

test((),(), desc => 'empty');

test(my $enter = ('
--lib=libdir
--raku-bin-dir=rakudir
--exec
--reporter=custom-reporter
--silent
--append
--fail-level'
.trim.split($?NL)
), $enter, desc => 'full');

test(
	(<--reporter=custom-reporter --html --color-blind>),
	('--reporter=custom-reporter,html-color-blind',),
	desc => 'reporter: custom html color blind'
);

test(
	(<--reporter=custom-reporter --html>),
	('--reporter=custom-reporter,html',),
	desc => 'reporter: custom html'
);

test(
	(<--html --color-blind>),
	('--reporter=html-color-blind',),
	desc => 'reporter: html color blind'
);

test(
	(<--html>,),
	('--reporter=html',),
	desc => 'reporter: html'
);

test(
	(<--color-blind>,),
	(),
	desc => 'reporter: color-blind'
);

test(
	(<--reporter=custom-reporter --color-blind>),
	('--reporter=custom-reporter',),
	desc => 'reporter: custom color blind'
);

test(
	(<--html --reporter=custom-reporter>),
	('--reporter=custom-reporter,html',),
	desc => 'reporter: html custom'
);

test(
	(<--html --reporter=custom-reporter --color-blind>),
	('--reporter=custom-reporter,html-color-blind',),
	desc => 'reporter: html custom color blind'
);

test(
	(<--reporter=custom-reporter --reporter=my --html>),
	('--reporter=custom-reporter,html,my',),
	desc => 'reporter: html custom my html'
);

test(
	(<--exec -l>),
	('fail',),
	desc => 'exec: exec l'
);

test(
	(<--/exec -l>),
	('fail',),
	desc => 'exec: /exec l'
);

test(
	(<--exec="prove6" -l>),
	('fail',),
	desc => 'exec: exec= l'
);


test(
	('--exec="prove6 t xt"',),
	('--exec="prove6 t xt"',),
	desc => 'exec: exec='
);

test(
	(<--/exec>,),
	('--/exec',),
	desc => 'exec: /exec'
);

test(
	(<--exec>,),
	('--exec',),
	desc => 'exec: exec'
);

test(
	(<-l>,),
	('--exec="prove6 -l"',),
	desc => 'exec: -l'
);

done-testing;
exit; # this exit is need to prevent a stun in recursion MAIN call