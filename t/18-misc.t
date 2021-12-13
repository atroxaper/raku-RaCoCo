use Test;
use lib 'lib';
use App::Racoco::Misc;

plan 6;

is percent(2, 7), 28.5, '2/7';
is percent(4, 7), 57.1, '4/7';
is percent(1, 7), 14.2, '1/7';
is percent(1, 2), 50, '1/2';
is percent(30, 2), 100, '30/2';
is percent(3, 0), 100, '3/0';

done-testing;
