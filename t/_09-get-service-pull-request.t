use Test;
use lib 'lib';
use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls;
use lib 't/lib';
use Fixture;

plan 3;

my ReporterCoveralls $coveralls = ReporterCoveralls.new;
#my $p = Properties.new(lib => $*TMPDIR.add('lib'), command-line => 'repo_token:123');
my %config-file = %('_' => %());
my $p = Properties.bless(command-line => %(), config-file-mode => '-', :%config-file);

%*ENV<GITHUB_ACTIONS> = 1;
%*ENV<GITHUB_REF> = 'refs/pull/123';
is $coveralls.get-service-pull-request(:$p), 123, 'github service pull request';

%*ENV<GITHUB_REF> = 'blabla/123';
is $coveralls.get-service-pull-request(:$p), '', 'no github service pull request';

%*ENV<GITHUB_ACTIONS>:delete;
is $coveralls.get-service-pull-request(:$p), '', 'general service pull request';

done-testing