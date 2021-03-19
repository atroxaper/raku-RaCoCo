unit module App::Racoco::ProjectName;

use App::Racoco::Paths;

our sub project-name(IO::Path :$lib --> Str) is export {
  from-meta(:$lib) // from-path(:$lib) // Nil
}

sub from-meta(:$lib) {
  my $path = meta6-path(:$lib);
  return Nil unless $path.e;
  my $line-with-name = $path.slurp.lines.grep(* ~~ /'"name"'/).first;
  return Nil unless $line-with-name;
  ($line-with-name.split(':').[*-1].trim ~~ / <-['",]>+/).Str
}

sub from-path(:$lib) {
  parent-name($lib)
}