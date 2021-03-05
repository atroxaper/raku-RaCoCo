use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::ProjectName;
use Racoco::Fixture;
use Racoco::TmpDir;

plan 2;

is project-name(lib => Fixture::root-folder().add('lib')), 'Test Project',
  'project name from meta ok';

is project-name(lib => create-tmp-dir('racoco-tests').add('lib')), 'racoco-tests',
  'project name from path ok';


done-testing