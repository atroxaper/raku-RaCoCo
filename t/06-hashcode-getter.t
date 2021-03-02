use Test;
use lib 'lib';
use Racoco::PrecompFile;
use lib 't/lib';
use Racoco::Fixture;

plan 1;

my $getter = HashcodeGetterReal.new;

my $precomp = Fixture::root-folder().add('lib')
  .add('.precomp').add('7011F868022706D0DB123C03898593E0AB8D8AF3')
  .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');

is $getter.get($precomp), '266B9F83542BC85F73639D2D300D0701AF14F9E5',
  'hashcode ok';

done-testing