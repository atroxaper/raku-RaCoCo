use Test;
use lib 't/lib';
use Racoco::Fixture;

plan 9;

constant fixture = Racoco::Fixture;

my $root = $*TMPDIR.IO.add('fixture-dir');

fixture::create-tmp-dir($root);
fixture::create-tmp-file($root.add('file1'));
fixture::register-tmp-file($root.add('file2'));
fixture::register-tmp-dir($root.add('dir1'));

ok $root.e, 'create root';
ok $root.add('file1').e, 'create file1';
nok $root.add('file2').e, 'add file2';
nok $root.add('dir1').e, 'add dir1';
$root.add('dir1').mkdir;
ok $root.add('dir1').e, 'mkdir dir1';

fixture::clean-up;

nok $root.add('file2').e, 'unlink file1';
nok $root.add('file1').e, 'unlink file2';
nok $root.add('dir1').e, 'rmdir dir1';
nok $root.e, 'rmdir root';

done-testing
