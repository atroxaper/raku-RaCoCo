use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Paths;

unit role App::Racoco::Report::Reporter is export;

method do(Paths :$paths, Data :$data, Properties :$properties) { ... }