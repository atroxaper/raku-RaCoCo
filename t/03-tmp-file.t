use Test;
use lib 't/lib';
use App::Racoco::TmpDir;

plan 9;

my $sources = create-tmp-dir('racoco-tests');
ok $sources.e, 'create sources';

my $sub-dir = register-dir($sources.add('sub-dir'));
nok $sub-dir.e, 'register sub-dir';

$sub-dir.mkdir;
ok $sub-dir.e, 'mkdir sub-dir';

lives-ok { register-dir('not-exists') }, 'register not-exists';

my $dir-with-file = create-dir($sources.add('dir-with-file'));
$dir-with-file.add('file').spurt: '';
ok $dir-with-file.add('file').e, 'create dir-with-file/file';

lives-ok { clean-up }, 'good clean-up';

nok $sub-dir.e, 'rmdir sub-dir';
nok $sources.e, 'rmdir sources';
nok $dir-with-file.e, 'rmdir dir-with-file';

done-testing
