use Test;
use lib 'lib';
use Racoco::UtilTmpFile;

plan 11;

constant tmp-file = Racoco::UtilTmpFile;

my $root = $*TMPDIR.add('tmp-file-dir');

tmp-file::create-dir($root);
tmp-file::create-file($root.add('file1'));
tmp-file::register-file($root.add('file2'));
tmp-file::register-dir($root.add('dir1'));

tmp-file::create-dir($root.add('my'));
$root.add('my').add('file').spurt: '';

ok $root.e, 'create root';
ok $root.add('file1').e, 'create file1';
nok $root.add('file2').e, 'add file2';
nok $root.add('dir1').e, 'add dir1';
$root.add('dir1').mkdir;
ok $root.add('dir1').e, 'mkdir dir1';

ok $root.add('my').add('file').e, 'create my file';

tmp-file::clean-up;

nok $root.add('file2').e, 'unlink file1';
nok $root.add('file1').e, 'unlink file2';
nok $root.add('dir1').e, 'rmdir dir1';
nok $root.e, 'rmdir root';

nok $root.add('my').e, 'rmdir my dir';

done-testing
