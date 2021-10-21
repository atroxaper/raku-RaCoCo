use Test;
use lib 'lib';
use App::Racoco::Paths;
use lib 't/lib';
use App::Racoco::TmpDir;

plan 8;

my ($sources, $lib) = TmpDir::create-tmp-lib('racoco-tests');

{
	my $racoco-path = racoco-path(:$lib);
	ok $racoco-path.is-absolute, 'racoco path is absolute';
	ok $racoco-path.e, 'racoco path exists';
}

{
	my $precomp-path = our-precomp-path(:$lib);
	ok $precomp-path.is-absolute, 'precomp path is absolute';
	ok $precomp-path.e, 'precomp path exists';
}

{
	nok lib-precomp-path(:$lib).e, 'lib precomp path does not exists by default';
}

{
	is our-precomp-path(:$lib).parent, racoco-path(:$lib), 'out precomp parent';
	isnt our-precomp-path(:$lib), lib-precomp-path(:$lib), 'lib and our precomp';
}

{
  is parent-name($lib), 'racoco-tests', 'parent name ok';
}
done-testing