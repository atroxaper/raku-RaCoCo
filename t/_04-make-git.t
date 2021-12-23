use Test;
use lib 'lib';
use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls;
use lib 't/lib';
use Fixture;

plan 1;

my $lib = 't-resources/_02-make-source-files-json'.IO;
my $*create-proc = Fixture::mockProc(|%(
		'%H' => '_hash',
		'%aN' => '_author',
		'%ae' => '_author_email',
		'%cN' => '_commiter',
		'%ce' => '_commiter_email',
		'%s' => '_message',
		'--abbrev-ref' => '_branch',
		'remote' => "origin  origin.git (fetch)\norigin  origin.git (push)\nfork  fork.git (fetch)",
	));
my ReporterCoveralls $coveralls = ReporterCoveralls.new;
my $properties = Properties.new(lib => $*TMPDIR.add('lib'));

is $coveralls.make-git(:$properties),
q:to/END/.trim, 'make-git';
{
"git":{
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