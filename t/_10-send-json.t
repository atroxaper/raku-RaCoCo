use Test;
use lib 'lib';
use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls;
use lib 't/lib';
use Fixture;
use Mocks;

plan 1;

my $*create-transport = Mocks::TransportMock.new;
my $*create-proc = Fixture::mockProc(|%(
		'%H' => '_hash',
		'%aN' => '_author',
		'%ae' => '_author_email',
		'%cN' => '_commiter',
		'%ce' => '_commiter_email',
		'%s' => '_message',
		'--abbrev-ref' => '_branch',
		'remote' => "origin  origin.git (fetch)\norigin  origin.git (push)\nzork  zork.git (fetch)",
	));
my $data = Data.new(
	coverable => ('Module1.rakumod', set(3, 4), 'Module2.rakumod', set(3)).Map,
	covered => ('Module1.rakumod', bag(3), 'Module2.rakumod', bag(3)).Map
);
my $lib = 't-resources/_02-make-source-files-json'.IO;
my %config-file = %('_' => %());
my $p = Properties.bless(command-line => %(), config-file-mode => '-', :%config-file);
%*ENV<GITHUB_ACTIONS> = 1;
%*ENV<GITHUB_TOKEN> = 'github-token';
%*ENV<GITHUB_RUN_ID> = 123;
%*ENV<GITHUB_REF> = 'refs/pull/123';
my ReporterCoveralls $coveralls = ReporterCoveralls.new;
$coveralls.do(:$lib, :$data, properties => $p);

is $*create-transport.sended,
q:to/END/.trim, 'make json ok';
{
"repo_token":"github-token",
"service_name":"github-actions",
"service_number":"123",
"service_job_id":"",
"service_pull_request":"123",
"source_files": [
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
],
"git": {
	"head":{
		"id":"_hash",
		"author_name":"_author",
		"author_email":"_author_email",
		"committer_name":"_commiter",
		"committer_email":"_commiter_email",
		"message":"_message"
	},
	"branch":"_branch",
	"remotes": [
		{
			"name":"origin",
			"url": "origin.git"
		}
	]
}
}
END

done-testing