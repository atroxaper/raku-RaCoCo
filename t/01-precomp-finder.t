use Test;
use lib 'lib';

use Racoco::PrecompFileFind;
use Racoco::X;
plan 9;

my $source = 't'.IO.add('resources').add('useful-provider');

{
  my $lib = $source.add('not-exists-lib');
  throws-like { Finder.new(:$lib) }, Racoco::X::WrongLibPath,
    'find with wrong lib path', message => /$lib/;
}

{
  my $file = 'Module.rakumod';
  my $lib = $source.add('lib1');
  my $precomp = $lib.add('.precomp')
      .add('7011F868022706D0DB123C03898593E0AB8D8AF3')
      .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');
  my $finder = Finder.new(:$lib);
  my $result = $finder.find($file);
  isa-ok $result, IO, 'find io';
  ok $result.e, 'find exists';
  ok $result.is-absolute, 'find absolute';
  ok $result.Str.starts-with($lib.absolute), 'find under source';
  is $result, $precomp.IO.absolute.IO, 'find ok';
}

{
  my $file = 'NotExists.rakumod';
  my $lib = $source.add('lib1');
  my $finder = Finder.new(:$lib);
  my $result = $finder.find($file);
  nok $result.DEFINITE, 'cannot find precomp file';
}

{
  my $file = 'Module.rakumod';
  my $lib = $source.add('lib2');
  throws-like { Finder.new(:$lib) }, Racoco::X::AmbiguousPrecompContent,
    'two precomp content', message => /$lib/;

}

{
  my $file = 'Module.rakumod';
  my $lib = $source.add('lib3');
  my $finder = Finder.new(:$lib);
  my $result = $finder.find($file);
  nok $result.DEFINITE, 'cannot find .precomp folder';
}

done-testing