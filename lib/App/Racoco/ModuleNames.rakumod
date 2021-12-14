unit module App::Racoco::ModuleNames;
use App::Racoco::Sha;

our sub module-parts(IO() :$path is copy --> Positional) is export {
	my @parts;
	my $last-len = $path.Str.chars + 1;
	$path .= extension('');
	while $path ne '.' && $path.Str.chars < $last-len {
		@parts.push: $path.basename;
		$last-len = $path.Str.chars;
		$path .= parent;
	}
	@parts.pop if $path.Str.chars == $last-len;
	@parts.reverse.List;
}

our sub module-name(IO() :$path --> Str) is export {
	my @parts = module-parts(:$path);
	return @parts.join('::');
}

our sub file-precomp-path(IO() :$path is copy --> IO::Path) is export {
  my $module-name = module-name(:$path);
  my $sha-value = App::Racoco::Sha::create().uc($module-name);
  my $two-sha-letters = $sha-value.substr(0, 2);
  $two-sha-letters.IO.add($sha-value)
}