use Test;
use lib 'lib';
use Racoco::UtilTmpFile;

plan 11;

constant tmp-file = Racoco::UtilTmpFile;

my $root = tmp-file::create-dir($*TMPDIR.add('tmp-file-dir'));
my $file1 = tmp-file::create-file($root.add('file1'));
my $file2 = tmp-file::register-file($root.add('file2'));
my $dir1 = tmp-file::register-dir($root.add('dir1'));

ok $root.e, 'create root';
ok $file1.e, 'create file1';
nok $file2.e, 'add file2';
nok $dir1.e, 'add dir1';
$dir1.mkdir;
ok $dir1.e, 'mkdir dir1';

my $my-dir = tmp-file::create-dir($root.add('my'));
$my-dir.add('file').spurt: '';
ok $my-dir.add('file').e, 'create my file';

tmp-file::clean-up;

nok $file2.e, 'unlink file2';
nok $file1.e, 'unlink file1';
nok $dir1.e, 'rmdir dir1';
nok $root.e, 'rmdir root';

nok $my-dir.e, 'rmdir my dir';

done-testing
