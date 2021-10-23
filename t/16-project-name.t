use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::ProjectName;
use App::Racoco::Fixture;
use App::Racoco::TmpDir;

plan 2;

is project-name(lib => Fixture::root-folder().add('lib')), 'Test::Project',
  'project name from meta ok';

is project-name(lib => TmpDir::create-tmp-dir('racoco-tests').add('lib')), 'racoco-tests',
  'project name from path ok';


done-testing