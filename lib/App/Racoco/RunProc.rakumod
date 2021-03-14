unit module App::Racoco::RunProc;

class RunProc is export {
  method run(|c --> Proc) {
    my $proc = shell(|c);
    if $proc.exitcode != 0 {
    	$*ERR.say: "Fail execute: {c.List[0]}";
    }
    $proc
  }
}
