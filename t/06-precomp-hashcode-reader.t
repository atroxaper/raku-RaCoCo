use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Fixture;
use Racoco::Paths;
use Racoco::Precomp::PrecompHashcodeReader;

plan 1;

my $reader = PrecompHashcodeReaderReal.new;

my $path = lib-precomp-path(lib => Fixture::root-folder().add('lib'))
  .add('7011F868022706D0DB123C03898593E0AB8D8AF3')
  .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');

is $reader.read(:$path), '266B9F83542BC85F73639D2D300D0701AF14F9E5',
  'hashcode ok';

done-testing