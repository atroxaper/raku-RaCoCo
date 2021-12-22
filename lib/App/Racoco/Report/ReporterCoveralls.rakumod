use App::Racoco::Report::Reporter;
use App::Racoco::Report::DataPart;
use App::Racoco::Report::Data;

unit class App::Racoco::Report::ReporterCoveralls does Reporter is export;

method do(IO::Path:D :$lib, Data:D :$data) {
	# 1 collect all configurations
	# 2 collect data to send
	# 3 send
}