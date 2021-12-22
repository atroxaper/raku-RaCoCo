use Test;
use lib 'lib';
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls;

plan 1;

my $data = Data.new(
	coverable => ('Module1.rakumod', set(3, 4), 'Module2.rakumod', set(3)).Map,
	covered => ('Module1.rakumod', bag(3), 'Module2.rakumod', bag(3)).Map
);
my $lib = 't-resources/_02-make-source-files-json'.IO;
my ReporterCoveralls $coveralls = ReporterCoveralls.new;

say $coveralls.make-source-files-json(:$lib, :$data);

done-testing