unit class App::Racoco::Report::Data is export;

use App::Racoco::Paths;
use App::Racoco::Report::DataPart;
use App::Racoco::X;

constant HEADER = 'RaCoCo report v2:';
constant LEGEND = 'Filename | Coverage% | line hit-time line hit-time ... [| line hit-time line hit-time ... ]';

has $!parts is built;

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

method for(:$file-name --> DataPart) {
	$!parts{$file-name} // Nil
}

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