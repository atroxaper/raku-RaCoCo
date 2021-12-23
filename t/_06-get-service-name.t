use Test;
use lib 'lib';
use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls;
use lib 't/lib';
use Fixture;

plan 4;

my ReporterCoveralls $coveralls = ReporterCoveralls.new;
#my $p = Properties.new(lib => $*TMPDIR.add('lib'), command-line => 'repo_token:123');
my %config-file = %('_' => %(
	github_service_name => 'github',
	service_name => 'general-name'
));
my $p = Properties.bless(command-line => %(), config-file-mode => '-', :%config-file);

%*ENV<COVERALLS_SERVICE_NAME> = 'env-name';
%*ENV<GITHUB_ACTIONS> = 1;
is $coveralls.get-service-name(:$p), 'github', 'github service name from properties';

%config-file<_><github_service_name>:delete;
is $coveralls.get-service-name(:$p), 'github-actions', 'general github service name';

%*ENV<GITHUB_ACTIONS>:delete;
is $coveralls.get-service-name(:$p), 'env-name', 'env name';

%*ENV<COVERALLS_SERVICE_NAME>:delete;
is $coveralls.get-service-name(:$p), 'general-name', 'service-name';

done-testing