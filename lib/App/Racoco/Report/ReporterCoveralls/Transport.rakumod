unit role App::Racoco::Report::ReporterCoveralls::Transport
	is export;

method host() { ... }

method uri() { "https://{self.host}/api/v1/jobs" }

method send(Str:D $obj, :$uri --> Bool) { ... }
