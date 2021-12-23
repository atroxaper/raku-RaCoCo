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
	service_job_id => 333
));
my $p = Properties.bless(command-line => %(), config-file-mode => '-', :%config-file);

%*ENV<COVERALLS_SERVICE_JOB_ID> = 321;
%*ENV<GITHUB_ACTIONS> = 1;
is $coveralls.get-service-job-id(:$p), '', 'github service job id';

%*ENV<GITHUB_ACTIONS>:delete;
is $coveralls.get-service-job-id(:$p), 321, 'env service job id';

%*ENV<COVERALLS_SERVICE_JOB_ID>:delete;
is $coveralls.get-service-job-id(:$p), 333, 'properties service job id';

done-testing