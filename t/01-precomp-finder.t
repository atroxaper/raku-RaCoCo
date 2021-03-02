use Test;
use lib 'lib';
use Racoco::PrecompFile;
use Racoco::Paths;
use Racoco::Sha;
use Racoco::X;

plan 9;

my $sources = 't-resources'.IO.add('root-folder');
my $sha = Racoco::Sha::create();
my ($file, $lib, $finder);

sub setUp($file-name, $lib-name) {
  $file = $file-name;
  $lib = $sources.add($lib-name);
  $finder = Finder.new(:$lib);
}

{
  my $lib = $sources.add('not-exists-lib');
  throws-like { Finder.new(:$lib) }, Racoco::X::WrongLibPath,
    'find with wrong lib path', message => /$lib/;
}

{
  setUp('Module.rakumod', 'lib');
  my $precomp = lib-precomp-path(:$lib)
      .add('7011F868022706D0DB123C03898593E0AB8D8AF3')
      .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');
  my $result = $finder.find($file);
  isa-ok $result, IO::Path, 'find io';
  ok $result.e, 'find exists';
  ok $result.Str.starts-with($lib), 'find under source';
  is $result.absolute.IO, $precomp.IO, 'find ok';
}

{
  setUp('NotExists.rakumod', 'lib');
  my $result = $finder.find($file);
  nok $result.DEFINITE, 'cannot find precomp file';
}

{
  my $lib = $sources.add('two-precomp-lib');
  throws-like { Finder.new(:$lib) }, Racoco::X::AmbiguousPrecompContent,
    'two precomp content', message => /$lib/;

}

{
  setUp('Module.rakumod', 'no-precomp-lib');
  my $result = $finder.find($file);
  nok $result.DEFINITE, 'cannot find .precomp folder';
}

{
  setUp('Module2.rakumod', 'lib');
  my $expected = our-precomp-path(:$lib).add('C4')
      .add('C42D08C62F336741E9DBBDC10EFA8A4673AA820F');
  is $finder.find($file).absolute.IO, $expected, 'find in our precomp';
}

done-testing