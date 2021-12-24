use Test;
use lib 'lib';
use App::Racoco::Report::ReporterCoveralls::TransportTinyHTTP;

plan 2;

my TransportTinyHTTP $transport = TransportTinyHTTP.new;
my $content = q:to/END/;
	{
	"name": "App::RaCoCo::Reporter::ReporterCoveralls",
	"description": "RaCoCo reporter for coveralls.io service",
	}
	END

lives-ok { $transport.send(uri => 'https://httpbin.org/post', $content) }, 'success post';
dies-ok { $transport.send(uri => 'https://httpbin.org/wrong_uri', $content) }, 'fail post';

done-testing