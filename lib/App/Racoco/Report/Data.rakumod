unit class App::Racoco::Report::Data is export;

use App::Racoco::Paths;
use App::Racoco::Report::DataPart;
use App::Racoco::Misc;
use App::Racoco::X;

constant HEADER = 'RaCoCo report v2:';
constant LEGEND = 'Filename | Coverage% | line hit-time line hit-time ... [| line hit-time line hit-time ... ]';

has $!parts is built;

method new(::?CLASS:U: :%coverable, :%covered --> ::?CLASS) {
	my $parts = %coverable.map(-> $c {
		DataPart.new(
			$c.key,
			coverable => $c.value,
			covered => %covered{$c.key} // bag()
		)
	}).map({.file-name => $_}).Map;
	self.bless(:$parts)
}

method read(::?CLASS:U: :$lib! --> ::?CLASS) {
	my $path = report-data-path(:$lib);
	CannotReadReport.new(path => $lib).throw unless $path.e;

	my $lines := $path.slurp.lines;
	if $lines[0] ne HEADER || $lines[1] ne LEGEND {
		return self.new(parts => {});
	}
	my $parts = $lines.skip(2)
		.map({DataPart.read($_)})
		.grep(*.file-name.chars)
		.map({.file-name => $_}).Map;
	self.bless(:$parts)
}

method plus(::?CLASS:U: ::?CLASS:D $data1, ::?CLASS:D $data2 --> ::?CLASS) {
	my ($parts1, $parts2) = ($data1, $data2)>>!parts;
	my $parts = ($parts1.keys (+) $parts2.keys).keys
		.map({DataPart.plus($parts1{$_}, $parts2{$_})})
		.map({$_.file-name => $_}).Map;
	self.bless(:$parts)
}

method for(:$file-name --> DataPart) {
	$!parts{$file-name} // Nil
}

method !parts() { $!parts }

method get-all-parts(--> Positional) {
	$!parts.values.sort(*.file-name).List
}

method write(:$lib!) {
	report-data-path(:$lib).spurt:
		join $?NL,
			HEADER,
			LEGEND,
			$!parts.values.sort(*.file-name)
}

method percent(--> Rat) {
	percent(
		([+] $!parts.values.map(*.covered-amount)),
		([+] $!parts.values.map(*.coverable-amount))
	)
}