use Test;
use lib 'lib';
use Racoco::PrecompFile;

plan 1;

my $getter = HashcodeGetter.new;

my $precomp = 't'.IO.add('resources').add('root-folder').add('lib1')
  .add('.precomp').add('7011F868022706D0DB123C03898593E0AB8D8AF3')
  .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');

is $getter.get($precomp), 'E65F8B87B22A41EC7A4084D299523BD828CCE5E4',
  'hashcode ok';

done-testing