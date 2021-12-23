use Test;
use lib 'lib';
use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls;
use lib 't/lib';
use Fixture;

plan 3;

my ReporterCoveralls $coveralls = ReporterCoveralls.new;
my $p = Properties.new(lib => $*TMPDIR.add('lib'), command-line => 'repo_token:123');

%*ENV<GITHUB_ACTIONS> = 1;
%*ENV<GITHUB_TOKEN> = 'github-token';
%*ENV<COVERALLS_REPO_TOKEN> = 'env-token';
is $coveralls.get-repo-token(:$p), 'github-token', 'github token';

%*ENV<GITHUB_ACTIONS>:delete;
is $coveralls.get-repo-token(:$p), 'env-token', 'env token';

%*ENV<COVERALLS_REPO_TOKEN>:delete;
is $coveralls.get-repo-token(:$p), '123', 'conf token';

done-testing