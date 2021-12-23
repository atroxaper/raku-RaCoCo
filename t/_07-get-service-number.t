use Test;
use lib 'lib';
use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls;
use lib 't/lib';
use Fixture;

plan 3;

my ReporterCoveralls $coveralls = ReporterCoveralls.new;
my %config-file = %('_' => %(
	service_number => 333
));
my $p = Properties.bless(command-line => %(), config-file-mode => '-', :%config-file);

%*ENV<COVERALLS_SERVICE_NUMBER> = 321;
%*ENV<GITHUB_ACTIONS> = 1;
%*ENV<GITHUB_RUN_ID> = 123;
is $coveralls.get-service-number(:$p), 123, 'github service number';

%*ENV<GITHUB_ACTIONS>:delete;
is $coveralls.get-service-number(:$p), 321, 'env service number';

%*ENV<COVERALLS_SERVICE_NUMBER>:delete;
is $coveralls.get-service-number(:$p), 333, 'properties service number';

done-testing