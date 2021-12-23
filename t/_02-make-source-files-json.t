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

is $coveralls.make-source-files-json(:$lib, :$data),
q:to/END/.trim;
{
"name":"_02-make-source-files-json/Module1.rakumod",
"source_digest":"46825b98d27e64057eeaf06057641d0c",
"coverage":[null,null,1,0,null]
},
{
"name":"_02-make-source-files-json/Module2.rakumod",
"source_digest":"fdbfbcd3d37d0fedb6e9fcdada5ae3d0",
"coverage":[null,null,1]
}
END

done-testing