use App::Racoco::Report::Reporter:ver<1.5+>;
use App::Racoco::Report::DataPart:ver<1.5+>;
use App::Racoco::Report::Data:ver<1.5+>;

unit class App::Racoco::Report::ReporterCoveralls does Reporter is export;

method do(IO::Path:D :$lib, Data:D :$data) {
	# 1 collect all configurations
	# 2 collect data to send
	# 3 send
}