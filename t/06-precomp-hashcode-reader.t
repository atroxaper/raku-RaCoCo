use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Fixture;
use App::Racoco::Paths;
use App::Racoco::Precomp::PrecompHashcodeReader;

plan 1;

Fixture::restore-root-folder();

my $reader = PrecompHashcodeReaderReal.new;

my $path = lib-precomp-path(lib => Fixture::root-folder().add('lib'))
  .add(Fixture::compiler-id())
  .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');

is $reader.read(:$path), '266B9F83542BC85F73639D2D300D0701AF14F9E5',
  'hashcode ok';

done-testing