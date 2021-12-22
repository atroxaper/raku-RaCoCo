use App::Racoco::Report::ReporterCoveralls::Transport;
use App::Racoco::Report::ReporterCoveralls::Factory;
unit class App::Racoco::Report::ReporterCoveralls::Postman
	is export;

has Transport $!transport = Factory::create-transport;

