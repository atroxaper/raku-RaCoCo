use Test;
use lib 'lib';
use App::Racoco::Report::ReporterCoveralls::Factory;
use lib 't/lib';
use Mocks;

plan 2;

my $*create-transport = Mocks::TransportMock.new;
is Factory::create-transport.uri, 'https://my-host/api/v1/jobs', 'transport mock';

my $*create-md5 = Mocks::MD5Mock.new;
is Factory::create-md5.md5('lib/Module/ModuleName.rakumod'),
	'｢lib/Module/...｣', 'md5 mock';

done-testing;
