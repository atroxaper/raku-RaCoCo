use Test;
use lib 'lib';
use Module3;

plan 2;

is mod3(True), 'mod3', 'mod3 ok';
is mod3(False), '3dom', '3dom ok';

done-testing