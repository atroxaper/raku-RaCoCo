use Test;
use lib 'lib';
use App::Racoco::Report::ReporterCoveralls::TransportTinyHTTP;

plan 2;

my TransportTinyHTTP $transport = TransportTinyHTTP.new;
ok $transport.send(
	uri => 'https://httpbin.org/post',
	q:to/END/), 'succes post';
	{
	"name": "App::RaCoCo::Reporter::ReporterCoveralls",
	"description": "RaCoCo reporter for coveralls.io service",
	}
	END
nok $transport.send(
	uri => 'https://httpbin.org/wrong_uri',
	q:to/END/), 'fail post';
	{
	"name": "App::RaCoCo::Reporter::ReporterCoveralls",
	"description": "RaCoCo reporter for coveralls.io service",
	}
	END

done-testing