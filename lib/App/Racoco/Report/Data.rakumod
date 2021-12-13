unit class App::Racoco::Report::Data is export;

use App::Racoco::Paths;
use App::Racoco::Report::DataPart;
use App::Racoco::X;

constant HEADER = 'RaCoCo report v2:';
constant LEGEND = 'Filename | Coverage% | line hit-time line hit-time ... [| line hit-time line hit-time ... ]';

has $!parts is built;

method read(:$lib!) {
	my $path = report-data-path(:$lib);
	CannotReadReport.new(path => $lib).throw unless $path.e;

	my $lines := $path.slurp.lines;
	$lines[0];
	$lines[1];
	my $parts = $lines.skip(2).map({DataPart.read($_)}).map({.file-name => $_}).Map;
	self.new(:$parts)
}

method for(:$file-name --> DataPart) {
	$!parts{$file-name} // Nil
}