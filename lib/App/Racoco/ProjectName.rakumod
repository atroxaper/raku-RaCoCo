unit module App::Racoco::ProjectName;

use App::Racoco::Paths;

our sub project-name(Paths :$paths --> Str) is export {
  from-meta(:$paths) // from-root(:$paths) // Nil
}

sub from-meta(:$paths) {
  my $path = $paths.meta6-path;
  return Nil unless $path.e;
  my $line-with-name = $path.slurp.lines.first(* ~~ /'"name"'/);
  return Nil unless $line-with-name;
  ($line-with-name.split(' ').[*-1].trim ~~ / <-['",]>+/).Str
}

sub from-root(:$paths) {
  $paths.root-name
}