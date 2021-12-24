use Test;
use lib 'lib';
use App::Racoco::Report::ReporterCoveralls::MD5;

plan 1;

is MD5.new.md5('ffffooobar'), '107a16238739151b1d3af196c2596a55';

done-testing