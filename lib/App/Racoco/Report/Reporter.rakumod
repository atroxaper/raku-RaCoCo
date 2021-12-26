use App::Racoco::Properties;
use App::Racoco::Report::Data;

unit role App::Racoco::Report::Reporter is export;

method do(IO() :$lib, Data :$data, Properties :$properties) { ... }