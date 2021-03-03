unit module Racoco::RunProc;

class RunProc is export {
  method run(|c --> Proc) {
    my $proc = shell(|c);
    if $proc.exitcode != 0 {
    	$*ERR.say: "Fail proc execute: {c.List[0]}";
    }
    $proc
  }
}
